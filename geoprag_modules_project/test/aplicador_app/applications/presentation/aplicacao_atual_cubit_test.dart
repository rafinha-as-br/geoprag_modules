import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/aplicacao_atual_cubit.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/aplicacao_atual_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';

class MockAplicacaoRepository extends Mock implements AplicacaoRepository {}

void main() {
  late MockAplicacaoRepository repository;

  final aplicacao = Aplicacao(
    id: 'a1',
    data: DateTime(2026, 5, 3),
    lat: -26.9328,
    lng: -48.9554,
    dosagem: 10.5,
    aplicadorId: '1',
  );

  setUp(() {
    repository = MockAplicacaoRepository();
  });

  blocTest<AplicacaoAtualCubit, AplicacaoAtualState>(
    'emite [Loaded] com a aplicação do aplicadorId informado ao construtor',
    setUp: () {
      when(() => repository.buscarAtual('1')).thenAnswer((_) async => aplicacao);
    },
    build: () => AplicacaoAtualCubit(repository, '1'),
    expect: () => [
      isA<AplicacaoAtualLoaded>().having(
        (s) => s.aplicacao.id,
        'aplicacao.id',
        'a1',
      ),
    ],
    verify: (_) {
      verify(() => repository.buscarAtual('1')).called(1);
    },
  );

  blocTest<AplicacaoAtualCubit, AplicacaoAtualState>(
    'emite [Error] com mensagem amigável quando não há aplicação em andamento '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.buscarAtual('5')).thenThrow(
        const EntidadeNaoEncontradaException(
          'Nenhuma aplicação em andamento para o aplicador "5".',
        ),
      );
    },
    build: () => AplicacaoAtualCubit(repository, '5'),
    expect: () => [
      isA<AplicacaoAtualError>().having(
        (s) => s.message,
        'message',
        'Nenhuma aplicação em andamento para o aplicador "5".',
      ),
    ],
  );

  blocTest<AplicacaoAtualCubit, AplicacaoAtualState>(
    'emite [Error] com mensagem genérica (e loga) quando a exceção é '
    'inesperada, sem vazar detalhe técnico',
    setUp: () {
      when(() => repository.buscarAtual('9')).thenThrow(Exception('falha de rede'));
    },
    build: () => AplicacaoAtualCubit(repository, '9'),
    expect: () => [
      isA<AplicacaoAtualError>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
