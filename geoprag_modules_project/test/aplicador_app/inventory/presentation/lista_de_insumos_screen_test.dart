import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/insumo_view_model.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/inventario_cubit.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/inventario_state.dart';
import 'package:geoprag_modules/aplicador_app/inventory/presentation/lista_de_insumos_screen.dart';

class MockInventarioCubit extends MockCubit<InventarioState>
    implements InventarioCubit {}

void main() {
  late MockInventarioCubit cubit;

  Widget wrap(InventarioState state) {
    cubit = MockInventarioCubit();
    whenListen(cubit, Stream.value(state), initialState: state);
    return MaterialApp(
      home: BlocProvider<InventarioCubit>.value(
        value: cubit,
        child: const ListaDeInsumosScreen(),
      ),
    );
  }

  group('ListaDeInsumosScreen', () {
    testWidgets('mostra spinner enquanto carrega', (tester) async {
      await tester.pumpWidget(wrap(const InventarioLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra mensagem de erro amigável', (tester) async {
      await tester.pumpWidget(wrap(const InventarioError('falha de rede')));

      expect(
        find.text('Não foi possível carregar o inventário: falha de rede'),
        findsOneWidget,
      );
    });

    testWidgets('renderiza o estoque atual e o bottom nav', (tester) async {
      await tester.pumpWidget(
        wrap(
          const InventarioLoaded(
            EstoqueAtualViewModel(
              produtoNome: 'BTI Líquido',
              quantidadeFormatada: '10 Litros',
              atualizadoEmDescricao: 'Última atualização hoje',
              recebimentosPendentesCount: 2,
            ),
          ),
        ),
      );

      expect(find.text('10 Litros'), findsOneWidget);
      expect(
        find.text('BTI Líquido - Última atualização hoje'),
        findsOneWidget,
      );
      expect(find.text('2 produtos a caminho'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
