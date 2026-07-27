import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/aplicacao_atual_cubit.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/aplicacao_atual_state.dart';
import 'package:mocktail/mocktail.dart';

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
        StateError('Nenhuma aplicação em andamento para o aplicador "5".'),
      );
    },
    build: () => AplicacaoAtualCubit(repository, '5'),
    expect: () => [
      isA<AplicacaoAtualError>().having(
        (s) => s.message,
        'message',
        isNot(contains('StateError')),
      ),
    ],
  );
}
