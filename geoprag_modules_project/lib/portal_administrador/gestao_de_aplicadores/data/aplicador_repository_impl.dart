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
      // TODO(GEOPRAG-42/69): `bairro`/`telefone`/`endereco` são campos
      // legados que não fazem parte do formulário de cadastro documentado
      // (ver "Regra de Negócio - Dados da Conta") — mantidos vazios aqui até
      // a divergência de modelo ser resolvida nessas issues.
      id: (mockApplicators.length + 1).toString(),
      nome: nome,
      bairro: '',
      status: UsuarioStatus.ativo,
      dataCriacao: DateTime.now(),
      email: email,
      cpf: cpf,
      dataNascimento: dataNascimento,
      sexo: sexo,
      cep: cep,
      telefone: '',
      endereco: '',
    );
    mockApplicators.add(aplicador);
    return aplicador;
  }
}
