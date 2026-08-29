import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_auth_step_screen.dart';
import '../../core/aplicador_navigator.dart';
import '../core/usuario.dart';
import 'auth_action_state.dart';
import 'login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, AuthActionState<Usuario>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<Usuario>) {
          AplicadorNavigatorScope.of(context).toPonto();
        } else if (state is AuthActionFailure<Usuario>) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthActionLoading<Usuario>;
        return BaseAuthStepScreen(
          title: 'Entrar',
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(
                  Icons.lock_person_outlined,
                  size: 80,
                  color: GeopragColors.green900,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Acesso do Voluntário',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: GeopragColors.green900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: 'CPF ou E-mail',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        AplicadorNavigatorScope.of(context).toEsqueciSenha(),
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: GeopragColors.green900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionLabel: 'Entrar',
          isLoading: isLoading,
          onAction: isLoading
              ? null
              : () => context.read<LoginCubit>().submit(
                  identifier: _identifierController.text,
                  senha: _senhaController.text,
                ),
        );
      },
    );
  }
}
