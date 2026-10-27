import 'dart:convert';

import '../../../src/api/api_client.dart';
import '../../../src/api/api_exceptions.dart';
import '../../../src/api/sync/pull_dtos.dart';
import '../../../src/api/sync/registro_dtos.dart';
import '../../../src/api/sync/sync_json.dart' show formatarDataHoraComOffset;
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../local/item_da_outbox.dart';
import '../../local/outbox_dao.dart';
import '../core/resultado_da_sincronizacao.dart';
import '../core/servico_de_sincronizacao.dart';
import 'cursor_do_pull.dart';
import 'reconciliador_do_pull.dart';

/// [ServicoDeSincronizacao] sobre a outbox do SQLite e o [ApiClient].
///
/// - Envia os itens `PENDENTE` em lotes de até [tamanhoDoLote] (o servidor
///   recusa mais de [tamanhoMaximoDoLote]) e interpreta a resposta **por
///   item**: `CRIADO` e `DUPLICADO` marcam `ENVIADO`; `REJEITADO` marca
///   `REJEITADO` com o motivo.
/// - **Falha de requisição conta como offline**: rede, tempo esgotado, erro do
///   servidor ou token não renovável devolvem o lote à fila. O registro nunca
///   se perde, e o reenvio é seguro porque o servidor é idempotente pelo `id`.
/// - Um lote que o servidor recusa por inteiro (`400`/`413`/`422`) é reenviado
///   item a item, para que um registro inválido seja `REJEITADO` sozinho em
///   vez de travar a fila.
/// - [sincronizar] também baixa os pontos do aplicador (`GET /sync/pull`) e os
///   reconcilia com o banco pelo [ReconciliadorDoPull], sempre **depois** do
///   envio: os pendentes vão antes de o servidor poder retirar um ponto.
/// - Um fluxo por vez (ver [enviarPendentes]): envio e pull nunca rodam ao
///   mesmo tempo. A espera crescente entre tentativas que falharam é dos
///   gatilhos (`GatilhosDeSincronizacao`).
class ServicoDeSincronizacaoImpl implements ServicoDeSincronizacao {
  ServicoDeSincronizacaoImpl({
    required ApiClient api,
    required OutboxDao outbox,
    required ReconciliadorDoPull reconciliador,
    required Future<String> Function() dispositivoId,
    CursorDoPull? cursor,
    this.tamanhoDoLote = tamanhoMaximoDoLote,
  }) : assert(tamanhoDoLote > 0 && tamanhoDoLote <= tamanhoMaximoDoLote),
       _api = api,
       _outbox = outbox,
       _reconciliador = reconciliador,
       _dispositivoId = dispositivoId,
       _cursor = cursor;

  static const String caminho = '/sync/aplicacoes';
  static const String caminhoDoPull = '/sync/pull';

  /// O servidor recusa lotes maiores (413).
  static const int tamanhoMaximoDoLote = 500;

  final ApiClient _api;
  final OutboxDao _outbox;
  final ReconciliadorDoPull _reconciliador;
  final Future<String> Function() _dispositivoId;

  /// Sem cursor, todo pull é o snapshot completo.
  final CursorDoPull? _cursor;
  final int tamanhoDoLote;

  Future<ResultadoDaSincronizacao>? _emAndamento;
  bool _novaRodada = false;

  // Pedido de pull e resultado do fluxo em curso (zerados a cada fluxo novo).
  bool _pullPedido = false;
  bool _envioCompleto = true;
  ResultadoDoPull? _pull;
  bool _pullFalhou = false;

  @override
  Future<void> enviarPendentes() => _iniciar(comPull: false);

  @override
  Future<ResultadoDaSincronizacao> sincronizar() => _iniciar(comPull: true);

  Future<ResultadoDaSincronizacao> _iniciar({required bool comPull}) {
    if (comPull) _pullPedido = true;
    final atual = _emAndamento;
    if (atual != null) {
      _novaRodada = true;
      return atual;
    }
    _envioCompleto = true;
    _pull = null;
    _pullFalhou = false;
    return _emAndamento = _rodar();
  }

