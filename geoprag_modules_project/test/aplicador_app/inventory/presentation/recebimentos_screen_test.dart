import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimento_view_model.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimentos_cubit.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimentos_screen.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/recebimentos_state.dart';

class MockRecebimentosCubit extends MockCubit<RecebimentosState>
    implements RecebimentosCubit {}

void main() {
  late MockRecebimentosCubit cubit;

  Widget wrap(RecebimentosState state) {
    cubit = MockRecebimentosCubit();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: BlocProvider<RecebimentosCubit>.value(
        value: cubit,
        child: const RecebimentosScreen(),
      ),
    );
  }

  group('RecebimentosScreen', () {
    testWidgets('mostra spinner enquanto carrega', (tester) async {
      await tester.pumpWidget(wrap(const RecebimentosLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      await tester.pumpWidget(wrap(const RecebimentosError('falha de rede')));

      expect(
        find.text('Não foi possível carregar os recebimentos: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('mostra o empty-state quando não há recebimentos', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const RecebimentosLoaded([])));

      expect(find.text('Nenhum recebimento pendente.'), findsOneWidget);
    });

    testWidgets('renderiza cada recebimento como card', (tester) async {
      await tester.pumpWidget(
        wrap(
          const RecebimentosLoaded([
            RecebimentoResumoViewModel(
              id: 'r1',
              produtoNome: 'BTI Líquido',
              quantidadeDescricao: '5 Litros',
              enviadoPorDescricao: 'Enviado por: Carlos (Distribuidor)',
              dataDescricao: 'Data: 01/06/2026',
            ),
          ]),
        ),
      );

      expect(find.text('BTI Líquido - 5 Litros'), findsOneWidget);
      expect(
        find.text('Enviado por: Carlos (Distribuidor)\nData: 01/06/2026'),
        findsOneWidget,
      );
    });
  });
}
