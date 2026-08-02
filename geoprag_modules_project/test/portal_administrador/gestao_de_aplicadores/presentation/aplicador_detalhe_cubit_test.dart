import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/atuacao_aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/presentation/aplicador_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/presentation/aplicador_detalhe_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAplicadorRepository repository;

  final aplicador = Aplicador(
    id: '2',
    nome: 'Maria Souza',
    bairro: 'Poço Grande',
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 7, 1),
    email: 'maria.souza@email.com',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1992, 9, 3),
    sexo: 'Feminino',
    cep: '89222-000',
    telefone: '(47) 99999-9999',
    endereco: 'Rua Principal, 100 - Poço Grande',
  );

  const historico = [
    AtuacaoAplicador(
      tipo: AtuacaoAplicadorTipo.aplicacao,
      titulo: 'Aplicação Concluída',
      subtitulo: 'Córrego Gasparinho - 20/06/2026',
      valor: '50ml aplicados',
    ),
  ];

  setUp(() {
    repository = MockAplicadorRepository();
  });

  blocTest<AplicadorDetalheCubit, AplicadorDetalheState>(
    'emite [Loaded] com perfil e histórico do aplicador informado',
    setUp: () {
      when(
        () => repository.buscarPorId('2'),
      ).thenAnswer((_) async => aplicador);
      when(
        () => repository.buscarHistorico('2'),
      ).thenAnswer((_) async => historico);
    },
    build: () => AplicadorDetalheCubit(repository, '2'),
    expect: () => [
      isA<AplicadorDetalheLoaded>()
          .having((s) => s.aplicador.nome, 'aplicador.nome', 'Maria Souza')
          .having(
            (s) => s.aplicador.historico,
            'aplicador.historico',
            hasLength(1),
          ),
    ],
    verify: (_) {
      verify(() => repository.buscarPorId('2')).called(1);
      verify(() => repository.buscarHistorico('2')).called(1);
    },
  );

  blocTest<AplicadorDetalheCubit, AplicadorDetalheState>(
    'emite [Error] com mensagem amigável quando o id não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.buscarPorId('inexistente')).thenThrow(
        const EntidadeNaoEncontradaException(
          'Aplicador "inexistente" não encontrado.',
        ),
      );
    },
    build: () => AplicadorDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<AplicadorDetalheError>().having(
        (s) => s.message,
        'message',
        'Aplicador "inexistente" não encontrado.',
      ),
    ],
  );

  blocTest<AplicadorDetalheCubit, AplicadorDetalheState>(
    'emite [Error] com mensagem genérica (e loga) quando a exceção é '
    'inesperada, sem vazar detalhe técnico',
    setUp: () {
      when(
        () => repository.buscarPorId('inexistente'),
      ).thenThrow(Exception('offline'));
    },
    build: () => AplicadorDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<AplicadorDetalheError>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