  /// Roda até não haver pedido de nova rodada. Decidir "mais uma rodada?" e
  /// liberar [_emAndamento] acontece no mesmo trecho síncrono: uma chamada que
  /// chega a qualquer momento ou pede outra rodada, ou começa um fluxo novo.
  Future<ResultadoDaSincronizacao> _rodar() async {
    while (true) {
      _novaRodada = false;
      try {
        _envioCompleto = await _enviarTudo();
        if (_pullPedido && _envioCompleto) {
          _pullPedido = false;
          await _baixar();
        }
      } catch (e, stackTrace) {
        AppLogger.error(
          'ServicoDeSincronizacaoImpl.enviarPendentes',
          e,
          stackTrace,
        );
        _envioCompleto = false;
        // Uma falha local depois do POST (ex.: o banco recusou a gravação do
        // resultado) não pode deixar o lote preso em `ENVIANDO`: com um fluxo
        // por vez, tudo o que está `ENVIANDO` é desta rodada.
        await _reenfileirarEmAndamento();
      }
      if (!_novaRodada) {
        // Pull pedido que não rodou porque o envio não terminou: falhou.
        if (_pullPedido) {
          _pullPedido = false;
          _pullFalhou = true;
        }
        final resultado = ResultadoDaSincronizacao(
          envioCompleto: _envioCompleto,
          pull: _pull,
          pullFalhou: _pullFalhou,
        );
        _emAndamento = null;
        return resultado;
      }
    }
  }

  /// `GET /sync/pull` + reconciliação. Falha de rede ou do servidor, resposta
  /// ilegível ou erro ao gravar não lançam: o banco fica como estava e o pull
  /// conta como falho.
  ///
  /// Com cursor guardado o pull é incremental (`desde`); sem cursor, ou se o
  /// servidor recusar o cursor, é o snapshot completo e o cursor é refeito.
  Future<void> _baixar() async {
    _pull = null;
    try {
      final (:corpo, :incremental) = await _buscarPull();
      final resposta = PullResponseDto.fromJson(corpo! as Map<String, dynamic>);
      final resultado = await _reconciliador.reconciliar(
        resposta,
        incremental: incremental,
      );
      _pull = resultado;
      _pullFalhou = false;
      await _avancarCursor(resultado);
    } on ApiException {
      // Sem rede ou servidor fora: esperado em campo, sem log de erro.
      _pullFalhou = true;
    } catch (e, stackTrace) {
      AppLogger.error('ServicoDeSincronizacaoImpl.pull', e, stackTrace);
      _pullFalhou = true;
    }
  }

  /// O corpo de `GET /sync/pull` e se ele é incremental. Pede só o que mudou
  /// quando há cursor e o banco tem pontos; sem cursor, com o banco vazio (um
  /// cursor que sobreviveu a um banco recriado), ou se o servidor recusar o
  /// cursor, pede o snapshot completo.
  Future<({Object? corpo, bool incremental})> _buscarPull() async {
    final desde = await _cursor?.ler();
    if (desde != null && !await _reconciliador.semPontos()) {
      try {
        final corpo = await _api.get(
          caminhoDoPull,
          query: {'desde': formatarDataHoraComOffset(desde.toUtc())},
        );
        return (corpo: corpo, incremental: true);
      } on RequisicaoInvalidaException {
        // Cursor que o servidor não aceita: descarta e recomeça do snapshot.
        await _cursor?.apagar();
      }
    }
    return (corpo: await _api.get(caminhoDoPull), incremental: false);
  }

  /// Guarda o cursor da resposta, mas só depois de a reconciliação estar
  /// gravada e só se não sobrou nada a rever: um ponto retirado que ficou por
  /// causa de registro pendente, ou um ponto ilegível, só volta numa resposta
  /// que abranja o instante do cursor antigo. Sem avançar, o pull seguinte os
  /// traz de novo (e o ponto sai quando os pendentes forem enviados).
  Future<void> _avancarCursor(ResultadoDoPull resultado) async {
    final cursor = _cursor;
    final novo = resultado.cursor;
    if (cursor == null || novo == null) return;
    if (resultado.pontosMantidos.isNotEmpty ||
        resultado.pontosIgnorados.isNotEmpty) {
      return;
    }
    try {
      await cursor.gravar(novo);
    } catch (e, stackTrace) {
      // A reconciliação já está gravada; o pior caso é repetir o pull.
      AppLogger.error('ServicoDeSincronizacaoImpl.cursor', e, stackTrace);
    }
  }

