import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/mock_admin_accounts.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/resultado_solicitacao_promocao.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/core/solicitacao_promocao.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/data/administrador_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_administradores/data/mock_solicitacoes_promocao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

const _adminSeedEmail = 'admin@gaspar.sc.gov.br';

void main() {
  late AdministradorRepositoryImpl repository;
  final testEmails = <String>[];

  setUp(() {
    repository = AdministradorRepositoryImpl();
  });

  tearDown(() {
    for (final email in testEmails) {
      mockAdminAccounts.removeWhere((c) => c.email == email);
    }
    testEmails.clear();
    mockSolicitacoesPromocao.clear();
  });

  Future<AdminAccount> criarSubAdministrador(String email) async {
    testEmails.add(email);
    return repository.criar(
      email: email,
      nome: email,
      cpf: '123.456.789-00',
      dataNascimento: DateTime(1990, 1, 1),
      sexo: 'Feminino',
    );
  }

  void adicionarAdministrador(String email) {
    testEmails.add(email);
    mockAdminAccounts.add(
      AdminAccount(
        email: email,
        nome: email,
        cpf: '123.456.789-00',
        dataNascimento: DateTime(1980, 1, 1),
        sexo: 'Masculino',
        role: AdminRole.administrador,
      ),
    );
  }

  test('criar adiciona a conta como Sub-Administrador, mesmo cargo não sendo informado', () async {
    final conta = await criarSubAdministrador('nova@gaspar.sc.gov.br');

    expect(conta.role, AdminRole.subAdministrador);
    expect(mockAdminAccounts, contains(conta));
  });

  test('criar lança EntidadeDuplicadaException para e-mail já cadastrado', () async {
    expect(
      () => repository.criar(
        email: _adminSeedEmail,
        nome: 'Outro Nome',
        cpf: '123.456.789-00',
        dataNascimento: DateTime(1990, 1, 1),
        sexo: 'Feminino',
      ),
      throwsA(isA<EntidadeDuplicadaException>()),
    );
  });

  group('desativar', () {
    test('desativa o cadastro quando o executor é Administrador ativo', () async {
      final conta = await criarSubAdministrador('sub-desativar@gaspar.sc.gov.br');

      await repository.desativar(
        email: conta.email,
        executorEmail: _adminSeedEmail,
      );

      final atualizado = mockAdminAccounts.firstWhere(
        (c) => c.email == conta.email,
      );
      expect(atualizado.ativo, isFalse);
    });

    test('lança EntidadeNaoEncontradaException para e-mail inexistente', () {
      expect(
        () => repository.desativar(
          email: 'inexistente@gaspar.sc.gov.br',
          executorEmail: _adminSeedEmail,
        ),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });

    test('lança OperacaoNaoPermitidaException quando o executor não é Administrador', () async {
      final conta = await criarSubAdministrador('sub-alvo@gaspar.sc.gov.br');

      expect(
        () => repository.desativar(
          email: conta.email,
          executorEmail: 'celia.ramos@gaspar.sc.gov.br',
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('cancela automaticamente votação de promoção em aberto para o alvo desativado', () async {
      adicionarAdministrador('admin2-desativa@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-cancelado@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );
      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;

      await repository.desativar(
        email: alvo.email,
        executorEmail: _adminSeedEmail,
      );

      final atualizada = mockSolicitacoesPromocao.firstWhere(
        (s) => s.id == solicitacao.id,
      );
      expect(atualizada.status, StatusSolicitacaoPromocao.cancelada);
    });
  });

  group('solicitarPromocao', () {
    test('promove automaticamente quando não há outro Administrador ativo elegível', () async {
      final alvo = await criarSubAdministrador('auto-promovido@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );

      expect(resultado, isA<PromocaoAutomatica>());
      final contaAtualizada = mockAdminAccounts.firstWhere(
        (c) => c.email == alvo.email,
      );
      expect(contaAtualizada.role, AdminRole.administrador);
      expect(mockSolicitacoesPromocao, isEmpty);
    });

    test('abre votação travando a base de elegíveis quando há outros Administradores', () async {
      adicionarAdministrador('admin2-votacao@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-votacao@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );

      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;
      expect(solicitacao.baseElegiveisTravada, 1);
      expect(solicitacao.limiar, 1); // ceil(1 * 2/3) = 1
      expect(solicitacao.status, StatusSolicitacaoPromocao.aberta);
    });

    test('lança OperacaoNaoPermitidaException se já existe votação aberta para o mesmo alvo', () async {
      adicionarAdministrador('admin2-duplicada@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-duplicado@gaspar.sc.gov.br');

      await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );

      expect(
        () => repository.solicitarPromocao(
          solicitanteEmail: 'admin2-duplicada@gaspar.sc.gov.br',
          subAdministradorEmail: alvo.email,
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });

  group('votar', () {
    test('promove automaticamente ao atingir o limiar de 2/3 de votos favoráveis', () async {
      adicionarAdministrador('admin2-vota@gaspar.sc.gov.br');
      adicionarAdministrador('admin3-vota@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-aprovado@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );
      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;
      expect(solicitacao.limiar, 2); // ceil(2 * 2/3) = 2

      await repository.votar(
        solicitacaoId: solicitacao.id,
        votanteEmail: 'admin2-vota@gaspar.sc.gov.br',
        aprovar: true,
      );
      var atual = mockSolicitacoesPromocao.first;
      expect(atual.status, StatusSolicitacaoPromocao.aberta);

      await repository.votar(
        solicitacaoId: solicitacao.id,
        votanteEmail: 'admin3-vota@gaspar.sc.gov.br',
        aprovar: true,
      );
      atual = mockSolicitacoesPromocao.first;
      expect(atual.status, StatusSolicitacaoPromocao.aprovada);

      final contaAtualizada = mockAdminAccounts.firstWhere(
        (c) => c.email == alvo.email,
      );
      expect(contaAtualizada.role, AdminRole.administrador);
    });

    test('encerra como reprovada ao atingir o limiar de votos contrários', () async {
      adicionarAdministrador('admin2-reprova@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-reprovado@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );
      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;

      await repository.votar(
        solicitacaoId: solicitacao.id,
        votanteEmail: 'admin2-reprova@gaspar.sc.gov.br',
        aprovar: false,
      );

      final atual = mockSolicitacoesPromocao.first;
      expect(atual.status, StatusSolicitacaoPromocao.reprovada);

      final contaAtualizada = mockAdminAccounts.firstWhere(
        (c) => c.email == alvo.email,
      );
      expect(contaAtualizada.role, AdminRole.subAdministrador);
    });

    test('lança OperacaoNaoPermitidaException ao votar duas vezes na mesma solicitação', () async {
      adicionarAdministrador('admin2-duplo-voto@gaspar.sc.gov.br');
      adicionarAdministrador('admin3-duplo-voto@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-duplo-voto@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );
      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;

      await repository.votar(
        solicitacaoId: solicitacao.id,
        votanteEmail: 'admin2-duplo-voto@gaspar.sc.gov.br',
        aprovar: true,
      );

      expect(
        () => repository.votar(
          solicitacaoId: solicitacao.id,
          votanteEmail: 'admin2-duplo-voto@gaspar.sc.gov.br',
          aprovar: false,
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('lança OperacaoNaoPermitidaException quando quem vota é o solicitante ou o alvo', () async {
      adicionarAdministrador('admin2-inelegivel@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-inelegivel@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );
      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;

      expect(
        () => repository.votar(
          solicitacaoId: solicitacao.id,
          votanteEmail: _adminSeedEmail,
          aprovar: true,
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });

  group('cancelarSolicitacao', () {
    test('o solicitante cancela a própria solicitação em aberto', () async {
      adicionarAdministrador('admin2-cancela@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-cancela@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );
      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;

      await repository.cancelarSolicitacao(
        solicitacaoId: solicitacao.id,
        solicitanteEmail: _adminSeedEmail,
      );

      final atual = mockSolicitacoesPromocao.first;
      expect(atual.status, StatusSolicitacaoPromocao.cancelada);
    });

    test('lança OperacaoNaoPermitidaException se quem cancela não é o solicitante', () async {
      adicionarAdministrador('admin2-nao-solicitante@gaspar.sc.gov.br');
      final alvo = await criarSubAdministrador('sub-nao-solicitante@gaspar.sc.gov.br');

      final resultado = await repository.solicitarPromocao(
        solicitanteEmail: _adminSeedEmail,
        subAdministradorEmail: alvo.email,
      );
      final solicitacao = (resultado as SolicitacaoPromocaoAberta).solicitacao;

      expect(
        () => repository.cancelarSolicitacao(
          solicitacaoId: solicitacao.id,
          solicitanteEmail: 'admin2-nao-solicitante@gaspar.sc.gov.br',
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });
}
