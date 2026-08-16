import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/resultado_solicitacao_promocao.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/administradores_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/administradores_state.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAdministradorRepository extends Mock
    implements AdministradorRepository {}

void main() {
  late MockAdministradorRepository repository;

  final contaAdmin = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );
  final contaSub = AdminAccount(
    email: 'sub@gaspar.sc.gov.br',
    nome: 'Célia Ramos',
    cpf: '987.654.321-00',
    dataNascimento: DateTime(1990, 3, 20),
    sexo: 'Feminino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.subAdministrador,
  );

  setUp(() {
    repository = MockAdministradorRepository();
  });

  blocTest<AdministradoresCubit, AdministradoresState>(
    'carrega a listagem no estado inicial',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
    },
    build: () => AdministradoresCubit(repository),
    expect: () => [
      isA<AdministradoresLoaded>().having(
        (s) => s.administradores.length,
        'administradores.length',
        2,
      ),
    ],
  );

  blocTest<AdministradoresCubit, AdministradoresState>(
    'recarregar atualiza a lista sem aviso associado',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
    },
    build: () => AdministradoresCubit(repository),
    act: (cubit) => cubit.recarregar(),
    skip: 1,
    expect: () => [
      isA<AdministradoresLoaded>()
          .having((s) => s.administradores.length, 'administradores.length', 2)
          .having((s) => s.avisoAcao, 'avisoAcao', isNull),
    ],
  );

  blocTest<AdministradoresCubit, AdministradoresState>(
    'desativar recarrega a lista com aviso de sucesso',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
      when(
        () => repository.desativar(
          email: contaSub.email,
          executorEmail: contaAdmin.email,
        ),
      ).thenAnswer((_) async {});
    },
    build: () => AdministradoresCubit(repository),
    act: (cubit) =>
        cubit.desativar(email: contaSub.email, executorEmail: contaAdmin.email),
    skip: 1,
    expect: () => [
      isA<AdministradoresLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('desativado'),
      ),
    ],
  );

  blocTest<AdministradoresCubit, AdministradoresState>(
    'reativar recarrega a lista com aviso de sucesso',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
      when(
        () => repository.reativar(
          email: contaSub.email,
          executorEmail: contaAdmin.email,
        ),
      ).thenAnswer((_) async {});
    },
    build: () => AdministradoresCubit(repository),
    act: (cubit) =>
        cubit.reativar(email: contaSub.email, executorEmail: contaAdmin.email),
    skip: 1,
    expect: () => [
      isA<AdministradoresLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('reativado'),
      ),
    ],
  );

  blocTest<AdministradoresCubit, AdministradoresState>(
    'rebaixar recarrega a lista com aviso de sucesso',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
      when(
        () => repository.rebaixar(
          email: contaAdmin.email,
          executorEmail: contaAdmin.email,
        ),
      ).thenAnswer((_) async {});
    },
    build: () => AdministradoresCubit(repository),
    act: (cubit) => cubit.rebaixar(
      email: contaAdmin.email,
      executorEmail: contaAdmin.email,
    ),
    skip: 1,
    expect: () => [
      isA<AdministradoresLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('rebaixado'),
      ),
    ],
  );

  blocTest<AdministradoresCubit, AdministradoresState>(
    'rebaixar mostra a mensagem amigável quando o repositório recusa a operação',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
      when(
        () => repository.rebaixar(
          email: contaAdmin.email,
          executorEmail: contaAdmin.email,
        ),
      ).thenThrow(
        const OperacaoNaoPermitidaException(
          'Não é possível rebaixar o próprio cargo.',
        ),
      );
    },
    build: () => AdministradoresCubit(repository),
    act: (cubit) => cubit.rebaixar(
      email: contaAdmin.email,
      executorEmail: contaAdmin.email,
    ),
    skip: 1,
    expect: () => [
      isA<AdministradoresLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('próprio cargo'),
      ),
    ],
  );

  blocTest<AdministradoresCubit, AdministradoresState>(
    'solicitarPromocao mostra a mensagem amigável quando o repositório recusa a operação',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
      when(
        () => repository.solicitarPromocao(
          solicitanteEmail: contaAdmin.email,
          subAdministradorEmail: contaSub.email,
        ),
      ).thenThrow(
        const OperacaoNaoPermitidaException(
          'Já existe uma solicitação de promoção em aberto para este usuário.',
        ),
      );
    },
    build: () => AdministradoresCubit(repository),
    act: (cubit) => cubit.solicitarPromocao(
      solicitanteEmail: contaAdmin.email,
      subAdministradorEmail: contaSub.email,
    ),
    skip: 1,
    expect: () => [
      isA<AdministradoresLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('Já existe uma solicitação'),
      ),
    ],
  );

  blocTest<AdministradoresCubit, AdministradoresState>(
    'solicitarPromocao mostra aviso de promoção automática quando não há votação',
    setUp: () {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => [contaAdmin, contaSub]);
      when(
        () => repository.solicitarPromocao(
          solicitanteEmail: contaAdmin.email,
          subAdministradorEmail: contaSub.email,
        ),
      ).thenAnswer(
        (_) async => PromocaoAutomatica(
          contaSub.copyWith(role: AdminRole.administrador),
        ),
      );
    },
    build: () => AdministradoresCubit(repository),
    act: (cubit) => cubit.solicitarPromocao(
      solicitanteEmail: contaAdmin.email,
      subAdministradorEmail: contaSub.email,
    ),
    skip: 1,
    expect: () => [
      isA<AdministradoresLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('automaticamente'),
      ),
    ],
  );
}
