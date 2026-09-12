import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairro_view_model.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairros_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairros_state.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/mapa_de_bairros_screen.dart';
import 'package:geoprag_modules/src/widgets/base_card_list_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockBairrosCubit extends MockCubit<BairrosState>
    implements BairrosCubit {}

class MockAdminNavigator extends Mock implements AdminNavigator {}

void main() {
  late MockBairrosCubit cubit;

  Widget wrap(BairrosState state) {
    cubit = MockBairrosCubit();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<BairrosCubit>.value(value: cubit),
          BlocProvider<AdminSessionCubit>(create: (_) => AdminSessionCubit()),
        ],
        child: AdminNavigatorScope(
          navigator: MockAdminNavigator(),
          child: const MapaDeBairrosScreen(),
        ),
      ),
    );
  }

  group('MapaDeBairrosScreen', () {
    testWidgets('mostra spinner enquanto carrega', (tester) async {
      await tester.pumpWidget(wrap(const BairrosLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      await tester.pumpWidget(wrap(const BairrosError('falha de rede')));

      expect(
        find.text('Não foi possível carregar os bairros: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('mostra o empty-state quando não há bairros', (tester) async {
      await tester.pumpWidget(wrap(const BairrosLoaded([])));

      expect(find.text('Nenhum bairro encontrado.'), findsOneWidget);
    });

    testWidgets('renderiza cada bairro como ListTile', (tester) async {
      await tester.pumpWidget(
        wrap(
          const BairrosLoaded([
            BairroResumoViewModel(
              id: 'b1',
              nome: 'Belchior',
              status: 'atrasado',
              diasSemAplicacao: 12,
            ),
          ]),
        ),
      );

      expect(find.text('Belchior'), findsOneWidget);
      expect(find.text('12 dias sem aplicação'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BaseCardListScreen<BairroResumoViewModel>),
          matching: find.byType(ListTile),
        ),
        findsOneWidget,
      );
    });
  });
}
