import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminAuthRepository extends Mock implements AdminAuthRepository {}

void main() {
  late MockAdminAuthRepository repository;

  final conta = AdminAccount(
    id: 'adm-77',
    tenantId: 'gaspar-sc',
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '',
    dataNascimento: DateTime.utc(1970),
    sexo: '',
    dataCriacao: DateTime.utc(1970),
    role: AdminRole.administrador,
  );

  setUp(() {
    repository = MockAdminAuthRepository();
  });

  blocTest<AdminSessionCubit, AdminSessionState>(
    'restaurar emite Autenticado quando há sessão guardada',
    setUp: () {
      when(() => repository.sessaoAtual()).thenAnswer((_) async => conta);
    },
    build: () => AdminSessionCubit(repository: repository),
    act: (cubit) => cubit.restaurar(),
    expect: () => [
      isA<AdminSessionAutenticado>().having(
        (s) => s.conta.id,
        'conta.id',
        'adm-77',
      ),
    ],
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'restaurar sem sessão guardada não emite nada',
    setUp: () {
      when(() => repository.sessaoAtual()).thenAnswer((_) async => null);
    },
    build: () => AdminSessionCubit(repository: repository),
    act: (cubit) => cubit.restaurar(),
    expect: () => <AdminSessionState>[],
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'restaurar com falha de leitura segue sem sessão (o portal pede o login)',
    setUp: () {
      when(() => repository.sessaoAtual()).thenThrow(Exception('storage'));
    },
    build: () => AdminSessionCubit(repository: repository),
    act: (cubit) => cubit.restaurar(),
    expect: () => <AdminSessionState>[],
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'restaurar sem repositório (uso só com mocks) não emite nada',
    build: () => AdminSessionCubit(),
    act: (cubit) => cubit.restaurar(),
    expect: () => <AdminSessionState>[],
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'encerrarSessao apaga a sessão guardada e emite SemAcesso',
    setUp: () {
      when(() => repository.logout()).thenAnswer((_) async {});
    },
    build: () => AdminSessionCubit(repository: repository),
    seed: () => AdminSessionAutenticado(conta),
    act: (cubit) => cubit.encerrarSessao(),
    expect: () => [isA<AdminSessionSemAcesso>()],
    verify: (_) => verify(() => repository.logout()).called(1),
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'encerrarSessao emite SemAcesso mesmo se apagar o armazenamento falhar',
    setUp: () {
      when(() => repository.logout()).thenThrow(Exception('storage'));
    },
    build: () => AdminSessionCubit(repository: repository),
    seed: () => AdminSessionAutenticado(conta),
    act: (cubit) => cubit.encerrarSessao(),
    expect: () => [isA<AdminSessionSemAcesso>()],
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'sessaoPerdida emite SemAcesso sem chamar o logout (a API já apagou o token)',
    build: () => AdminSessionCubit(repository: repository),
    seed: () => AdminSessionAutenticado(conta),
    act: (cubit) => cubit.sessaoPerdida(),
    expect: () => [isA<AdminSessionSemAcesso>()],
    verify: (_) => verifyNever(() => repository.logout()),
  );
}
