import 'aplicador.dart';
import 'atuacao_aplicador.dart';

/// Contrato de acesso aos dados de Aplicadores (voluntários cadastrados) do
/// Portal Administrador.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class AplicadorRepository {
  Future<List<Aplicador>> listar();
  Future<Aplicador> buscarPorId(String id);
  Future<List<AtuacaoAplicador>> buscarHistorico(String aplicadorId);

  /// Cria o vínculo de um novo Aplicador (GEOPRAG-65) — permitido a
  /// Administrador e Sub-Administrador (ver "Regra de Negócio - Cadastro e
  /// Acesso do Aplicador"). O cadastro nasce sempre `Ativo`.
  ///
  /// Endereço de residência (`cep`, `rua`, `numero`, `bairro`, `cidade`,
  /// `uf`) é obrigatório para o Aplicador (GEOPRAG-70); `complemento`
  /// continua opcional.
  Future<Aplicador> criar({
    required String email,
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String sexo,
    required String cep,
    required String rua,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String uf,
  });

  /// Ativa o cadastro do Aplicador. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir.
  Future<void> ativar(String id);

  /// Desativa o cadastro do Aplicador. Lança
  /// `EntidadeNaoEncontradaException` se o [id] não existir.
  Future<void> desativar(String id);
}
