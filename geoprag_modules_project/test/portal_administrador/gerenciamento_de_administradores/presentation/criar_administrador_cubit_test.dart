import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/criar_administrador_cubit.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_data_nascimento_input.dart';
import 'package:geoprag_modules/src/widgets/geoprag_sexo_input.dart';
import 'package:mocktail/mocktail.dart';

class MockAdministradorRepository extends Mock
    implements AdministradorRepository {}

void main() {
  late MockAdministradorRepository repository;
  late CriarAdministradorCubit cubit;

  final dataNascimento = DateTime(1990, 1, 1);

  AdminAccount novaConta() => AdminAccount(
    email: 'nova@gaspar.sc.gov.br',
    nome: 'Nova Conta',
    cpf: '123.456.789-00',
    dataNascimento: dataNascimento,
    sexo: 'Feminino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.subAdministrador,
  );

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CriarAdministradorCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CriarAdministradorCubit>(),
      ),
    ),
  );

  setUp(() {
    repository = MockAdministradorRepository();
    cubit = CriarAdministradorCubit(repository);
  });

  /// O formulário (5 campos) não cabe na altura padrão de teste (600px) por
  /// pouco — em vez de rolar até o botão, o que disputava o toque com a
  /// scrollbar interativa do template, amplia a superfície para caber tudo
  /// sem rolagem.
  Future<void> ampliarSuperficie(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  /// Stub genérico de [AdministradorRepository.criar] (qualquer argumento) —
  /// usado pelos testes que só se importam com o que a submissão faz com a
  /// resposta, não com quais dados foram enviados.
  void quandoCriarQualquer(Answer<Future<AdminAccount>> resposta) {
    when(
      () => repository.criar(
        email: any(named: 'email'),
        nome: any(named: 'nome'),
        cpf: any(named: 'cpf'),
        dataNascimento: any(named: 'dataNascimento'),
        sexo: any(named: 'sexo'),
      ),
    ).thenAnswer(resposta);
  }

  /// Preenche todos os campos obrigatórios do formulário na tela pumpada por
  /// [wrap]. Sexo e data de nascimento são disparados diretamente pelo
  /// `onChanged` do widget correspondente — mesmo caminho que um toque real
  /// aciona — em vez de pilotar `showDatePicker`/o overlay do dropdown.
  Future<void> preencherFormulario(
    WidgetTester tester, {
    required String email,
    required String nome,
  }) async {
    await ampliarSuperficie(tester);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), nome); // nome
    await tester.enterText(campos.at(1), email); // e-mail
    await tester.enterText(campos.at(2), '123.456.789-00'); // cpf

    tester
        .widget<GeopragDataNascimentoInput>(
          find.byType(GeopragDataNascimentoInput),
        )
        .onChanged(dataNascimento);
    tester
        .widget<GeopragSexoInput>(find.byType(GeopragSexoInput))
        .onChanged('Feminino');
    await tester.pump();
  }

  group('CriarAdministradorCubit', () {
    testWidgets(
      'não submete e mostra as mensagens de validação com o formulário vazio',
      (tester) async {
        await ampliarSuperficie(tester);

        await tester.pumpWidget(wrap());

        await tester.tap(find.text('Registrar Sub-Administrador'));
        await tester.pump();

        verifyNever(
          () => repository.criar(
            email: any(named: 'email'),
            nome: any(named: 'nome'),
            cpf: any(named: 'cpf'),
            dataNascimento: any(named: 'dataNascimento'),
            sexo: any(named: 'sexo'),
          ),
        );
        expect(find.text('Informe o nome completo.'), findsOneWidget);
        expect(find.text('Informe um CPF válido.'), findsOneWidget);
        expect(find.text('Informe a data de nascimento.'), findsOneWidget);
        expect(find.text('Informe o sexo.'), findsOneWidget);
      },
    );

    testWidgets(
      'submete o formulário e emite feedback de sucesso com a senha gerada',
      (tester) async {
        when(
          () => repository.criar(
            email: 'nova@gaspar.sc.gov.br',
            nome: 'Nova Conta',
            cpf: '123.456.789-00',
            dataNascimento: dataNascimento,
            sexo: 'Feminino',
          ),
        ).thenAnswer((_) async => novaConta());

        await tester.pumpWidget(wrap());
        await preencherFormulario(
          tester,
          email: 'nova@gaspar.sc.gov.br',
          nome: 'Nova Conta',
        );

        await tester.tap(find.text('Registrar Sub-Administrador'));
        await tester.pumpAndSettle();

        expect(
          find.text('Administrador cadastrado com sucesso.'),
          findsOneWidget,
        );
        expect(cubit.senhaGerada, '01011990nc#');
        verify(
          () => repository.criar(
            email: 'nova@gaspar.sc.gov.br',
            nome: 'Nova Conta',
            cpf: '123.456.789-00',
            dataNascimento: dataNascimento,
            sexo: 'Feminino',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'mostra spinner e desabilita o botão enquanto salva',
      (tester) async {
        final envioPendente = Completer<AdminAccount>();
        quandoCriarQualquer((_) => envioPendente.future);

        await tester.pumpWidget(wrap());
        await preencherFormulario(
          tester,
          email: 'nova@gaspar.sc.gov.br',
          nome: 'Nova Conta',
        );

        await tester.tap(find.text('Registrar Sub-Administrador'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );

        envioPendente.complete(novaConta());
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'emite feedback de erro com mensagem amigável quando o e-mail já existe',
      (tester) async {
        quandoCriarQualquer(
          (_) => throw const EntidadeDuplicadaException(
            'Já existe um administrador cadastrado com o e-mail '
            '"duplicado@gaspar.sc.gov.br".',
          ),
        );

        await tester.pumpWidget(wrap());
        await preencherFormulario(
          tester,
          email: 'duplicado@gaspar.sc.gov.br',
          nome: 'X',
        );

        await tester.tap(find.text('Registrar Sub-Administrador'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Já existe um administrador cadastrado'),
          findsOneWidget,
        );
        expect(cubit.senhaGerada, isNull);
      },
    );

    testWidgets(
      'emite mensagem genérica quando a exceção é inesperada '
      '(nunca expõe a exceção bruta ao usuário)',
      (tester) async {
        quandoCriarQualquer((_) => throw Exception('timeout'));

        await tester.pumpWidget(wrap());
        await preencherFormulario(
          tester,
          email: 'instavel@gaspar.sc.gov.br',
          nome: 'Y',
        );

        await tester.tap(find.text('Registrar Sub-Administrador'));
        await tester.pumpAndSettle();

        expect(
          find.text(AppErrorMessages.carregamentoGenerico),
          findsOneWidget,
        );
      },
    );
  });
}
