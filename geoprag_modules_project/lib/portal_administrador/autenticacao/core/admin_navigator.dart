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
  void toMapaBairro();

  void toAplicadores();
  void toAplicadorDetalhes();

  /// Único destino do módulo `gerenciamento_de_administradores` por ora —
  /// leva direto ao formulário de criação de novo administrador. Uma tela
  /// de listagem, se vier a existir, é decisão pendente de wireframe fora
  /// do escopo desta issue (ver GEOPRAG-46).
  void toGerenciamentoAdministradores();

  void toEstoque();
  void toEstoqueFormula();
  void toEstoqueLicitacao();
  void toEstoqueProduto();
  void toEstoqueVisualizacao();

  void toDistribuicoes();
  void toDistribuicaoCadastro();
  void toDistribuicaoVisualizacao();

  void toDenunciasAdmin();
  void toDenunciaAdminDetalhes();

  /// Substitui a rota atual pela tela de login (usado pelo "Sair" da sidebar).
  void toLogout();

  /// Limpa toda a pilha de navegação e volta para a tela de login (usado
  /// após concluir o fluxo de redefinição de senha).
  void toLoginResetStack();

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
