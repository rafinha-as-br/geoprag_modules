import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/geoprag_logo.dart';
import '../core/admin_navigator.dart';
import '../core/admin_account.dart';
import 'admin_login_cubit.dart';
import 'auth_action_state.dart';

class LoginScreenWeb extends StatefulWidget {
  const LoginScreenWeb({super.key});

  @override
  State<LoginScreenWeb> createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends State<LoginScreenWeb> {
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
    return BlocListener<AdminLoginCubit, AuthActionState<AdminAccount>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<AdminAccount>) {
          AdminNavigatorScope.of(context).toDashboard();
        } else if (state is AuthActionFailure<AdminAccount>) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/foto_aerea_gaspar.jpg',
              package: 'geoprag_modules',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Row(
              children: [
                // Left side: Branding / Landing Area
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GeopragColors.green900.withAlpha(235),
                          GeopragColors.green800.withAlpha(185),
                        ],
                      ),
                    ),
                    child: const SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GeopragMark(
                              size: 96,
                              variant: GeopragMarkVariant.light,
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Geoprag\nPortal do Servidor',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1.0,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Plataforma integrada de georreferenciamento e gestão operacional destinada ao apoio do programa municipal de controle do borrachudo no município de Gaspar.',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Right side: Login Form Area
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(64.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Acesso Restrito',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: GeopragColors.green900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Entre com suas credenciais de servidor da prefeitura',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 48),
                                TextFormField(
                                  controller: _identifierController,
                                  decoration: InputDecoration(
                                    labelText: 'CPF ou E-mail Institucional',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
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
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => AdminNavigatorScope.of(
                                      context,
                                    ).toEsqueciSenha(),
                                    child: const Text('Esqueci minha senha'),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                BlocBuilder<
                                  AdminLoginCubit,
                                  AuthActionState<AdminAccount>
                                >(
                                  builder: (context, state) {
                                    return ElevatedButton(
                                      onPressed:
                                          state
                                              is AuthActionLoading<AdminAccount>
                                          ? null
                                          : () => context
                                                .read<AdminLoginCubit>()
                                                .submit(
                                                  identifier:
                                                      _identifierController
                                                          .text,
                                                  senha: _senhaController.text,
                                                ),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                      ),
                                      child:
                                          state
                                              is AuthActionLoading<AdminAccount>
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Entrar no Portal',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
