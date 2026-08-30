import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_auth_step_screen.dart';
import '../../../src/widgets/geoprag_password_requirements.dart';
import '../core/admin_navigator.dart';
import 'admin_recriar_senha_cubit.dart';
import 'auth_action_state.dart';

/// Tela final · Fluxos B e C (Portal Administrador) — recriação de senha.
/// Reversível nas primeiras 24 horas via e-mail de alerta e implica logout
/// forçado de todos os dispositivos, conforme política de recuperação de
/// senha para Administradores e sub-Administradores.
class RecriarSenhaWebScreen extends StatefulWidget {
  const RecriarSenhaWebScreen({super.key});

  @override
  State<RecriarSenhaWebScreen> createState() => _RecriarSenhaWebScreenState();
}

class _RecriarSenhaWebScreenState extends State<RecriarSenhaWebScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    if (!GeopragPasswordRequirements(
      password: _senhaController.text,
    ).allSatisfied) {
      return;
    }

    context.read<AdminRecriarSenhaCubit>().submit(
      novaSenha: _senhaController.text,
    );
  }

  void _mostrarSucesso(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Senha alterada'),
        content: const Text(
          'Sua senha foi redefinida com sucesso. Reversível por 24h via e-mail de alerta. '
          'Todos os dispositivos foram desconectados.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                AdminNavigatorScope.of(context).toLoginResetStack(),
            child: const Text('Ir para o login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminRecriarSenhaCubit, AuthActionState<Null>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<Null>) {
          _mostrarSucesso(context);
        } else if (state is AuthActionFailure<Null>) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthActionLoading<Null>;
        return BaseAuthStepScreen(
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crie uma nova senha',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: GeopragColors.green900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reversível por 24h. Dispositivos desconectados.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure1 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarController,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: 'Confirme a nova senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GeopragPasswordRequirements(password: _senhaController.text),
              ],
            ),
          ),
          actionLabel: 'Salvar',
          isLoading: isLoading,
          onAction: isLoading ? null : _salvar,
        );
      },
    );
  }
}
