import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/core/aplicador_navigator.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco_repository.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/cadastro_do_foco_screen.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/criar_denuncia_de_foco_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaDeFocoRepository extends Mock
    implements DenunciaDeFocoRepository {}

class MockAplicadorNavigator extends Mock implements AplicadorNavigator {}

void main() {
  setUpAll(() => registerFallbackValue(NivelInfestacaoFoco.medio));

  late MockDenunciaDeFocoRepository repository;
  late MockAplicadorNavigator navigator;
  late CriarDenunciaDeFocoCubit cubit;

  Widget wrap() => MaterialApp(
    home: AplicadorNavigatorScope(
      navigator: navigator,
      child: BlocProvider<CriarDenunciaDeFocoCubit>.value(
        value: cubit,
        child: const CadastroDoFocoScreen(),
      ),
    ),
  );

  setUp(() {
    repository = MockDenunciaDeFocoRepository();
    navigator = MockAplicadorNavigator();
    cubit = CriarDenunciaDeFocoCubit(repository);
  });

  /// A tela (AppBar + formulário + botão Cancelar) não cabe na altura
  /// padrão de teste (600px) por pouco — amplia a superfície para o botão
  /// de envio ficar alcançável sem rolagem.
  Future<void> ampliarSuperficie(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('CadastroDoFocoScreen', () {
    testWidgets(
      'mostra o formulário completo com botão de envio e Cancelar',
      (tester) async {
        await ampliarSuperficie(tester);
        await tester.pumpWidget(wrap());

        expect(find.text('Nova Denúncia'), findsWidgets);
        expect(find.text('Enviar Denúncia'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.byType(DropdownButtonFormField<NivelInfestacaoFoco>), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
      },
    );

    testWidgets(
      'ao enviar com sucesso, navega para a listagem de denúncias',
      (tester) async {
        when(
          () => repository.registrar(
            nivelInfestacao: any(named: 'nivelInfestacao'),
            localDescricao: any(named: 'localDescricao'),
            observacoes: any(named: 'observacoes'),
          ),
        ).thenAnswer(
          (_) async => DenunciaDeFoco(
            id: '1',
            nivelInfestacao: NivelInfestacaoFoco.medio,
            localDescricao: 'Perto da ponte',
            status: StatusDenunciaDeFoco.recebida,
            dataRegistro: DateTime(2026, 8, 1),
          ),
        );

        await ampliarSuperficie(tester);
        await tester.pumpWidget(wrap());
        await tester.enterText(
          find.byType(TextFormField).first,
          'Perto da ponte',
        );

        await tester.tap(find.text('Enviar Denúncia'));
        await tester.pumpAndSettle();

        verify(() => navigator.toDenuncias()).called(1);
      },
    );

    testWidgets(
      'Cancelar chama o navigator sem enviar nada',
      (tester) async {
        await ampliarSuperficie(tester);
        await tester.pumpWidget(wrap());

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        verifyNever(
          () => repository.registrar(
            nivelInfestacao: any(named: 'nivelInfestacao'),
            localDescricao: any(named: 'localDescricao'),
            observacoes: any(named: 'observacoes'),
          ),
        );
        verify(() => navigator.back()).called(1);
      },
    );
  });
}
