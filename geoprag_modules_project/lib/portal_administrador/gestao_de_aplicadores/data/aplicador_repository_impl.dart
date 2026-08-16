import '../core/aplicador.dart';
import '../core/aplicador_repository.dart';
import '../core/atuacao_aplicador.dart';
import 'mock_aplicadores.dart';
import 'mock_atuacoes_aplicador.dart';
import '../../../src/entities/usuario.dart';
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
      orElse: () => throw EntidadeNaoEncontradaException(
        'Aplicador "$id" não encontrado.',
      ),
    );
  }

  @override
  Future<List<AtuacaoAplicador>> buscarHistorico(String aplicadorId) async {
    return mockAtuacoesAplicador[aplicadorId] ?? const [];
  }

  @override
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
  }) async {
    final jaExiste = mockApplicators.any(
      (aplicador) => aplicador.email == email,
    );
    if (jaExiste) {
      throw EntidadeDuplicadaException(
        'Já existe um aplicador cadastrado com o e-mail "$email".',
      );
    }

    final aplicador = Aplicador(
      // TODO(GEOPRAG-42): `telefone` é um campo legado que não faz parte do
      // formulário de cadastro documentado (ver "Regra de Negócio - Dados
      // da Conta") — mantido vazio aqui até a divergência de modelo ser
      // resolvida nessa issue.
      id: (mockApplicators.length + 1).toString(),
      nome: nome,
      status: UsuarioStatus.ativo,
      dataCriacao: DateTime.now(),
      email: email,
      cpf: cpf,
      dataNascimento: dataNascimento,
      sexo: sexo,
      cep: cep,
      rua: rua,
      numero: numero,
      complemento: complemento,
      bairro: bairro,
      cidade: cidade,
      uf: uf,
      telefone: '',
    );
    mockApplicators.add(aplicador);
    return aplicador;
  }

  @override
  Future<void> ativar(String id) async =>
      _atualizarStatus(id, UsuarioStatus.ativo);

  @override
  Future<void> desativar(String id) async =>
      _atualizarStatus(id, UsuarioStatus.desativado);

  void _atualizarStatus(String id, UsuarioStatus status) {
    final index = mockApplicators.indexWhere((aplicador) => aplicador.id == id);
    if (index == -1) {
      throw EntidadeNaoEncontradaException('Aplicador "$id" não encontrado.');
    }
    mockApplicators[index] = mockApplicators[index].copyWith(
      status: status,
      dataDesativacao: status == UsuarioStatus.desativado
          ? DateTime.now()
          : mockApplicators[index].dataDesativacao,
    );
  }
}
