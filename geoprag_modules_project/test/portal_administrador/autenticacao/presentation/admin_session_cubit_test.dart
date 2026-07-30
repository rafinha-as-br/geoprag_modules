import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_state.dart';

void main() {
  final conta = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    role: AdminRole.administrador,
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'estado inicial é SemAcesso',
    build: () => AdminSessionCubit(),
    verify: (cubit) => expect(cubit.state, isA<AdminSessionSemAcesso>()),
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'iniciarSessao emite Autenticado com a conta informada',
    build: () => AdminSessionCubit(),
    act: (cubit) => cubit.iniciarSessao(conta),
    expect: () => [
      isA<AdminSessionAutenticado>().having(
        (s) => s.conta.role,
        'conta.role',
        AdminRole.administrador,
      ),
    ],
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'encerrarSessao emite SemAcesso novamente',
    build: () => AdminSessionCubit(),
    seed: () => AdminSessionAutenticado(conta),
    act: (cubit) => cubit.encerrarSessao(),
    expect: () => [isA<AdminSessionSemAcesso>()],
  );
}
