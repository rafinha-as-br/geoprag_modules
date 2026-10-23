import '../../../src/atraso/alerta_de_atraso_repository.dart';
import '../../../src/atraso/alerta_de_atraso_repository_impl.dart';
import '../../../src/entities/atraso_de_aplicacao.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../portal_administrador/gestao_de_aplicacoes/data/mock_pontos_de_aplicacao.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';

/// Implementação de [AplicadorPontoDeAplicacaoRepository] sobre a mesma
/// fonte mockada do portal administrador (`mockPontosDeAplicacao`) — os
/// dois apps vão consumir um único backend real futuramente, então a
/// simulação também compartilha uma única lista mutável em vez de duas
/// fontes que poderiam divergir entre si.
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AplicadorPontoDeAplicacaoRepositoryImpl
    implements AplicadorPontoDeAplicacaoRepository {
  /// [agora] é o "hoje" da verificação de atraso; só os testes o trocam.
  AplicadorPontoDeAplicacaoRepositoryImpl({
    AlertaDeAtrasoRepository? alertaDeAtrasoRepository,
    DateTime Function() agora = DateTime.now,
  }) : _alertaDeAtrasoRepository =
           alertaDeAtrasoRepository ?? AlertaDeAtrasoRepositoryImpl(),
       _agora = agora;

  final AlertaDeAtrasoRepository _alertaDeAtrasoRepository;
  final DateTime Function() _agora;

  @override
  Future<List<PontoDeAplicacao>> listarMeusPontos(String aplicadorId) async {
    return mockPontosDeAplicacao
        .where(
          (ponto) =>
              ponto.aplicadorId == aplicadorId &&
              ponto.estado != EstadoPontoDeAplicacao.desativado,
        )
        .toList();
  }

  @override
  Future<PontoDeAplicacao> buscarPorId(String id) async {
    return mockPontosDeAplicacao.firstWhere(
      (ponto) => ponto.id == id,
      orElse: () => throw EntidadeNaoEncontradaException(
        'Ponto de aplicação "$id" não encontrado.',
      ),
    );
  }

  @override
  Future<Set<String>> idsDePontosEmAtraso(String aplicadorId) async => {
    for (final ponto in await listarMeusPontos(aplicadorId))
      if (await _emAtraso(ponto)) ponto.id,
  };

  @override
  Future<bool> estaEmAtraso(String id) async =>
      _emAtraso(await buscarPorId(id));

  Future<bool> _emAtraso(PontoDeAplicacao ponto) async =>
      ponto.estadoDeAtraso(
        dataDeReferencia: _agora(),
        alertasRemovidos: await _alertaDeAtrasoRepository.listarRemovidos(
          ponto.id,
        ),
      ) ==
      EstadoDeAtraso.emAtraso;

  @override
  Future<void> registrarSubponto(String id, Subponto subponto) async {
    final index = mockPontosDeAplicacao.indexWhere((ponto) => ponto.id == id);
    if (index == -1) {
      throw EntidadeNaoEncontradaException(
        'Ponto de aplicação "$id" não encontrado.',
      );
    }
    mockPontosDeAplicacao[index] = mockPontosDeAplicacao[index]
        .registrarSubponto(subponto);
  }
}
