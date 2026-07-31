import '../../autenticacao/core/admin_account.dart';
import '../../autenticacao/data/mock_admin_accounts.dart';
import '../core/administrador_repository.dart';
import '../core/resultado_solicitacao_promocao.dart';
import '../core/solicitacao_promocao.dart';
import 'mock_solicitacoes_promocao.dart';
import '../../../src/errors/app_exceptions.dart';

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

/// Implementação mockada de [AdministradorRepository] — opera sobre as
/// listas mockadas compartilhadas com o fluxo de autenticação
/// (`mockAdminAccounts`) e as solicitações de promoção
/// (`mockSolicitacoesPromocao`).
///
/// TODO(GEOPRAG-36): substituir por implementação HTTP real quando o
/// contrato de endpoints deste módulo for validado com o backend.
class AdministradorRepositoryImpl implements AdministradorRepository {
  @override
  Future<AdminAccount> criar({
    required String email,
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String sexo,
  }) async {
    final jaExiste = mockAdminAccounts.any((conta) => conta.email == email);
    if (jaExiste) {
      throw EntidadeDuplicadaException(
        'Já existe um administrador cadastrado com o e-mail "$email".',
      );
    }

    final conta = AdminAccount(
      email: email,
      nome: nome,
      cpf: cpf,
      dataNascimento: dataNascimento,
      sexo: sexo,
      role: AdminRole.subAdministrador,
    );
    mockAdminAccounts.add(conta);
    return conta;
  }

  @override
  Future<List<AdminAccount>> listar() async => List.unmodifiable(mockAdminAccounts);

  @override
  Future<void> desativar({
    required String email,
    required String executorEmail,
  }) async {
    final indiceAlvo = mockAdminAccounts.indexWhere((c) => c.email == email);
    if (indiceAlvo == -1) {
      throw EntidadeNaoEncontradaException(
        'Administrador "$email" não encontrado.',
      );
    }

    final executor = _buscarAdministradorAtivo(executorEmail);
    if (executor == null) {
      throw const OperacaoNaoPermitidaException(
        'Apenas um Administrador ativo pode desativar um cadastro.',
      );
    }

    mockAdminAccounts[indiceAlvo] = mockAdminAccounts[indiceAlvo].copyWith(
      ativo: false,
    );

    // RN "Mecânica da Votação 2/3", regra específica 7: desativação do
    // Sub-Administrador alvo cancela automaticamente qualquer votação de
    // promoção em aberto para ele, independentemente dos votos já
    // registrados.
    for (var i = 0; i < mockSolicitacoesPromocao.length; i++) {
      final solicitacao = mockSolicitacoesPromocao[i];
      if (solicitacao.subAdministradorEmail == email && solicitacao.aberta) {
        mockSolicitacoesPromocao[i] = solicitacao.copyWith(
          status: StatusSolicitacaoPromocao.cancelada,
        );
      }
    }
  }

  @override
  Future<ResultadoSolicitacaoPromocao> solicitarPromocao({
    required String solicitanteEmail,
    required String subAdministradorEmail,
  }) async {
    final solicitante = _buscarAdministradorAtivo(solicitanteEmail);
    if (solicitante == null) {
      throw const OperacaoNaoPermitidaException(
        'Apenas um Administrador ativo pode solicitar uma promoção.',
      );
    }

    final alvo = mockAdminAccounts
        .where((c) => c.email == subAdministradorEmail)
        .firstOrNull;
    if (alvo == null) {
      throw EntidadeNaoEncontradaException(
        'Administrador "$subAdministradorEmail" não encontrado.',
      );
    }
    if (!alvo.ativo || alvo.role != AdminRole.subAdministrador) {
      throw const OperacaoNaoPermitidaException(
        'Só é possível solicitar promoção de um Sub-Administrador ativo.',
      );
    }

    // RN "Mecânica da Votação 2/3", regra específica 8: uma votação de
    // promoção por Sub-Administrador por vez.
    final jaExisteAberta = mockSolicitacoesPromocao.any(
      (s) => s.subAdministradorEmail == subAdministradorEmail && s.aberta,
    );
    if (jaExisteAberta) {
      throw const OperacaoNaoPermitidaException(
        'Já existe uma solicitação de promoção em aberto para este usuário.',
      );
    }

    final baseElegiveis = mockAdminAccounts
        .where(
          (c) =>
              c.role == AdminRole.administrador &&
              c.ativo &&
              c.email != solicitanteEmail &&
              c.email != subAdministradorEmail,
        )
        .length;

    // RN "Mecânica da Votação 2/3", regra específica 5: sem nenhum "demais
    // Administrador" elegível, promove automaticamente sem abrir votação.
    if (baseElegiveis == 0) {
      final indiceAlvo = mockAdminAccounts.indexOf(alvo);
      final contaPromovida = alvo.copyWith(role: AdminRole.administrador);
      mockAdminAccounts[indiceAlvo] = contaPromovida;
      return PromocaoAutomatica(contaPromovida);
    }

    final solicitacao = SolicitacaoPromocao(
      id: proximoIdSolicitacaoPromocao(),
      subAdministradorEmail: subAdministradorEmail,
      solicitanteEmail: solicitanteEmail,
      dataAbertura: DateTime.now(),
      baseElegiveisTravada: baseElegiveis,
      votantesEmail: const {},
      votosFavoraveis: 0,
      votosContrarios: 0,
      status: StatusSolicitacaoPromocao.aberta,
    );
    mockSolicitacoesPromocao.add(solicitacao);
    return SolicitacaoPromocaoAberta(solicitacao);
  }

