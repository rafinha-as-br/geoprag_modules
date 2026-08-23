import '../core/denuncia_de_foco.dart';
import '../core/denuncia_de_foco_repository.dart';
import 'mock_denuncias_de_foco.dart';

/// Implementação de [DenunciaDeFocoRepository] com fonte remota mockada
/// (`mockDenunciasDeFoco`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class DenunciaDeFocoRepositoryImpl implements DenunciaDeFocoRepository {
  @override
  Future<List<DenunciaDeFoco>> listar() async => mockDenunciasDeFoco;

  @override
  Future<DenunciaDeFoco> registrar({
    required NivelInfestacaoFoco nivelInfestacao,
    required String localDescricao,
    String? observacoes,
  }) async {
    final novaDenuncia = DenunciaDeFoco(
      id: '${mockDenunciasDeFoco.length + 1}',
      nivelInfestacao: nivelInfestacao,
      localDescricao: localDescricao,
      status: StatusDenunciaDeFoco.recebida,
      dataRegistro: DateTime.now(),
      observacoes: observacoes,
    );
    mockDenunciasDeFoco.insert(0, novaDenuncia);
    return novaDenuncia;
  }
}
