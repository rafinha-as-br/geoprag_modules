import '../core/aplicador.dart';
import '../core/aplicador_repository.dart';
import '../core/atuacao_aplicador.dart';
import 'mock_aplicadores.dart';
import 'mock_atuacoes_aplicador.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [AplicadorRepository] com fonte remota mockada
/// (`mockApplicators`/`mockAtuacoesAplicador`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AplicadorRepositoryImpl implements AplicadorRepository {
  @override
  Future<List<Aplicador>> listar() async => mockApplicators;

  @override
  Future<Aplicador> buscarPorId(String id) async {
    return mockApplicators.firstWhere(
      (aplicador) => aplicador.id == id,
      orElse: () => throw EntidadeNaoEncontradaException('Aplicador "$id" não encontrado.'),
    );
  }

  @override
  Future<List<AtuacaoAplicador>> buscarHistorico(String aplicadorId) async {
    return mockAtuacoesAplicador[aplicadorId] ?? const [];
  }
}
