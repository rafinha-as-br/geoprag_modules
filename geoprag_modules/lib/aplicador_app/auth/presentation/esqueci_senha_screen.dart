import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';
import 'auth_action_state.dart';
import 'esqueci_senha_cubit.dart';

/// Tela 1 · Fluxo A (Aplicador) — autoatendimento via e-mail cadastrado,
/// conforme política de recuperação de senha para usuários Aplicadores.
class EsqueciSenhaScreen extends StatefulWidget {
  const EsqueciSenhaScreen({super.key});

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EsqueciSenhaCubit, AuthActionState<Null>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<Null>) {
          AplicadorNavigatorScope.of(context).toVerificarCodigo();
        } else if (state is AuthActionFailure<Null>) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Esqueci minha senha')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.mail_lock_outlined,
                  size: 72,
                  color: GeopragColors.green900,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Esqueci minha senha',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: GeopragColors.green900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informe o e-mail cadastrado. Enviaremos um código de verificação.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'joao@exemplo.com',
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o e-mail cadastrado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<EsqueciSenhaCubit, AuthActionState<Null>>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is AuthActionLoading<Null>
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<EsqueciSenhaCubit>().submit(
                                  email: _emailController.text,
                                );
                              }
                            },
                      child: state is AuthActionLoading<Null>
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enviar código'),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'A senha só pode ser redefinida a cada 24 horas.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
