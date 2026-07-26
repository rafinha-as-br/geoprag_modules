import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/geoprag_logo.dart';
import '../../core/admin_navigator.dart';
import '../core/admin_account.dart';
import 'admin_esqueci_senha_cubit.dart';
import 'auth_action_state.dart';

/// Tela 1 · Fluxos B e C (Portal Administrador) — ponto de entrada único do
/// "esqueci minha senha" web. O papel da conta (Administrador principal ou
/// Sub-Administrador) define o restante do fluxo, resolvido pelo
/// [AdminEsqueciSenhaCubit].
class EsqueciSenhaWebScreen extends StatefulWidget {
  const EsqueciSenhaWebScreen({super.key});

  @override
  State<EsqueciSenhaWebScreen> createState() => _EsqueciSenhaWebScreenState();
}

class _EsqueciSenhaWebScreenState extends State<EsqueciSenhaWebScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _prosseguir() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AdminEsqueciSenhaCubit>().submit(email: _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminEsqueciSenhaCubit, AuthActionState<AdminRole>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<AdminRole>) {
          final navigator = AdminNavigatorScope.of(context);
          if (state.data == AdminRole.administrador) {
            navigator.toVerificarCodigoAdmin();
          } else {
            navigator.toAguardandoAutorizacao();
          }
        } else if (state is AuthActionFailure<AdminRole>) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: GeopragLogo(markSize: 40)),
                    const SizedBox(height: 32),
                    const Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: GeopragColors.green900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verificação por e-mail institucional, sem autorização de terceiros para o '
                      'Administrador principal; requer autorização do Administrador principal para '
                      'contas de Sub-Administrador.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'nome@gaspar.sc.gov.br',
                        prefixIcon: const Icon(Icons.mail_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o e-mail institucional cadastrado';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Demonstração: admin@gaspar.sc.gov.br (Administrador) ou '
                      'celia.ramos@gaspar.sc.gov.br (Sub-Administrador).',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<
                      AdminEsqueciSenhaCubit,
                      AuthActionState<AdminRole>
                    >(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is AuthActionLoading<AdminRole>
                              ? null
                              : _prosseguir,
                          child: state is AuthActionLoading<AdminRole>
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Solicitar redefinição'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => AdminNavigatorScope.of(context).back(),
                        child: const Text('Voltar ao login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
