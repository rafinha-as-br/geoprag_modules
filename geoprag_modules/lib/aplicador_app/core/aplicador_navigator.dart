import 'package:flutter/widgets.dart';

/// Interface semântica de navegação do `aplicador_app`, um método por
/// destino hoje hardcoded via `Navigator.pushNamed`/`pop`. Implementada em
/// cada app consumidor (ex.: com `go_router`) e resolvida uma única vez na
/// raiz da árvore de widgets via [AplicadorNavigatorScope].
abstract class AplicadorNavigator {
  void toLogin();
  void toEsqueciSenha();
  void toVerificarCodigo();
  void toRecriarSenha();
  void toLoginResetStack();

  void toPonto();
  void toPontoMarcar();

  void toAplicacaoInfo();
  void toAplicacaoGeo();
  void toAplicacaoRegistrar();

  void toInventario();
  void toRecebimentos();
  void toRecebimentoConfirmar();

  void toDenuncias();
  void toDenunciaEducativa();
  void toDenunciaNova();

  void back();
}

/// Resolve o [AplicadorNavigator] injetado na raiz da árvore de widgets do
/// `app_aplicador`.
class AplicadorNavigatorScope extends InheritedWidget {
  final AplicadorNavigator navigator;

  const AplicadorNavigatorScope({
    super.key,
    required this.navigator,
    required super.child,
  });

  static AplicadorNavigator of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AplicadorNavigatorScope>();
    assert(scope != null, 'No AplicadorNavigatorScope found in context');
    return scope!.navigator;
  }

  @override
  bool updateShouldNotify(covariant AplicadorNavigatorScope oldWidget) {
    return navigator != oldWidget.navigator;
  }
}
