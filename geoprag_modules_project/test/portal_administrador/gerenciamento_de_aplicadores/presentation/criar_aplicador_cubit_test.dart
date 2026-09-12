import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/presentation/criar_aplicador_cubit.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_data_nascimento_input.dart';
import 'package:geoprag_modules/src/widgets/geoprag_sexo_input.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAplicadorRepository repository;
  late CriarAplicadorCubit cubit;

  final dataNascimento = DateTime(1990, 1, 1);

  Aplicador novoAplicador() => Aplicador(
    id: '6',
    nome: 'Nova Conta',
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 1, 1),
    email: 'novo@gaspar.sc.gov.br',
    cpf: '123.456.789-00',
    dataNascimento: dataNascimento,
    sexo: 'Feminino',
    cep: '89100-000',
    rua: 'Rua Nova',
    numero: '10',
    bairro: 'Centro',
    cidade: 'Gaspar',
    uf: 'SC',
    telefone: '',
  );

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<CriarAplicadorCubit>.value(
        value: cubit,
        child: const BaseFormScreen<CriarAplicadorCubit>(),
      ),
    ),
  );

  setUp(() {
    repository = MockAplicadorRepository();
    cubit = CriarAplicadorCubit(repository);
  });

  /// Preenche todos os campos obrigatórios do formulário na tela pumpada por
  /// [wrap]. Sexo e data de nascimento são disparados diretamente pelo
  /// `onChanged` do widget correspondente — mesmo caminho que um toque real
  /// aciona — em vez de pilotar `showDatePicker`/o overlay do dropdown.
  Future<void> preencherFormulario(
    WidgetTester tester, {
    required String email,
    required String nome,
  }) async {
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), nome); // nome
    await tester.enterText(campos.at(1), email); // e-mail
    await tester.enterText(campos.at(2), '123.456.789-00'); // cpf
    await tester.enterText(campos.at(3), '89100-000'); // cep
    await tester.enterText(campos.at(4), 'Rua Nova'); // rua
    await tester.enterText(campos.at(5), '10'); // número
    await tester.enterText(campos.at(7), 'Centro'); // bairro
    await tester.enterText(campos.at(8), 'Gaspar'); // cidade
    await tester.enterText(campos.at(9), 'SC'); // uf

    tester
        .widget<GeopragDataNascimentoInput>(
          find.byType(GeopragDataNascimentoInput),
        )
        .onChanged(dataNascimento);
    tester
        .widget<GeopragSexoInput>(find.byType(GeopragSexoInput))
        .onChanged('Feminino');
    await tester.pump();

    // O formulário tem campos demais para caber no viewport padrão do
    // teste — rola até o botão antes de tocá-lo, mesmo motivo do fix do
    // template em base_form_screen_test.dart.
    await tester.scrollUntilVisible(
      find.text('Registrar Aplicador'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }

  group('CriarAplicadorCubit', () {
    testWidgets(
      'submete o formulário e emite feedback de sucesso com a senha gerada',
      (tester) async {
        when(
          () => repository.criar(
            email: 'novo@gaspar.sc.gov.br',
            nome: 'Nova Conta',
            cpf: '123.456.789-00',
            dataNascimento: dataNascimento,
            sexo: 'Feminino',
            cep: '89100-000',
            rua: 'Rua Nova',
            numero: '10',
            complemento: null,
            bairro: 'Centro',
            cidade: 'Gaspar',
            uf: 'SC',
          ),
        ).thenAnswer((_) async => novoAplicador());

        await tester.pumpWidget(wrap());
        await preencherFormulario(
          tester,
          email: 'novo@gaspar.sc.gov.br',
          nome: 'Nova Conta',
        );

        await tester.tap(find.text('Registrar Aplicador'));
        await tester.pumpAndSettle();

        expect(find.text('Aplicador cadastrado com sucesso.'), findsOneWidget);
        expect(cubit.senhaGerada, '01011990nc#');
        verify(
          () => repository.criar(
            email: 'novo@gaspar.sc.gov.br',
            nome: 'Nova Conta',
            cpf: '123.456.789-00',
            dataNascimento: dataNascimento,
            sexo: 'Feminino',
            cep: '89100-000',
            rua: 'Rua Nova',
            numero: '10',
            complemento: null,
            bairro: 'Centro',
            cidade: 'Gaspar',
            uf: 'SC',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'mostra spinner e desabilita o botão enquanto salva',
      (tester) async {
        final envioPendente = Completer<Aplicador>();
        when(
          () => repository.criar(
            email: any(named: 'email'),
            nome: any(named: 'nome'),
            cpf: any(named: 'cpf'),
            dataNascimento: any(named: 'dataNascimento'),
            sexo: any(named: 'sexo'),
            cep: any(named: 'cep'),
            rua: any(named: 'rua'),
            numero: any(named: 'numero'),
            complemento: any(named: 'complemento'),
            bairro: any(named: 'bairro'),
            cidade: any(named: 'cidade'),
            uf: any(named: 'uf'),
          ),
        ).thenAnswer((_) => envioPendente.future);

        await tester.pumpWidget(wrap());
        await preencherFormulario(tester, email: 'novo@gaspar.sc.gov.br', nome: 'Nova Conta');

        await tester.tap(find.text('Registrar Aplicador'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );

        envioPendente.complete(novoAplicador());
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'emite feedback de erro com mensagem amigável quando o e-mail já existe',
      (tester) async {
        when(
          () => repository.criar(
            email: any(named: 'email'),
            nome: any(named: 'nome'),
            cpf: any(named: 'cpf'),
            dataNascimento: any(named: 'dataNascimento'),
            sexo: any(named: 'sexo'),
            cep: any(named: 'cep'),
            rua: any(named: 'rua'),
            numero: any(named: 'numero'),
            complemento: any(named: 'complemento'),
            bairro: any(named: 'bairro'),
            cidade: any(named: 'cidade'),
            uf: any(named: 'uf'),
          ),
        ).thenThrow(
          const EntidadeDuplicadaException(
            'Já existe um aplicador cadastrado com o e-mail '
            '"duplicado@gaspar.sc.gov.br".',
          ),
        );

        await tester.pumpWidget(wrap());
        await preencherFormulario(
          tester,
          email: 'duplicado@gaspar.sc.gov.br',
          nome: 'X',
        );

        await tester.tap(find.text('Registrar Aplicador'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Já existe um aplicador cadastrado'),
          findsOneWidget,
        );
        expect(cubit.senhaGerada, isNull);
      },
    );

    testWidgets(
      'emite mensagem genérica quando a exceção é inesperada '
      '(nunca expõe a exceção bruta ao usuário)',
      (tester) async {
        when(
          () => repository.criar(
            email: any(named: 'email'),
            nome: any(named: 'nome'),
            cpf: any(named: 'cpf'),
            dataNascimento: any(named: 'dataNascimento'),
            sexo: any(named: 'sexo'),
            cep: any(named: 'cep'),
            rua: any(named: 'rua'),
            numero: any(named: 'numero'),
            complemento: any(named: 'complemento'),
            bairro: any(named: 'bairro'),
            cidade: any(named: 'cidade'),
            uf: any(named: 'uf'),
          ),
        ).thenThrow(Exception('timeout'));

        await tester.pumpWidget(wrap());
        await preencherFormulario(
          tester,
          email: 'instavel@gaspar.sc.gov.br',
          nome: 'Y',
        );

        await tester.tap(find.text('Registrar Aplicador'));
        await tester.pumpAndSettle();

        expect(
          find.text(AppErrorMessages.carregamentoGenerico),
          findsOneWidget,
        );
      },
    );
  });
}
