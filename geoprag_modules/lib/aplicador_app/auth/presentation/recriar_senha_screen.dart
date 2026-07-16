import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/geoprag_password_requirements.dart';
import '../../core/aplicador_navigator.dart';
import 'auth_action_state.dart';
import 'recriar_senha_cubit.dart';

/// Tela 3 · Fluxo A (Aplicador) — recriação de senha. Toda troca implica
/// logout forçado de todos os dispositivos e é reversível nas primeiras 24
/// horas via e-mail de alerta (política de recuperação de senha).
class RecriarSenhaScreen extends StatefulWidget {
  const RecriarSenhaScreen({super.key});

  @override
  State<RecriarSenhaScreen> createState() => _RecriarSenhaScreenState();
}

class _RecriarSenhaScreenState extends State<RecriarSenhaScreen> {
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
    ).allSatisfied)
      return;

    context.read<RecriarSenhaCubit>().submit(novaSenha: _senhaController.text);
  }

  void _mostrarSucesso(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Senha alterada'),
        content: const Text(
          'Sua senha foi redefinida com sucesso. Todos os dispositivos foram desconectados.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                AplicadorNavigatorScope.of(context).toLoginResetStack(),
            child: const Text('Ir para o login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecriarSenhaCubit, AuthActionState<Null>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<Null>) {
          _mostrarSucesso(context);
        } else if (state is AuthActionFailure<Null>) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Crie uma nova senha')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Crie uma nova senha',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: GeopragColors.green900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Todos os dispositivos serão desconectados.',
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
                    if (value != _senhaController.text)
                      return 'As senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GeopragPasswordRequirements(password: _senhaController.text),
                const SizedBox(height: 32),
                BlocBuilder<RecriarSenhaCubit, AuthActionState<Null>>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is AuthActionLoading<Null>
                          ? null
                          : _salvar,
                      child: state is AuthActionLoading<Null>
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Salvar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
