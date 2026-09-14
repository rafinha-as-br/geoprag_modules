import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_exceptions.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_state.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/editar_meus_dados_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/editar_meus_dados_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAdministradorRepository extends Mock
    implements AdministradorRepository {}

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

void main() {
  final contaAtual = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );

  late MockAdministradorRepository administradorRepository;
  late MockAdminAuthRepository authRepository;
  late EditarMeusDadosCubit cubit;
  late AdminSessionCubit sessionCubit;

  Widget wrap() => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<EditarMeusDadosCubit>.value(value: cubit),
        BlocProvider<AdminSessionCubit>.value(value: sessionCubit),
      ],
      child: const EditarMeusDadosScreen(),
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
    sessionCubit = AdminSessionCubit()..iniciarSessao(contaAtual);
  });

  Future<void> ampliarSuperficie(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets(
    'sucesso parcial (senha atual incorreta): AdminSessionCubit é sincronizado mesmo assim',
    (tester) async {
      final contaSalva = contaAtual.copyWith(nome: 'Marcos V. Silva');
      when(
        () => administradorRepository.editarPropriosDados(
          emailAtual: any(named: 'emailAtual'),
          nome: any(named: 'nome'),
          novoEmail: any(named: 'novoEmail'),
        ),
      ).thenAnswer((_) async => contaSalva);
      when(
        () => authRepository.alterarSenha(
          senhaAtual: any(named: 'senhaAtual'),
          novaSenha: any(named: 'novaSenha'),
        ),
      ).thenThrow(const InvalidCredentialsException());

      await ampliarSuperficie(tester);
      await tester.pumpWidget(wrap());

      final checkbox = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      checkbox.onChanged!(true);
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(2), 'ErrouASenha');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'NovaSenhaForte99',
      );

      await cubit.submit();
      await tester.pump();

      // A senha falhou (feedback de erro), mas o nome já mudou — a sessão
      // precisa refletir isso sem exigir novo login.
      expect(
        sessionCubit.state,
        isA<AdminSessionAutenticado>().having(
          (s) => s.conta.nome,
          'nome',
          'Marcos V. Silva',
        ),
      );
    },
  );
}