  @override
  Future<List<SolicitacaoPromocao>> listarSolicitacoesAbertas() async =>
      List.unmodifiable(mockSolicitacoesPromocao.where((s) => s.aberta));

  @override
  Future<void> votar({
    required String solicitacaoId,
    required String votanteEmail,
    required bool aprovar,
  }) async {
    final indice = mockSolicitacoesPromocao.indexWhere(
      (s) => s.id == solicitacaoId,
    );
    if (indice == -1) {
      throw EntidadeNaoEncontradaException(
        'Solicitação de promoção "$solicitacaoId" não encontrada.',
      );
    }

    final solicitacao = mockSolicitacoesPromocao[indice];
    if (!solicitacao.aberta) {
      throw const OperacaoNaoPermitidaException(
        'Esta solicitação de promoção já foi encerrada.',
      );
    }

    final votante = _buscarAdministradorAtivo(votanteEmail);
    final elegivel =
        votante != null &&
        votanteEmail != solicitacao.solicitanteEmail &&
        votanteEmail != solicitacao.subAdministradorEmail;
    if (!elegivel) {
      throw const OperacaoNaoPermitidaException(
        'Você não está habilitado a votar nesta solicitação.',
      );
    }

    // RN "Mecânica da Votação 2/3", regra específica 3: voto definitivo.
    if (solicitacao.votantesEmail.contains(votanteEmail)) {
      throw const OperacaoNaoPermitidaException(
        'Seu voto já foi registrado e não pode ser alterado.',
      );
    }

    final novosVotantes = {...solicitacao.votantesEmail, votanteEmail};
    final novosFavoraveis =
        solicitacao.votosFavoraveis + (aprovar ? 1 : 0);
    final novosContrarios =
        solicitacao.votosContrarios + (aprovar ? 0 : 1);

    var novoStatus = solicitacao.status;
    if (novosFavoraveis >= solicitacao.limiar) {
      novoStatus = StatusSolicitacaoPromocao.aprovada;
      final indiceAlvo = mockAdminAccounts.indexWhere(
        (c) => c.email == solicitacao.subAdministradorEmail,
      );
      if (indiceAlvo != -1) {
        mockAdminAccounts[indiceAlvo] = mockAdminAccounts[indiceAlvo]
            .copyWith(role: AdminRole.administrador);
      }
    } else if (novosContrarios >= solicitacao.limiar) {
      novoStatus = StatusSolicitacaoPromocao.reprovada;
    }

    mockSolicitacoesPromocao[indice] = solicitacao.copyWith(
      votantesEmail: novosVotantes,
      votosFavoraveis: novosFavoraveis,
      votosContrarios: novosContrarios,
      status: novoStatus,
    );
  }

  @override
  Future<void> cancelarSolicitacao({
    required String solicitacaoId,
    required String solicitanteEmail,
  }) async {
    final indice = mockSolicitacoesPromocao.indexWhere(
      (s) => s.id == solicitacaoId,
    );
    if (indice == -1) {
      throw EntidadeNaoEncontradaException(
        'Solicitação de promoção "$solicitacaoId" não encontrada.',
      );
    }

    final solicitacao = mockSolicitacoesPromocao[indice];
    if (!solicitacao.aberta) {
      throw const OperacaoNaoPermitidaException(
        'Esta solicitação de promoção já foi encerrada.',
      );
    }
    if (solicitacao.solicitanteEmail != solicitanteEmail) {
      throw const OperacaoNaoPermitidaException(
        'Só quem abriu a solicitação pode cancelá-la.',
      );
    }

    // RN "Mecânica da Votação 2/3", regra específica 6: só pode cancelar
    // enquanto mantiver o cargo de Administrador ativo.
    if (_buscarAdministradorAtivo(solicitanteEmail) == null) {
      throw const OperacaoNaoPermitidaException(
        'Você perdeu o direito de cancelar esta solicitação.',
      );
    }

    mockSolicitacoesPromocao[indice] = solicitacao.copyWith(
      status: StatusSolicitacaoPromocao.cancelada,
    );
  }

  AdminAccount? _buscarAdministradorAtivo(String email) {
    final conta = mockAdminAccounts.where((c) => c.email == email).firstOrNull;
    if (conta == null || !conta.ativo || conta.role != AdminRole.administrador) {
      return null;
    }
    return conta;
  }
}
