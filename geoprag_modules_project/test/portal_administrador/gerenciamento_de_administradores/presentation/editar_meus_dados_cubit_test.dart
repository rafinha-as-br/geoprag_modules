import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_exceptions.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/editar_meus_dados_cubit.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
import 'package:geoprag_modules/src/widgets/base_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdministradorRepository extends Mock
    implements AdministradorRepository {}

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

/// Aciona o `onChanged` do checkbox "trocar minha senha" sem simular o
/// gesto de toque completo — `tester.tap()` sobre um `CheckboxListTile`
/// dispara o efeito de ripple, que tenta carregar o shader
/// `ink_sparkle.frag`, indisponível neste ambiente de teste (mesma causa
/// dos 47+ testes pré-existentes do pacote que também evitam `tap` sobre
/// widgets com ripple).
Future<void> _marcarTrocarSenha(WidgetTester tester) async {
  final checkbox = tester.widget<CheckboxListTile>(
    find.byType(CheckboxListTile),
  );
  checkbox.onChanged!(true);
  await tester.pump();
}

void main() {
  late MockAdministradorRepository administradorRepository;
  late MockAdminAuthRepository authRepository;
  late EditarMeusDadosCubit cubit;

  final contaAtual = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );

  Widget wrap() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<EditarMeusDadosCubit>.value(
        value: cubit,
        child: const BaseFormScreen<EditarMeusDadosCubit>(),
      ),
    ),
  );

  setUp(() {
    administradorRepository = MockAdministradorRepository();
    authRepository = MockAdminAuthRepository();
    cubit = EditarMeusDadosCubit(
      administradorRepository,
      authRepository,
      contaAtual,
    );
  });

  Future<void> ampliarSuperficie(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('carrega nome e e-mail da conta atual nos campos', (
    tester,
  ) async {
    await ampliarSuperficie(tester);
    await tester.pumpWidget(wrap());

    expect(find.text('Marcos Vieira'), findsOneWidget);
    expect(find.text('admin@gaspar.sc.gov.br'), findsOneWidget);
  });

  testWidgets(
    'checkbox de troca de senha revela senha atual e nova senha',
    (tester) async {
      await ampliarSuperficie(tester);
      await tester.pumpWidget(wrap());

      expect(find.text('Senha atual'), findsNothing);

      await _marcarTrocarSenha(tester);

      expect(find.text('Senha atual'), findsOneWidget);
      expect(find.text('Nova senha'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
    },
  );

  testWidgets('salva nome e e-mail e emite feedback de sucesso', (
    tester,
  ) async {
    final contaSalva = contaAtual.copyWith(
      nome: 'Marcos V. Silva',
      email: 'marcos.silva@gaspar.sc.gov.br',
    );
    when(
      () => administradorRepository.editarPropriosDados(
        emailAtual: contaAtual.email,
        nome: 'Marcos V. Silva',
        novoEmail: 'marcos.silva@gaspar.sc.gov.br',
      ),
    ).thenAnswer((_) async => contaSalva);

    await ampliarSuperficie(tester);
    await tester.pumpWidget(wrap());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Marcos Vieira'),
      'Marcos V. Silva',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'admin@gaspar.sc.gov.br'),
      'marcos.silva@gaspar.sc.gov.br',
    );
    // Chama submit() direto no Cubit em vez de tester.tap() no botão: evita
    // o efeito de ripple do Material (mesmo motivo de _marcarTrocarSenha).
    await cubit.submit();
    await tester.pump();

    expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
    expect(cubit.contaAtualizada, contaSalva);
    verifyNever(
      () => authRepository.alterarSenha(
        senhaAtual: any(named: 'senhaAtual'),
        novaSenha: any(named: 'novaSenha'),
      ),
    );
  });

  testWidgets('e-mail já cadastrado mostra erro amigável', (tester) async {
    when(
      () => administradorRepository.editarPropriosDados(
        emailAtual: any(named: 'emailAtual'),
        nome: any(named: 'nome'),
        novoEmail: any(named: 'novoEmail'),
      ),
    ).thenAnswer(
      (_) async => throw const EntidadeDuplicadaException(
        'Já existe um administrador cadastrado com o e-mail "x".',
      ),
    );

    await ampliarSuperficie(tester);
    await tester.pumpWidget(wrap());

    // Chama submit() direto no Cubit em vez de tester.tap() no botão: evita
    // o efeito de ripple do Material (mesmo motivo de _marcarTrocarSenha).
    await cubit.submit();
    await tester.pump();

    expect(cubit.state.feedback, isA<AcaoFeedbackErro>());
    expect(
      (cubit.state.feedback as AcaoFeedbackErro).mensagem,
      contains('e-mail'),
    );
  });

  testWidgets(
    'troca de senha bem-sucedida: dados e senha atualizados',
    (tester) async {
      when(
        () => administradorRepository.editarPropriosDados(
          emailAtual: any(named: 'emailAtual'),
          nome: any(named: 'nome'),
          novoEmail: any(named: 'novoEmail'),
        ),
      ).thenAnswer((_) async => contaAtual);
      when(
        () => authRepository.alterarSenha(
          senhaAtual: 'SenhaAtual123',
          novaSenha: 'NovaSenhaForte99',
        ),
      ).thenAnswer((_) async {});

      await ampliarSuperficie(tester);
      await tester.pumpWidget(wrap());

      await _marcarTrocarSenha(tester);

      // Ordem dos TextFormField: 0=Nome, 1=E-mail, 2=Senha atual, 3=Nova
      // senha (o checkbox "Segurança" não é um TextFormField).
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'SenhaAtual123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'NovaSenhaForte99',
      );
      await cubit.submit();
      await tester.pump();

      expect(cubit.state.feedback, isA<AcaoFeedbackSucesso>());
      verify(
        () => authRepository.alterarSenha(
          senhaAtual: 'SenhaAtual123',
          novaSenha: 'NovaSenhaForte99',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'senha atual incorreta: dados salvos mas feedback avisa que a senha não mudou',
    (tester) async {
      when(
        () => administradorRepository.editarPropriosDados(
          emailAtual: any(named: 'emailAtual'),
          nome: any(named: 'nome'),
          novoEmail: any(named: 'novoEmail'),
        ),
      ).thenAnswer((_) async => contaAtual);
      when(
        () => authRepository.alterarSenha(
          senhaAtual: any(named: 'senhaAtual'),
          novaSenha: any(named: 'novaSenha'),
        ),
      ).thenThrow(const InvalidCredentialsException());

      await ampliarSuperficie(tester);
      await tester.pumpWidget(wrap());

      await _marcarTrocarSenha(tester);

      await tester.enterText(find.byType(TextFormField).at(2), 'SenhaErrada');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'NovaSenhaForte99',
      );
      await cubit.submit();
      await tester.pump();

      expect(cubit.state.feedback, isA<AcaoFeedbackErro>());
      expect(
        (cubit.state.feedback as AcaoFeedbackErro).mensagem,
        contains('senha atual incorreta'),
      );
      // Os dados (nome/e-mail) foram salvos mesmo com a senha falhando.
      expect(cubit.contaAtualizada, contaAtual);
    },
  );

  testWidgets('nova senha fraca é rejeitada antes de chamar o repositório', (
    tester,
  ) async {
    when(
      () => administradorRepository.editarPropriosDados(
        emailAtual: any(named: 'emailAtual'),
        nome: any(named: 'nome'),
        novoEmail: any(named: 'novoEmail'),
      ),
    ).thenAnswer((_) async => contaAtual);

    await ampliarSuperficie(tester);
    await tester.pumpWidget(wrap());

    await _marcarTrocarSenha(tester);

    await tester.enterText(
      find.byType(TextFormField).at(2),
      'SenhaAtual123',
    );
    await tester.enterText(find.byType(TextFormField).at(3), '123');
    // Chama submit() direto no Cubit em vez de tester.tap() no botão: evita
    // o efeito de ripple do Material (mesmo motivo de _marcarTrocarSenha).
    await cubit.submit();
    await tester.pump();

    expect(find.text('A senha não atende aos requisitos.'), findsOneWidget);
    verifyNever(
      () => authRepository.alterarSenha(
        senhaAtual: any(named: 'senhaAtual'),
        novaSenha: any(named: 'novaSenha'),
      ),
    );
  });
}
