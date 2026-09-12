import '../core/solicitacao_redefinicao.dart';
import '../core/solicitacao_redefinicao_repository.dart';
import 'mock_solicitacoes_redefinicao.dart';

/// Implementação de [SolicitacaoRedefinicaoRepository] com fonte remota
/// mockada (`mockSolicitacaoRedefinicaoPendente`) e estado em memória.
///
/// TODO(GEOPRAG-24): substituir por implementação real assim que o contrato
/// de endpoints de autenticação (GEOPRAG-22) for fechado com o backend.
class SolicitacaoRedefinicaoRepositoryImpl
    implements SolicitacaoRedefinicaoRepository {
  SolicitacaoRedefinicao _atual = mockSolicitacaoRedefinicaoPendente;

  @override
  Future<SolicitacaoRedefinicao> buscarPendente() async => _atual;

  @override
  Future<SolicitacaoRedefinicao> autorizar(String id) async {
    _atual = _atual.copyWith(status: StatusSolicitacaoRedefinicao.autorizado);
    return _atual;
  }

  @override
  Future<SolicitacaoRedefinicao> negar(String id) async {
    _atual = _atual.copyWith(status: StatusSolicitacaoRedefinicao.negado);
    return _atual;
  }
}
