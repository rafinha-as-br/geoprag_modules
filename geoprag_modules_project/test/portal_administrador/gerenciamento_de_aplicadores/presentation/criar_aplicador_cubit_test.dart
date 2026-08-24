import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/presentation/criar_aplicador_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/presentation/criar_aplicador_state.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAplicadorRepository repository;

  setUp(() {
    repository = MockAplicadorRepository();
  });

  final dataNascimento = DateTime(1990, 1, 1);

  blocTest<CriarAplicadorCubit, CriarAplicadorState>(
    'emite [Salvando, Sucesso] com a senha gerada quando o repositório cria o cadastro',
    setUp: () {
      when(
        () => repository.criar(
          email: 'novo@gaspar.sc.gov.br',
          nome: 'Nova Conta',
          cpf: '123.456.789-00',
          dataNascimento: dataNascimento,
          sexo: 'Feminino',
          cep: '89100-000',
          rua: 'Rua Nova',
          numero: '10',
          bairro: 'Centro',
          cidade: 'Gaspar',
          uf: 'SC',
        ),
      ).thenAnswer(
        (_) async => Aplicador(
          id: '6',
          nome: 'Nova Conta',
          status: UsuarioStatus.ativo,
          dataCriacao: DateTime(2026, 1, 1),
          email: 'novo@gaspar.sc.gov.br',
          cpf: '123.456.789-00',
          dataNascimento: dataNascimento,
          sexo: 'Feminino',
          cep: '89100-000',
          rua: 'Rua Nova',
          numero: '10',
          bairro: 'Centro',
          cidade: 'Gaspar',
          uf: 'SC',
          telefone: '',
        ),
      );
    },
    build: () => CriarAplicadorCubit(repository),
    act: (cubit) => cubit.submit(
      email: 'novo@gaspar.sc.gov.br',
      nome: 'Nova Conta',
      cpf: '123.456.789-00',
      dataNascimento: dataNascimento,
      sexo: 'Feminino',
      cep: '89100-000',
      rua: 'Rua Nova',
      numero: '10',
      bairro: 'Centro',
      cidade: 'Gaspar',
      uf: 'SC',
    ),
    expect: () => [
      isA<CriarAplicadorSalvando>(),
      isA<CriarAplicadorSucesso>()
          .having(
            (s) => s.aplicador.email,
            'aplicador.email',
            'novo@gaspar.sc.gov.br',
          )
          .having((s) => s.senhaGerada, 'senhaGerada', '01011990nc#'),
    ],
  );

  blocTest<CriarAplicadorCubit, CriarAplicadorState>(
    'emite [Salvando, Erro] com a mensagem amigável quando o e-mail já existe',
    setUp: () {
      when(
        () => repository.criar(
          email: 'duplicado@gaspar.sc.gov.br',
          nome: 'X',
          cpf: '123.456.789-00',
          dataNascimento: dataNascimento,
          sexo: 'Feminino',
          cep: '89100-000',
          rua: 'Rua Nova',
          numero: '10',
          bairro: 'Centro',
          cidade: 'Gaspar',
          uf: 'SC',
        ),
      ).thenThrow(
        const EntidadeDuplicadaException(
          'Já existe um aplicador cadastrado com o e-mail "duplicado@gaspar.sc.gov.br".',
        ),
      );
    },
    build: () => CriarAplicadorCubit(repository),
    act: (cubit) => cubit.submit(
      email: 'duplicado@gaspar.sc.gov.br',
      nome: 'X',
      cpf: '123.456.789-00',
      dataNascimento: dataNascimento,
      sexo: 'Feminino',
      cep: '89100-000',
      rua: 'Rua Nova',
      numero: '10',
      bairro: 'Centro',
      cidade: 'Gaspar',
      uf: 'SC',
    ),
    expect: () => [
      isA<CriarAplicadorSalvando>(),
      isA<CriarAplicadorErro>().having(
        (s) => s.message,
        'message',
        contains('Já existe'),
      ),
    ],
  );

  blocTest<CriarAplicadorCubit, CriarAplicadorState>(
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
          cep: '89100-000',
          rua: 'Rua Nova',
          numero: '10',
          bairro: 'Centro',
          cidade: 'Gaspar',
          uf: 'SC',
        ),
      ).thenThrow(Exception('timeout'));
    },
    build: () => CriarAplicadorCubit(repository),
    act: (cubit) => cubit.submit(
      email: 'instavel@gaspar.sc.gov.br',
      nome: 'Y',
      cpf: '123.456.789-00',
      dataNascimento: dataNascimento,
      sexo: 'Feminino',
      cep: '89100-000',
      rua: 'Rua Nova',
      numero: '10',
      bairro: 'Centro',
      cidade: 'Gaspar',
      uf: 'SC',
    ),
    expect: () => [
      isA<CriarAplicadorSalvando>(),
      isA<CriarAplicadorErro>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
