import 'dart:convert';

import '../../../src/api/api_client.dart';
import '../../../src/api/api_exceptions.dart';
import '../../../src/api/sync/pull_dtos.dart';
import '../../../src/api/sync/registro_dtos.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../local/item_da_outbox.dart';
import '../../local/outbox_dao.dart';
import '../core/resultado_da_sincronizacao.dart';
import '../core/servico_de_sincronizacao.dart';
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
    this.tamanhoDoLote = tamanhoMaximoDoLote,
  }) : assert(tamanhoDoLote > 0 && tamanhoDoLote <= tamanhoMaximoDoLote),
       _api = api,
       _outbox = outbox,
       _reconciliador = reconciliador,
       _dispositivoId = dispositivoId;

  static const String caminho = '/sync/aplicacoes';
  static const String caminhoDoPull = '/sync/pull';

  /// O servidor recusa lotes maiores (413).
  static const int tamanhoMaximoDoLote = 500;

  final ApiClient _api;
  final OutboxDao _outbox;
  final ReconciliadorDoPull _reconciliador;
  final Future<String> Function() _dispositivoId;
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
  Future<void> _baixar() async {
    try {
      final corpo = await _api.get(caminhoDoPull);
      final resposta = PullResponseDto.fromJson(corpo! as Map<String, dynamic>);
      _pull = await _reconciliador.reconciliar(resposta);
      _pullFalhou = false;
    } on ApiException {
      // Sem rede ou servidor fora: esperado em campo, sem log de erro.
      _pullFalhou = true;
    } catch (e, stackTrace) {
      AppLogger.error('ServicoDeSincronizacaoImpl.pull', e, stackTrace);
      _pullFalhou = true;
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
