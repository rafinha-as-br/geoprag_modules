import '../core/ponto_de_aplicacao.dart';
import '../core/ponto_de_aplicacao_repository.dart';
import 'mock_pontos_de_aplicacao.dart';

/// Implementação de [PontoDeAplicacaoRepository] com fonte remota mockada
/// (`mockPontoDeAplicacaoAtual`/`mockCapturaLocalizacaoAtual`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class PontoDeAplicacaoRepositoryImpl implements PontoDeAplicacaoRepository {
  @override
  Future<PontoDeAplicacao> buscarAtual() async => mockPontoDeAplicacaoAtual;

  @override
  Future<PontoDeAplicacao> capturarLocalizacaoAtual() async =>
      mockCapturaLocalizacaoAtual;

  @override
  Future<void> marcarPontoInicial(PontoDeAplicacao ponto) async {
    // TODO(GEOPRAG-24): enviar `ponto` para validação da prefeitura via API
    // real assim que o contrato de endpoints deste módulo for validado.
  }
}
