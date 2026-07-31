import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/criar_administrador_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/criar_administrador_state.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAdministradorRepository extends Mock
    implements AdministradorRepository {}

void main() {
  late MockAdministradorRepository repository;

  setUp(() {
    repository = MockAdministradorRepository();
  });

  final dataNascimento = DateTime(1990, 1, 1);

  blocTest<CriarAdministradorCubit, CriarAdministradorState>(
    'emite [Salvando, Sucesso] quando o repositório cria a conta',
    setUp: () {
      when(
        () => repository.criar(
          email: 'nova@gaspar.sc.gov.br',
          nome: 'Nova Conta',
          cpf: '123.456.789-00',
          dataNascimento: dataNascimento,
          sexo: 'Feminino',
        ),
      ).thenAnswer(
        (_) async => AdminAccount(
          email: 'nova@gaspar.sc.gov.br',
          nome: 'Nova Conta',
          cpf: '123.456.789-00',
          dataNascimento: dataNascimento,
          sexo: 'Feminino',
          dataCriacao: DateTime(2026, 1, 1),
          role: AdminRole.subAdministrador,
        ),
      );
    },
    build: () => CriarAdministradorCubit(repository),
    act: (cubit) => cubit.submit(
      email: 'nova@gaspar.sc.gov.br',
      nome: 'Nova Conta',
      cpf: '123.456.789-00',
      dataNascimento: dataNascimento,
      sexo: 'Feminino',
    ),
    expect: () => [
      isA<CriarAdministradorSalvando>(),
      isA<CriarAdministradorSucesso>().having(
        (s) => s.conta.role,
        'conta.role',
        AdminRole.subAdministrador,
      ),
    ],
  );

  blocTest<CriarAdministradorCubit, CriarAdministradorState>(
    'emite [Salvando, Erro] com a mensagem amigável quando o e-mail já existe',
    setUp: () {
      when(
        () => repository.criar(
          email: 'duplicado@gaspar.sc.gov.br',
          nome: 'X',
          cpf: '123.456.789-00',
          dataNascimento: dataNascimento,
          sexo: 'Feminino',
        ),
      ).thenThrow(
        const EntidadeDuplicadaException(
          'Já existe um administrador cadastrado com o e-mail "duplicado@gaspar.sc.gov.br".',
        ),
      );
    },
    build: () => CriarAdministradorCubit(repository),
    act: (cubit) => cubit.submit(
      email: 'duplicado@gaspar.sc.gov.br',
      nome: 'X',
      cpf: '123.456.789-00',
      dataNascimento: dataNascimento,
      sexo: 'Feminino',
    ),
    expect: () => [
      isA<CriarAdministradorSalvando>(),
      isA<CriarAdministradorErro>().having(
        (s) => s.message,
        'message',
        contains('Já existe'),
      ),
    ],
  );

  blocTest<CriarAdministradorCubit, CriarAdministradorState>(
    'emite [Salvando, Erro] com mensagem genérica quando a exceção é inesperada '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.criar(
          email: 'instavel@gaspar.sc.gov.br',
          nome: 'Y',
          cpf: '123.456.789-00',
          dataNascimento: dataNascimento,
          sexo: 'Feminino',
        ),
      ).thenThrow(Exception('timeout'));
    },
    build: () => CriarAdministradorCubit(repository),
    act: (cubit) => cubit.submit(
      email: 'instavel@gaspar.sc.gov.br',
      nome: 'Y',
      cpf: '123.456.789-00',
      dataNascimento: dataNascimento,
      sexo: 'Feminino',
    ),
    expect: () => [
      isA<CriarAdministradorSalvando>(),
      isA<CriarAdministradorErro>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
