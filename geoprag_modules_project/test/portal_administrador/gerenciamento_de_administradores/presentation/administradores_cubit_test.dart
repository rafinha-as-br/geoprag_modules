import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/resultado_solicitacao_promocao.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/administradores_cubit.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';
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
    when(
      () => repository.listar(),
    ).thenAnswer((_) async => [contaAdmin, contaSub]);
  });

  test('carrega a listagem no estado inicial', () async {
    final cubit = AdministradoresCubit(repository);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.items.length, 2);
    expect(cubit.state.isLoading, isFalse);
  });

  test('busca filtra por nome, e-mail ou cargo', () async {
    final cubit = AdministradoresCubit(repository);
    await Future<void>.delayed(Duration.zero);

    cubit.buscar('célia');

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.single.nome, 'Célia Ramos');
  });

  test('recarregar atualiza a lista sem feedback associado', () async {
    final cubit = AdministradoresCubit(repository);
    await Future<void>.delayed(Duration.zero);

    await cubit.recarregar();

    expect(cubit.state.items.length, 2);
    expect(cubit.state.feedback, isNull);
  });

  test(
    'recarregar limpa o feedback de uma ação anterior não relacionada '
    '(ex.: voltar de "Novo Administrador" depois de desativar alguém)',
    () async {
      when(
        () => repository.desativar(
          email: contaSub.email,
          executorEmail: contaAdmin.email,
        ),
      ).thenAnswer((_) async {});

      final cubit = AdministradoresCubit(repository);
      await Future<void>.delayed(Duration.zero);
      await cubit.desativar(
        email: contaSub.email,
        executorEmail: contaAdmin.email,
      );
      expect(cubit.state.feedback, isNotNull);

      await cubit.recarregar();

      expect(cubit.state.feedback, isNull);
    },
  );

  test('desativar recarrega a lista e emite feedback de sucesso', () async {
    when(
      () => repository.desativar(
        email: contaSub.email,
        executorEmail: contaAdmin.email,
      ),
    ).thenAnswer((_) async {});

    final cubit = AdministradoresCubit(repository);
    await Future<void>.delayed(Duration.zero);

    await cubit.desativar(
      email: contaSub.email,
      executorEmail: contaAdmin.email,
    );

    expect(
      cubit.state.feedback,
      isA<AcaoFeedbackSucesso>().having(
        (f) => f.mensagem,
        'mensagem',
        contains('desativado'),
      ),
    );
  });

  test('reativar recarrega a lista e emite feedback de sucesso', () async {
    when(
      () => repository.reativar(
        email: contaSub.email,
        executorEmail: contaAdmin.email,
      ),
    ).thenAnswer((_) async {});

    final cubit = AdministradoresCubit(repository);
    await Future<void>.delayed(Duration.zero);

    await cubit.reativar(
      email: contaSub.email,
      executorEmail: contaAdmin.email,
    );

    expect(
      cubit.state.feedback,
      isA<AcaoFeedbackSucesso>().having(
        (f) => f.mensagem,
        'mensagem',
        contains('reativado'),
      ),
    );
  });

  test('rebaixar recarrega a lista e emite feedback de sucesso', () async {
    when(
      () => repository.rebaixar(
        email: contaAdmin.email,
        executorEmail: contaAdmin.email,
      ),
    ).thenAnswer((_) async {});

    final cubit = AdministradoresCubit(repository);
    await Future<void>.delayed(Duration.zero);

    await cubit.rebaixar(
      email: contaAdmin.email,
      executorEmail: contaAdmin.email,
    );

    expect(
      cubit.state.feedback,
      isA<AcaoFeedbackSucesso>().having(
        (f) => f.mensagem,
        'mensagem',
        contains('rebaixado'),
      ),
    );
  });

  test(
    'rebaixar emite feedback de erro amigável quando o repositório recusa a operação',
    () async {
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

      final cubit = AdministradoresCubit(repository);
      await Future<void>.delayed(Duration.zero);

      await cubit.rebaixar(
        email: contaAdmin.email,
        executorEmail: contaAdmin.email,
      );

      expect(
        cubit.state.feedback,
        isA<AcaoFeedbackErro>().having(
          (f) => f.mensagem,
          'mensagem',
          contains('próprio cargo'),
        ),
      );
    },
  );

  test(
    'solicitarPromocao emite feedback de erro amigável quando o repositório recusa a operação',
    () async {
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

      final cubit = AdministradoresCubit(repository);
      await Future<void>.delayed(Duration.zero);

      await cubit.solicitarPromocao(
        solicitanteEmail: contaAdmin.email,
        subAdministradorEmail: contaSub.email,
      );

      expect(
        cubit.state.feedback,
        isA<AcaoFeedbackErro>().having(
          (f) => f.mensagem,
          'mensagem',
          contains('Já existe uma solicitação'),
        ),
      );
    },
  );

  test(
    'solicitarPromocao emite feedback de sucesso com promoção automática quando não há votação',
    () async {
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

      final cubit = AdministradoresCubit(repository);
      await Future<void>.delayed(Duration.zero);

      await cubit.solicitarPromocao(
        solicitanteEmail: contaAdmin.email,
        subAdministradorEmail: contaSub.email,
      );

      expect(
        cubit.state.feedback,
        isA<AcaoFeedbackSucesso>().having(
          (f) => f.mensagem,
          'mensagem',
          contains('automaticamente'),
        ),
      );
    },
  );
}
