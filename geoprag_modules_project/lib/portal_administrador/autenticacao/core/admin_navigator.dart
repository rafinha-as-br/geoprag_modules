import 'package:flutter/widgets.dart';

/// Interface semântica de navegação do `portal_administrador`, um método por
/// destino hoje hardcoded via `Navigator.pushNamed`/`pushReplacementNamed`/
/// `pushNamedAndRemoveUntil`/`pop`. Implementada em cada app consumidor
/// (ex.: com `go_router`) e resolvida uma única vez na raiz da árvore de
/// widgets via [AdminNavigatorScope].
abstract class AdminNavigator {
  void toEsqueciSenha();
  void toAguardandoAutorizacao();
  void toAutorizarRedefinicao();
  void toVerificarCodigoSubAdmin();
  void toVerificarCodigoAdmin();
  void toRecriarSenha();

  void toDashboard();

  void toMapa();
  void toMapaBairro(String bairroId);

  void toAplicadores();
  void toAplicadorDetalhes(String aplicadorId);

  /// Formulário de criação de novo Aplicador (GEOPRAG-65).
  void toCriarAplicador();

  /// Dashboard do módulo `gestao_de_aplicacoes` — mapa geral de bairros
  /// (GEOPRAG-38).
  void toAplicacoes();

  /// Mapa + lista de aplicações de um bairro (GEOPRAG-38).
  void toAplicacaoBairro(String bairro);

  /// Detalhe de um ponto de aplicação — desativar, atribuir aplicador,
  /// editar (GEOPRAG-38).
  void toAplicacaoDetalhes(String pontoId);

  /// Formulário de criação de novo ponto de aplicação (GEOPRAG-38).
  void toAplicacaoCriarPonto();

  /// Dashboard do módulo `gerenciamento_de_administradores` — listagem,
  /// busca, desativação e solicitação de promoção (GEOPRAG-36).
  void toGerenciamentoAdministradores();

  /// Formulário de criação de novo administrador (nasce sempre
  /// Sub-Administrador). O `Future` completa quando a tela é fechada, para
  /// quem chamou poder recarregar dados que ela pode ter alterado
  /// (GEOPRAG-36, QA GEOPRAG-TC-4).
  Future<void> toCriarAdministrador();

  /// Tela de Solicitações de Promoção em aberto (votação de 2/3). O
  /// `Future` completa quando a tela é fechada, para quem chamou poder
  /// recarregar dados que ela pode ter alterado (GEOPRAG-36, QA
  /// GEOPRAG-TC-9).
  Future<void> toSolicitacoesPromocaoAdministrador();

  void toEstoque();
  void toEstoqueFormula();
  void toEstoqueLicitacao();
  void toEstoqueProduto();
  void toEstoqueVisualizacao(String produtoId);

  void toDistribuicoes();
  void toDistribuicaoCadastro();
  void toDistribuicaoVisualizacao(String distribuicaoId);

  void toDenunciasAdmin();
  void toDenunciaAdminDetalhes(String denunciaId);

  /// Substitui a rota atual pela tela de login (usado pelo "Sair" da sidebar).
  void toLogout();

  /// Limpa toda a pilha de navegação e volta para a tela de login (usado
  /// após concluir o fluxo de redefinição de senha).
  void toLoginResetStack();

  /// Volta um passo na pilha de navegação — só faz sentido no fluxo de
  /// recuperação de senha (`toEsqueciSenha`/`toAguardandoAutorizacao`/
  /// `toAutorizarRedefinicao`/`toVerificarCodigoSubAdmin`/
  /// `toVerificarCodigoAdmin`), o único que ainda empilha telas. Nenhuma
  /// tela pós-login do Portal Administrador deve chamar [back] — todo
  /// destino ali é alcançado como topo de pilha (implementações usam
  /// `pushReplacement`), então não há frame anterior para popar; volte
  /// chamando o método explícito do destino pretendido (ex.:
  /// `toAplicadores()`) — ver GEOPRAG-72.
  void back();
}

/// Resolve o [AdminNavigator] injetado na raiz da árvore de widgets do
/// `app_administrador`.
class AdminNavigatorScope extends InheritedWidget {
  final AdminNavigator navigator;

  const AdminNavigatorScope({
    super.key,
    required this.navigator,
    required super.child,
  });

  static AdminNavigator of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminNavigatorScope>();
    assert(scope != null, 'No AdminNavigatorScope found in context');
    return scope!.navigator;
  }

  @override
  bool updateShouldNotify(covariant AdminNavigatorScope oldWidget) {
    return navigator != oldWidget.navigator;
  }
}
