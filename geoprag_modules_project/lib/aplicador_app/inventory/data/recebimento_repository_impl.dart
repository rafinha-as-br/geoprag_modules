import '../core/recebimento.dart';
import '../core/recebimento_repository.dart';
import 'mock_recebimentos.dart';
import '../../../src/errors/app_exceptions.dart';

/// Implementação de [RecebimentoRepository] com fonte remota mockada
/// (`mockRecebimentos`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class RecebimentoRepositoryImpl implements RecebimentoRepository {
  @override
  Future<List<Recebimento>> listarPendentes() async {
    return mockRecebimentos
        .where((recebimento) => recebimento.status == RecebimentoStatus.pendente)
        .toList();
  }

  @override
  Future<Recebimento> buscarPorId(String id) async {
    return mockRecebimentos.firstWhere(
      (recebimento) => recebimento.id == id,
      orElse: () => throw EntidadeNaoEncontradaException('Recebimento "$id" não encontrado.'),
    );
  }

  @override
  Future<void> confirmar(String id) async {
    final index = mockRecebimentos.indexWhere(
      (recebimento) => recebimento.id == id,
    );
    if (index == -1) {
      throw EntidadeNaoEncontradaException('Recebimento "$id" não encontrado.');
    }
    mockRecebimentos[index] = mockRecebimentos[index].copyWith(
      status: RecebimentoStatus.confirmado,
    );
  }
}
