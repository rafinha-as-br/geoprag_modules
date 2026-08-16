import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/administrador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/solicitacao_promocao.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/solicitacoes_promocao_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/presentation/solicitacoes_promocao_state.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAdministradorRepository extends Mock
    implements AdministradorRepository {}

void main() {
  late MockAdministradorRepository repository;

  const solicitanteEmail = 'admin@gaspar.sc.gov.br';
  const votanteEmail = 'admin2@gaspar.sc.gov.br';
  const alvoEmail = 'sub@gaspar.sc.gov.br';

  final contas = [
    AdminAccount(
      email: solicitanteEmail,
      nome: 'Marcos Vieira',
      cpf: '123.456.789-00',
      dataNascimento: DateTime(1980, 5, 12),
      sexo: 'Masculino',
      dataCriacao: DateTime(2026, 1, 1),
      role: AdminRole.administrador,
    ),
    AdminAccount(
      email: votanteEmail,
      nome: 'Outro Admin',
      cpf: '111.111.111-11',
      dataNascimento: DateTime(1980, 5, 12),
      sexo: 'Masculino',
      dataCriacao: DateTime(2026, 1, 1),
      role: AdminRole.administrador,
    ),
    AdminAccount(
      email: alvoEmail,
      nome: 'Célia Ramos',
      cpf: '987.654.321-00',
      dataNascimento: DateTime(1990, 3, 20),
      sexo: 'Feminino',
      dataCriacao: DateTime(2026, 1, 1),
      role: AdminRole.subAdministrador,
    ),
  ];

  final solicitacaoAberta = SolicitacaoPromocao(
    id: 'sp1',
    subAdministradorEmail: alvoEmail,
    solicitanteEmail: solicitanteEmail,
    dataAbertura: DateTime(2026, 1, 1),
    baseElegiveisTravada: 1,
    votantesEmail: const {},
    votosFavoraveis: 0,
    votosContrarios: 0,
    status: StatusSolicitacaoPromocao.aberta,
  );

  setUp(() {
    repository = MockAdministradorRepository();
    when(() => repository.listar()).thenAnswer((_) async => contas);
  });

  blocTest<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
    'carrega as solicitações em aberto identificando se o usuário atual já votou',
    setUp: () {
      when(
        () => repository.listarSolicitacoesAbertas(),
      ).thenAnswer((_) async => [solicitacaoAberta]);
    },
    build: () => SolicitacoesPromocaoCubit(repository, votanteEmail),
    expect: () => [
      isA<SolicitacoesPromocaoLoaded>()
          .having((s) => s.solicitacoes.length, 'length', 1)
          .having((s) => s.solicitacoes.first.jaVotei, 'jaVotei', isFalse)
          .having(
            (s) => s.solicitacoes.first.souOSolicitante,
            'souOSolicitante',
            isFalse,
          ),
    ],
  );

  blocTest<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
    'recarregar atualiza a lista sem aviso associado',
    setUp: () {
      when(
        () => repository.listarSolicitacoesAbertas(),
      ).thenAnswer((_) async => [solicitacaoAberta]);
    },
    build: () => SolicitacoesPromocaoCubit(repository, votanteEmail),
    act: (cubit) => cubit.recarregar(),
    skip: 1,
    expect: () => [
      isA<SolicitacoesPromocaoLoaded>()
          .having((s) => s.solicitacoes.length, 'length', 1)
          .having((s) => s.avisoAcao, 'avisoAcao', isNull),
    ],
  );

  blocTest<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
    'votar recarrega a lista com aviso de sucesso',
    setUp: () {
      when(
        () => repository.listarSolicitacoesAbertas(),
      ).thenAnswer((_) async => [solicitacaoAberta]);
      when(
        () => repository.votar(
          solicitacaoId: 'sp1',
          votanteEmail: votanteEmail,
          aprovar: true,
        ),
      ).thenAnswer((_) async {});
    },
    build: () => SolicitacoesPromocaoCubit(repository, votanteEmail),
    act: (cubit) => cubit.votar(solicitacaoId: 'sp1', aprovar: true),
    skip: 1,
    expect: () => [
      isA<SolicitacoesPromocaoLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('aprovação'),
      ),
    ],
  );

  blocTest<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
    'votar mostra mensagem amigável quando o voto já foi registrado',
    setUp: () {
      when(
        () => repository.listarSolicitacoesAbertas(),
      ).thenAnswer((_) async => [solicitacaoAberta]);
      when(
        () => repository.votar(
          solicitacaoId: 'sp1',
          votanteEmail: votanteEmail,
          aprovar: true,
        ),
      ).thenThrow(
        const OperacaoNaoPermitidaException(
          'Seu voto já foi registrado e não pode ser alterado.',
        ),
      );
    },
    build: () => SolicitacoesPromocaoCubit(repository, votanteEmail),
    act: (cubit) => cubit.votar(solicitacaoId: 'sp1', aprovar: true),
    skip: 1,
    expect: () => [
      isA<SolicitacoesPromocaoLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('já foi registrado'),
      ),
    ],
  );

  blocTest<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
    'cancelar recarrega a lista com aviso de sucesso',
    setUp: () {
      when(
        () => repository.listarSolicitacoesAbertas(),
      ).thenAnswer((_) async => [solicitacaoAberta]);
      when(
        () => repository.cancelarSolicitacao(
          solicitacaoId: 'sp1',
          solicitanteEmail: solicitanteEmail,
        ),
      ).thenAnswer((_) async {});
    },
    build: () => SolicitacoesPromocaoCubit(repository, solicitanteEmail),
    act: (cubit) => cubit.cancelar('sp1'),
    skip: 1,
    expect: () => [
      isA<SolicitacoesPromocaoLoaded>().having(
        (s) => s.avisoAcao,
        'avisoAcao',
        contains('cancelada'),
      ),
    ],
  );
}
