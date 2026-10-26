import '../../../src/api/sync/pull_dtos.dart';
import '../../../src/api/sync/sync_mappers.dart';
import '../../../src/entities/aplicacao.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/entities/produto.dart';
import '../../../src/errors/app_logger.dart';
import '../../local/aplicacao_dao.dart';
import '../../local/item_da_outbox.dart';
import '../../local/outbox_dao.dart';
import '../../local/ponto_dao.dart';
import '../../local/produto_dao.dart';
import '../core/resultado_da_sincronizacao.dart';

/// Aplica a resposta do pull ao banco local (GEOPRAG-202).
///
/// - Insere ou atualiza cada ponto recebido.
/// - **Nunca apaga ponto com registro pendente** na outbox: um ponto que o
///   servidor retirou do aplicador (reatribuído, por exemplo) continua visível
///   até os pendentes serem enviados; o pull seguinte o remove.
/// - Quem não tem pendência e saiu da resposta sai do aparelho. Isso vale para
///   o snapshot completo; no pull **incremental** (GEOPRAG-206) a resposta traz
///   só os pontos alterados, então "ausente da resposta" não quer dizer
///   "retirado": só saem do aparelho os pontos listados em `removidos`, ainda
///   assim nunca os que têm registro pendente.
/// - Reaplica a baixa das aplicações locais ainda não enviadas: o pull traz a
///   data agendada como o servidor a conhece (ainda pendente), mas o aplicador
///   já a atendeu neste aparelho.
/// - Guarda os produtos da resposta (GEOPRAG-203), somando aos que já tem: o
///   incremental traz só os novos.
/// - Um ponto ilegível é ignorado sozinho: o resto da resposta segue e o ponto
///   fica como estava.
class ReconciliadorDoPull {
  ReconciliadorDoPull({
    required PontoDao pontos,
    required OutboxDao outbox,
    required AplicacaoDao aplicacoes,
    required ProdutoDao produtos,
  }) : _pontos = pontos,
       _outbox = outbox,
       _aplicacoes = aplicacoes,
       _produtos = produtos;

  final PontoDao _pontos;
  final OutboxDao _outbox;
  final AplicacaoDao _aplicacoes;
  final ProdutoDao _produtos;

  /// O aparelho não guarda nenhum ponto. Um cursor guardado não vale nesse caso
  /// (o banco foi recriado): o pull incremental deixaria a lista incompleta.
  Future<bool> semPontos() async => (await _pontos.listar()).isEmpty;

  /// [incremental]: a [resposta] veio de um pull com `desde` (só o que mudou).
  Future<ResultadoDoPull> reconciliar(
    PullResponseDto resposta, {
    bool incremental = false,
  }) async {
    await _produtos.salvarTodos([
      for (final p in resposta.produtos) Produto(id: p.id, nome: p.nome),
    ]);
    final recebidos = <PontoDeAplicacao>[];
    final ignorados = <String>[];
    for (final dto in resposta.pontos) {
      try {
        // A baixa vale para todo ponto recebido (não só os que tinham pendência
        // ao começar): um registro feito durante o pull não pode "desaparecer".
        recebidos.add(await _comBaixasLocais(SyncMappers.paraPonto(dto)));
      } on Object catch (e, stackTrace) {
        AppLogger.error('ReconciliadorDoPull ponto ${dto.id}', e, stackTrace);
        ignorados.add(dto.id);
      }
    }
    await _pontos.salvarTodos(recebidos);

    // Relê as pendências: um registro feito durante o pull protege o ponto.
    final pendentesAgora = await _outbox.pontoIdsComPendencias();
    final idsDaResposta = {for (final p in resposta.pontos) p.id};
    final removidos = <String>[];
    final mantidos = <String>[];
    final locais = [for (final local in await _pontos.listar()) local.id];
    final candidatos = incremental
        ? [
            for (final id in resposta.removidos)
              if (locais.contains(id)) id,
          ]
        : locais;
    for (final id in candidatos) {
      if (idsDaResposta.contains(id)) continue;
      if (pendentesAgora.contains(id)) {
        mantidos.add(id);
      } else {
        await _pontos.remover(id);
        removidos.add(id);
      }
    }

    return ResultadoDoPull(
      incremental: incremental,
      pontosSalvos: [for (final p in recebidos) p.id],
      pontosRemovidos: removidos,
      pontosMantidos: mantidos,
      pontosIgnorados: ignorados,
      produtos: resposta.produtos,
      cursor: resposta.cursor,
    );
  }

  /// [ponto] com a baixa das aplicações completas deste aparelho cujo envio
  /// ainda está pendente: a data agendada que cada uma atende vira concluída.
  Future<PontoDeAplicacao> _comBaixasLocais(PontoDeAplicacao ponto) async {
    var agendamento = ponto.agendamento;
    if (agendamento == null) return ponto;
    for (final aplicacao in await _aplicacoes.listarPorPonto(ponto.id)) {
      if (aplicacao.subpontos.length < ponto.quantidadeDeSubpontos) continue;
      if (!await _temEnvioPendente(aplicacao)) continue;
      agendamento = _concluirData(agendamento!, aplicacao.dataAgendadaId);
    }
    return identical(agendamento, ponto.agendamento)
        ? ponto
        : ponto.copyWith(agendamento: agendamento);
  }

  Future<bool> _temEnvioPendente(Aplicacao aplicacao) async {
    for (final subponto in aplicacao.subpontos) {
      final item = await _outbox.buscarPorId(subponto.id);
      if (item != null &&
          (item.estado == EstadoDoItemDaOutbox.pendente ||
              item.estado == EstadoDoItemDaOutbox.enviando)) {
        return true;
      }
    }
    return false;
  }

  /// [agendamento] com a data [dataId] concluída, se ela ainda estiver
  /// pendente; senão, o mesmo objeto.
  Agendamento _concluirData(Agendamento agendamento, String dataId) {
    final indice = agendamento.datas.indexWhere(
      (d) => d.id == dataId && d.status == StatusDataAgendada.pendente,
    );
    if (indice == -1) return agendamento;
    return Agendamento(
      dataInicio: agendamento.dataInicio,
      intervaloDias: agendamento.intervaloDias,
      quantidadeRecorrencias: agendamento.quantidadeRecorrencias,
      datas: [
        for (var i = 0; i < agendamento.datas.length; i++)
          i == indice
              ? agendamento.datas[i].copyWith(
                  status: StatusDataAgendada.concluida,
                )
              : agendamento.datas[i],
      ],
    );
  }
}
