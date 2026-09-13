import 'package:flutter/material.dart';

import '../../src/widgets/base_interstitial_screen.dart';
import '../autenticacao/core/admin_navigator.dart';

/// Tela exibida quando o cargo da sessão atual não tem acesso a um módulo
/// inteiro (GEOPRAG-112). Como as demais rotas do Portal Administrador
/// (GEOPRAG-116), o sidebar não é montado aqui — quem provê o
/// `AdminScaffold` é o `ShellRoute` que envolve a rota; esta tela é só o
/// conteúdo do painel à direita.
class AcessoNegadoScreen extends StatelessWidget {
  final String mensagem;

  const AcessoNegadoScreen({
    super.key,
    this.mensagem = 'Seu cargo não tem acesso a este módulo.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
