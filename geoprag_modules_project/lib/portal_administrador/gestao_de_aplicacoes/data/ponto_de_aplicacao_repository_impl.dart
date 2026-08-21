import '../core/ponto_de_aplicacao.dart';
import '../core/ponto_de_aplicacao_repository.dart';
import 'mock_pontos_de_aplicacao.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [AdminPontoDeAplicacaoRepository] com fonte remota mockada
/// (`mockPontosDeAplicacao`).
///
/// TODO(GEOPRAG-38): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AdminPontoDeAplicacaoRepositoryImpl implements AdminPontoDeAplicacaoRepository {
  @override
  Future<List<AdminPontoDeAplicacao>> listar() async => mockPontosDeAplicacao;

  @override
  Future<AdminPontoDeAplicacao> buscarPorId(String id) async {
    return mockPontosDeAplicacao.firstWhere(
      (ponto) => ponto.id == id,
      orElse: () =>
          throw EntidadeNaoEncontradaException('Ponto de aplicação "$id" não encontrado.'),
    );
  }

  @override
  Future<AdminPontoDeAplicacao> criar({
    required String bairro,
    required double lat,
    required double lng,
    String? aplicadorId,
    double distanciaAlertaMetros = 150.0,
    int intervaloDiasEntreAplicacoes = 15,
  }) async {
    final proximoId = (mockPontosDeAplicacao.length + 1).toString();
    final ponto = AdminPontoDeAplicacao(
      id: proximoId,
      bairro: bairro,
      lat: lat,
      lng: lng,
      status: StatusPontoDeAplicacao.planejada,
      aplicadorId: aplicadorId,
      distanciaAlertaMetros: distanciaAlertaMetros,
      intervaloDiasEntreAplicacoes: intervaloDiasEntreAplicacoes,
    );
    mockPontosDeAplicacao.add(ponto);
    return ponto;
  }

  @override
  Future<AdminPontoDeAplicacao> atribuirAplicador(
    String id,
    String? aplicadorId,
  ) async {
    final index = _indexOuFalha(id);
    final atualizado = mockPontosDeAplicacao[index].copyWith(
      aplicadorId: () => aplicadorId,
    );
    mockPontosDeAplicacao[index] = atualizado;
    return atualizado;
  }

  @override
  Future<AdminPontoDeAplicacao> desativar(String id) async {
    final index = _indexOuFalha(id);
    final atualizado = mockPontosDeAplicacao[index].copyWith(ativo: false);
    mockPontosDeAplicacao[index] = atualizado;
    return atualizado;
  }

  @override
  Future<AdminPontoDeAplicacao> editar(
    String id, {
    required String bairro,
    required double lat,
    required double lng,
    double? distanciaAlertaMetros,
    int? intervaloDiasEntreAplicacoes,
  }) async {
    final index = _indexOuFalha(id);
    final atualizado = mockPontosDeAplicacao[index].copyWith(
      bairro: bairro,
      lat: lat,
      lng: lng,
      distanciaAlertaMetros: distanciaAlertaMetros,
      intervaloDiasEntreAplicacoes: intervaloDiasEntreAplicacoes,
    );
    mockPontosDeAplicacao[index] = atualizado;
    return atualizado;
  }

  int _indexOuFalha(String id) {
    final index = mockPontosDeAplicacao.indexWhere((ponto) => ponto.id == id);
    if (index == -1) {
      throw EntidadeNaoEncontradaException('Ponto de aplicação "$id" não encontrado.');
    }
    return index;
  }
}
