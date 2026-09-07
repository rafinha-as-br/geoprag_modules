import 'package:flutter/material.dart';

import '../../src/widgets/base_interstitial_screen.dart';
import '../autenticacao/core/admin_navigator.dart';
import 'admin_scaffold.dart';

/// Tela exibida quando o cargo da sessão atual não tem acesso a um módulo
/// inteiro (GEOPRAG-112) — mantém o sidebar (via [AdminScaffold]) para que o
/// usuário continue navegando pelo que ele pode acessar, em vez de um beco
/// sem saída.
class AcessoNegadoScreen extends StatelessWidget {
  final String currentRoute;
  final String mensagem;

  const AcessoNegadoScreen({
    super.key,
    required this.currentRoute,
    this.mensagem = 'Seu cargo não tem acesso a este módulo.',
  });

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: currentRoute,
      body: BaseInterstitialScreen(
        icon: Icons.lock_outline,
        iconColor: Colors.grey,
        title: 'Acesso negado',
        body: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        primaryLabel: 'Voltar ao início',
        onPrimary: () => AdminNavigatorScope.of(context).toDashboard(),
      ),
    );
  }
}
