import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/dashboard_de_focos_screen.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/denuncia_de_foco_view_model.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/denuncias_de_foco_cubit.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/denuncias_de_foco_state.dart';

class MockDenunciasDeFocoCubit extends MockCubit<DenunciasDeFocoState>
    implements DenunciasDeFocoCubit {}

void main() {
  late MockDenunciasDeFocoCubit cubit;

  Widget wrap(DenunciasDeFocoState state) {
    cubit = MockDenunciasDeFocoCubit();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: BlocProvider<DenunciasDeFocoCubit>.value(
        value: cubit,
        child: const DashboardDeFocosScreen(),
      ),
    );
  }

  group('DashboardDeFocosScreen', () {
    testWidgets('mostra spinner enquanto carrega', (tester) async {
      await tester.pumpWidget(wrap(const DenunciasDeFocoLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      await tester.pumpWidget(
        wrap(const DenunciasDeFocoError('falha de rede')),
      );

      expect(
        find.text('Não foi possível carregar suas denúncias: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('mostra o empty-state quando não há denúncias', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const DenunciasDeFocoLoaded([])));

      expect(find.text('Nenhuma denúncia registrada.'), findsOneWidget);
    });

    testWidgets('renderiza cada denúncia como card e o bottom nav', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const DenunciasDeFocoLoaded([
            DenunciaDeFocoViewModel(
              id: 'd1',
              titulo: 'Foco Alto - Rua das Flores, 123',
              statusLabel: 'Recebida',
              dataFormatada: '01/06/2026',
              atendida: false,
            ),
          ]),
        ),
      );

      expect(find.text('Foco Alto - Rua das Flores, 123'), findsOneWidget);
      expect(
        find.text('Status: Recebida\nData: 01/06/2026'),
        findsOneWidget,
      );
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
