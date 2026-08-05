import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/data/aplicador_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/data/mock_aplicadores.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AplicadorRepositoryImpl repository;

  setUp(() {
    repository = AplicadorRepositoryImpl();
  });

  test('listar retorna todos os aplicadores mockados', () async {
    final result = await repository.listar();
    expect(result.length, mockApplicators.length);
  });

  test('buscarPorId retorna o aplicador correspondente', () async {
    final result = await repository.buscarPorId('2');
    expect(result.nome, 'Maria Souza');
  });

  test(
    'buscarPorId lança EntidadeNaoEncontradaException quando o id não existe',
    () {
      expect(
        () => repository.buscarPorId('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    },
  );

  test(
    'buscarHistorico retorna o histórico de atuações do aplicador conhecido',
    () async {
      final result = await repository.buscarHistorico('2');
      expect(result, hasLength(2));
    },
  );

  test(
    'buscarHistorico retorna lista vazia quando o aplicador não tem histórico mockado',
    () async {
      final result = await repository.buscarHistorico('1');
      expect(result, isEmpty);
    },
  );

  test('criar adiciona um novo aplicador ativo à lista', () async {
    final totalAntes = mockApplicators.length;
    final novo = await repository.criar(
      email: 'novo.criar@email.com',
      nome: 'Novo Criar',
      cpf: '999.999.999-99',
      dataNascimento: DateTime(1993, 5, 20),
      sexo: 'Feminino',
      cep: '89100-000',
      rua: 'Rua Nova',
      numero: '10',
      bairro: 'Centro',
      cidade: 'Gaspar',
      uf: 'SC',
    );

    expect(novo.email, 'novo.criar@email.com');
    expect(novo.ativo, isTrue);
    expect(mockApplicators.length, totalAntes + 1);
  });

  test(
    'criar lança EntidadeDuplicadaException quando o e-mail já está cadastrado',
    () {
      expect(
        () => repository.criar(
          email: 'maria.souza@email.com',
          nome: 'Outra Maria',
          cpf: '888.888.888-88',
          dataNascimento: DateTime(1993, 5, 20),
          sexo: 'Feminino',
          cep: '89100-000',
          rua: 'Rua Nova',
          numero: '10',
          bairro: 'Centro',
          cidade: 'Gaspar',
          uf: 'SC',
        ),
        throwsA(isA<EntidadeDuplicadaException>()),
      );
    },
  );
}
