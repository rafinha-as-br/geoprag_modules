import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/core/resumo_geral.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/core/resumo_geral_repository.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/presentation/dashboard_geral_cubit.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/presentation/dashboard_geral_state.dart';
import 'package:mocktail/mocktail.dart';

class MockResumoGeralRepository extends Mock implements ResumoGeralRepository {}

void main() {
  late MockResumoGeralRepository repository;

  const resumo = ResumoGeral(
    lotesAVencer: 2,
    corregosComAplicacaoAtrasada: 4,
    denunciasAbertas: 12,
    atualizacoesEstoque: [],
    ultimasAplicacoes: [],
    focosRecentes: [],
  );

  setUp(() {
    repository = MockResumoGeralRepository();
  });

  blocTest<DashboardGeralCubit, DashboardGeralState>(
    'emite [Loaded] com o resumo mapeado para ViewModel',
    setUp: () {
      when(() => repository.buscar()).thenAnswer((_) async => resumo);
    },
    build: () => DashboardGeralCubit(repository),
    expect: () => [
      isA<DashboardGeralLoaded>().having(
        (s) => s.resumo.denunciasAbertasTotal,
        'resumo.denunciasAbertasTotal',
        '12',
      ),
    ],
  );

  blocTest<DashboardGeralCubit, DashboardGeralState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.buscar()).thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => DashboardGeralCubit(repository),
    expect: () => [
      isA<DashboardGeralError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