  Future<void> _reenfileirarEmAndamento() async {
    try {
      await _outbox.reenfileirarEmAndamento();
    } catch (e, stackTrace) {
      AppLogger.error(
        'ServicoDeSincronizacaoImpl.reenfileirarEmAndamento',
        e,
        stackTrace,
      );
    }
  }

  /// Envia a fila até esvaziá-la. Devolve `false` se parou antes por falha
  /// (algum lote voltou à fila).
  Future<bool> _enviarTudo() async {
    while (true) {
      final itens = await _outbox.pendentes(limite: tamanhoDoLote);
      if (itens.isEmpty) return true;
      if (!await _enviarLote(itens)) return false;
    }
  }

  /// Envia um lote. Devolve `false` quando o fluxo deve parar (o lote voltou à
  /// fila) e `true` quando houve avanço e vale buscar o próximo.
  Future<bool> _enviarLote(List<ItemDaOutbox> itens) async {
    final legiveis = <ItemDaOutbox>[];
    final registros = <ItemDeRegistroDto>[];
    for (final item in itens) {
      final registro = await _lerRegistro(item);
      if (registro == null) continue;
      legiveis.add(item);
      registros.add(registro);
    }
    if (registros.isEmpty) return true;

    final ids = [for (final r in registros) r.id];
    await _outbox.marcarEnviando(ids);
    final RespostaDoLoteDto resposta;
    try {
      final corpo = await _api.post(
        caminho,
        corpo: LoteDeRegistroDto(
          dispositivoId: await _dispositivoId(),
          itens: registros,
        ).toJson(),
      );
      resposta = RespostaDoLoteDto.fromJson(corpo! as Map<String, dynamic>);
    } on RequisicaoInvalidaException catch (e) {
      // O servidor recusou o lote inteiro: não é rede, repetir não adianta.
      if (registros.length == 1) {
        await _outbox.marcarRejeitado(ids.single, e.mensagemAmigavel);
        return true;
      }
      await _devolverAFila(ids, e.mensagemAmigavel);
      return _enviarUmAUm(legiveis);
    } on ApiException catch (e) {
      await _devolverAFila(ids, e.mensagemAmigavel);
      return false;
    } catch (_) {
      await _devolverAFila(ids, AppErrorMessages.envioRespostaInesperada);
      rethrow;
    }

    final porId = {for (final r in resposta.resultados) r.id: r};
    final enviados = <String>[];
    var faltouResposta = false;
    for (final id in ids) {
      final resultado = porId[id];
      if (resultado == null) {
        faltouResposta = true;
        await _outbox.registrarFalha(id, AppErrorMessages.envioSemResposta);
      } else if (resultado.status.entregue) {
        enviados.add(id);
      } else {
        await _outbox.marcarRejeitado(
          id,
          resultado.motivo ??
              resultado.codigo ??
              AppErrorMessages.registroRecusado,
        );
      }
    }
    if (enviados.isNotEmpty) await _outbox.marcarEnviado(enviados);
    return !faltouResposta;
  }

  /// Reenvia cada item num lote só dele; o que o servidor recusar fica
  /// `REJEITADO` e o resto segue. Para na primeira falha de rede.
  Future<bool> _enviarUmAUm(List<ItemDaOutbox> itens) async {
    for (final item in itens) {
      if (!await _enviarLote([item])) return false;
    }
    return true;
  }

  /// O registro do item, ou `null` se o payload guardado não é legível: esse
  /// item é marcado `REJEITADO` para não travar a fila para sempre.
  Future<ItemDeRegistroDto?> _lerRegistro(ItemDaOutbox item) async {
    try {
      return ItemDeRegistroDto.fromJson(
        jsonDecode(item.payload) as Map<String, dynamic>,
      );
    } on Object {
      await _outbox.marcarRejeitado(
        item.id,
        AppErrorMessages.registroLocalIlegivel,
      );
      return null;
    }
  }

  Future<void> _devolverAFila(List<String> ids, String erro) async {
    for (final id in ids) {
      await _outbox.registrarFalha(id, erro);
    }
  }
}
