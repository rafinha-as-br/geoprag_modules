import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco_repository.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/criar_denuncia_de_foco_cubit.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaDeFocoRepository extends Mock
    implements DenunciaDeFocoRepository {}

void main() {
  setUpAll(() => registerFallbackValue(NivelInfestacaoFoco.medio));

  late MockDenunciaDeFocoRepository repository;
  late CriarDenunciaDeFocoCubit cubit;

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CriarDenunciaDeFocoCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CriarDenunciaDeFocoCubit>(),
      ),
    ),
  );

  setUp(() {
    repository = MockDenunciaDeFocoRepository();
    cubit = CriarDenunciaDeFocoCubit(repository);
  });

  /// A tela tem múltiplos campos (dropdown + 2 textos, um multilinha) e não
  /// cabe na altura padrão de teste (600px) por pouco — amplia a superfície
  /// para o botão de envio ficar alcançável sem rolagem.
  Future<void> ampliarSuperficie(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('CriarDenunciaDeFocoCubit', () {
    testWidgets(
      'submete o formulário e persiste a denúncia de verdade',
      (tester) async {
        when(
          () => repository.registrar(
            nivelInfestacao: NivelInfestacaoFoco.medio,
            localDescricao: 'Perto da ponte',
            observacoes: null,
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

        expect(find.text('Denúncia enviada com sucesso!'), findsOneWidget);
        verify(
          () => repository.registrar(
            nivelInfestacao: NivelInfestacaoFoco.medio,
            localDescricao: 'Perto da ponte',
            observacoes: null,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'envia observações quando preenchidas',
      (tester) async {
        when(
          () => repository.registrar(
            nivelInfestacao: NivelInfestacaoFoco.medio,
            localDescricao: 'Perto da ponte',
            observacoes: 'Água parada visível',
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
        final campos = find.byType(TextFormField);
        await tester.enterText(campos.at(0), 'Perto da ponte');
        await tester.enterText(campos.at(1), 'Água parada visível');

        await tester.tap(find.text('Enviar Denúncia'));
        await tester.pumpAndSettle();

        verify(
          () => repository.registrar(
            nivelInfestacao: NivelInfestacaoFoco.medio,
            localDescricao: 'Perto da ponte',
            observacoes: 'Água parada visível',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'não submete sem preencher a descrição do local',
      (tester) async {
        await ampliarSuperficie(tester);
        await tester.pumpWidget(wrap());

        await tester.tap(find.text('Enviar Denúncia'));
        await tester.pump();

        verifyNever(
          () => repository.registrar(
            nivelInfestacao: any(named: 'nivelInfestacao'),
            localDescricao: any(named: 'localDescricao'),
            observacoes: any(named: 'observacoes'),
          ),
        );
        expect(find.text('Informe a descrição do local.'), findsOneWidget);
      },
    );

    testWidgets(
      'emite mensagem genérica quando a exceção é inesperada '
      '(nunca expõe a exceção bruta ao usuário)',
      (tester) async {
        when(
          () => repository.registrar(
            nivelInfestacao: any(named: 'nivelInfestacao'),
            localDescricao: any(named: 'localDescricao'),
            observacoes: any(named: 'observacoes'),
          ),
        ).thenThrow(Exception('offline'));

        await ampliarSuperficie(tester);
        await tester.pumpWidget(wrap());
        await tester.enterText(
          find.byType(TextFormField).first,
          'Perto da ponte',
        );

        await tester.tap(find.text('Enviar Denúncia'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Exception'), findsNothing);
        expect(
          find.text('Não foi possível carregar os dados. Tente novamente.'),
          findsOneWidget,
        );
      },
    );
  });
}
