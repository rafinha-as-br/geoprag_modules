import 'package:flutter/material.dart';

import 'geoprag_submit_button.dart';

/// Template de tela do arquétipo "autenticação/step único" (título opcional
/// → corpo do formulário → botão único de ação), hoje repetido nas 12 telas
/// de autenticação web e mobile (login, esqueci senha, verificar código,
/// recriar senha, aguardando autorização, autorização de redefinição,
/// landing).
///
/// [title] é opcional porque nem toda tela do arquétipo tem AppBar — as
/// telas centralizadas do portal do administrador (ex.:
/// `verificar_codigo_admin_screen.dart`, `esqueci_senha_web_screen.dart`)
/// não usam AppBar, enquanto as telas do app do aplicador (ex.:
/// `login_screen.dart`, `esqueci_senha_screen.dart`) usam. Quando `null`,
/// nenhum AppBar é renderizado.
///
/// [body] fica livre (`Widget`, não uma estrutura fixa de `Form`) pelo
/// mesmo motivo do `body` em [BaseInterstitialScreen]: os campos variam
/// muito entre telas (e-mail, CPF, OTP + countdown, senha + confirmação) —
/// o template só garante o container comum (`Center` +
/// `SingleChildScrollView` + `ConstrainedBox(maxWidth: 440)`).
///
/// A "ação de sucesso" configurável pedida para este template — navegar,
/// mostrar diálogo, ou nenhuma ação, as 3 variantes de feedback encontradas
/// entre `login_screen.dart`, `recriar_senha_screen.dart` e telas sem
/// submissão assíncrona — é o próprio [onAction]: como o resultado da
/// submissão chega de forma assíncrona via Cubit e cada tela hoje tem seu
/// próprio `XxxCubit`/`AuthActionState<T>` (sem um tipo base compartilhado
/// entre `aplicador_app` e `portal_administrador`), este template não tenta
/// ouvir esse estado — o chamador continua envolvendo o widget com seu
/// próprio `BlocListener`, exatamente como já faz hoje, decidindo ali
/// (navegar, abrir diálogo, ou nada) o que ocorre em caso de sucesso.
/// Unificar `AuthActionState<T>` entre módulos é escopo da migração
/// (GEOPRAG-89), não deste template.
class BaseAuthStepScreen extends StatelessWidget {
  final String? title;
  final Widget body;
  final String actionLabel;
  final bool isLoading;
  final VoidCallback? onAction;

  const BaseAuthStepScreen({
    super.key,
    this.title,
    required this.body,
    required this.actionLabel,
    required this.isLoading,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                body,
                const SizedBox(height: 24),
                GeopragSubmitButton(
                  label: actionLabel,
                  isLoading: isLoading,
                  onPressed: onAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
