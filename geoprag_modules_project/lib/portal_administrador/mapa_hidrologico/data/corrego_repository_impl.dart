import '../core/bairro.dart';
import '../core/corrego.dart';
import '../core/corrego_repository.dart';
import 'mock_bairros.dart';
import 'mock_corregos.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [CorregoRepository] com fonte remota mockada
/// (`mockStreams`/`mockBairros`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class CorregoRepositoryImpl implements CorregoRepository {
  @override
  Future<List<Corrego>> listar() async => mockStreams;

  @override
  Future<Corrego> buscarPorId(String id) async {
    return mockStreams.firstWhere(
      (corrego) => corrego.id == id,
      orElse: () =>
          throw EntidadeNaoEncontradaException('Córrego "$id" não encontrado.'),
    );
  }

  @override
  Future<List<Bairro>> listarBairros() async => mockBairros;

  @override
  Future<Bairro> buscarBairroPorId(String id) async {
    return mockBairros.firstWhere(
      (bairro) => bairro.id == id,
      orElse: () =>
          throw EntidadeNaoEncontradaException('Bairro "$id" não encontrado.'),
    );
  }

  @override
  Future<List<Corrego>> listarCorregosDoBairro(String bairroId) async {
    final bairro = await buscarBairroPorId(bairroId);
    return mockStreams
        .where((corrego) => bairro.corregoIds.contains(corrego.id))
        .toList();
  }
}
