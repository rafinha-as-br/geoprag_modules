import '../../../src/entities/atraso_de_aplicacao.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../local/aplicacao_dao.dart';
import '../../local/ponto_dao.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';

/// "Agora" no fuso da operação (America/Sao_Paulo, o mesmo que a API usa para
/// "hoje"): o instante UTC deslocado em -3 h, com o dia de calendário de lá.
/// [verificarAtraso] lê só ano, mês e dia, então o fuso do aparelho não muda o
/// dia em que o alerta aparece.
// ponytail: UTC-3 fixo, sem horário de verão (extinto em 2019); se o Brasil o
// reinstituir, trocar pelo pacote `timezone`.
DateTime agoraNoFusoDaOperacao() =>
    DateTime.now().toUtc().subtract(const Duration(hours: 3));

/// [AplicadorPontoDeAplicacaoRepository] sobre o SQLite do aparelho
/// (GEOPRAG-203): lê o que o pull guardou e funciona sem rede.
///
/// Uma aplicação feita neste aparelho dá baixa na data agendada que atende
/// assim que seus subpontos completam o ponto, antes de o servidor confirmar:
/// sem isso o alerta de atraso continuaria aparecendo offline depois de o
/// aplicador ter aplicado.
class AplicadorPontoDeAplicacaoRepositoryLocal
    implements AplicadorPontoDeAplicacaoRepository {
  /// [agora] é o "hoje" da verificação de atraso; só os testes o trocam.
  AplicadorPontoDeAplicacaoRepositoryLocal({
    required PontoDao pontos,
    required AplicacaoDao aplicacoes,
    DateTime Function()? agora,
  }) : _pontos = pontos,
       _aplicacoes = aplicacoes,
       _agora = agora ?? agoraNoFusoDaOperacao;

  final PontoDao _pontos;
  final AplicacaoDao _aplicacoes;
  final DateTime Function() _agora;

  @override
  Future<List<PontoDeAplicacao>> listarMeusPontos(String aplicadorId) async => [
    for (final ponto in await _pontos.listar(aplicadorId: aplicadorId))
      if (ponto.estado != EstadoPontoDeAplicacao.desativado)
        await _comBaixasLocais(ponto),
  ];

  @override
  Future<PontoDeAplicacao> buscarPorId(String id) async {
    final ponto = await _pontos.buscarPorId(id);
    if (ponto == null) {
      throw EntidadeNaoEncontradaException(
        'Ponto de aplicação "$id" não encontrado.',
      );
    }
    return _comBaixasLocais(ponto);
  }

  @override
  Future<Set<String>> idsDePontosEmAtraso(String aplicadorId) async => {
    for (final ponto in await listarMeusPontos(aplicadorId))
      if (_emAtraso(ponto)) ponto.id,
  };

  @override
  Future<bool> estaEmAtraso(String id) async =>
      _emAtraso(await buscarPorId(id));

  bool _emAtraso(PontoDeAplicacao ponto) =>
      ponto.estadoDeAtraso(dataDeReferencia: _agora()) ==
      EstadoDeAtraso.emAtraso;

  /// [ponto] com a baixa das aplicações completas feitas neste aparelho: a data
  /// agendada que cada uma atende vira concluída, se ainda estava pendente.
  Future<PontoDeAplicacao> _comBaixasLocais(PontoDeAplicacao ponto) async {
    final original = ponto.agendamento;
    var agendamento = original;
    if (agendamento == null) return ponto;
    for (final aplicacao in await _aplicacoes.listarPorPonto(ponto.id)) {
      if (aplicacao.subpontos.length < ponto.quantidadeDeSubpontos) continue;
      final pendente = agendamento!.datas.any(
        (d) =>
            d.id == aplicacao.dataAgendadaId &&
            d.status == StatusDataAgendada.pendente,
      );
      if (pendente) {
        agendamento = agendamento.comDataConcluida(aplicacao.dataAgendadaId);
      }
    }
    return identical(agendamento, original)
        ? ponto
        : ponto.copyWith(agendamento: agendamento);
  }
}
