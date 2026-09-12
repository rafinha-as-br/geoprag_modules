import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_auth_step_screen.dart';
import '../../../src/widgets/geoprag_countdown.dart';
import '../../../src/widgets/geoprag_cpf_input.dart';
import '../../../src/widgets/geoprag_otp_input.dart';
import '../core/admin_navigator.dart';
import 'auth_action_state.dart';
import 'verificar_codigo_admin_cubit.dart';

/// Tela 2 · Fluxo C (Administrador principal) — verificação do código de 6
/// dígitos combinada com CPF, sem autorização de terceiros, dentro da
/// janela de 15 minutos (política de recuperação de senha para
/// Administradores e sub-Administradores).
class VerificarCodigoAdminScreen extends StatefulWidget {
  const VerificarCodigoAdminScreen({super.key});

  @override
  State<VerificarCodigoAdminScreen> createState() =>
      _VerificarCodigoAdminScreenState();
}

class _VerificarCodigoAdminScreenState
    extends State<VerificarCodigoAdminScreen> {
  static const _duracao = Duration(minutes: 15);

  final _cpfController = TextEditingController();
  bool _expirado = false;
  String _codigo = '';

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  bool get _podeConfirmar =>
      _codigo.length == 6 && _cpfController.text.length == 14;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificarCodigoAdminCubit, AuthActionState<Null>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<Null>) {
          AdminNavigatorScope.of(context).toRecriarSenha();
        } else if (state is AuthActionFailure<Null>) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthActionLoading<Null>;

        final String actionLabel;
        final VoidCallback? onAction;
        if (_expirado) {
          actionLabel = 'Reiniciar solicitação';
          onAction = () => AdminNavigatorScope.of(context).toEsqueciSenha();
        } else {
          actionLabel = 'Confirmar';
          onAction = _podeConfirmar && !isLoading
              ? () => context.read<VerificarCodigoAdminCubit>().submit(
                  code: _codigo,
                )
              : null;
        }

        return BaseAuthStepScreen(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Confirme sua identidade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: GeopragColors.green900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Verificação por e-mail + CPF, sem autorização de terceiros.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GeopragOtpInput(
                enabled: !_expirado,
                onCompleted: (code) => setState(() => _codigo = code),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: _expirado
                    ? Text(
                        'Código expirado.',
                        style: TextStyle(
                          color: GeopragColors.statusAtrasado,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      )
                    : GeopragCountdown(
                        duration: _duracao,
                        onExpired: () => setState(() => _expirado = true),
                      ),
              ),
              const SizedBox(height: 20),
              GeopragCpfInput(
                controller: _cpfController,
                enabled: !_expirado,
                decoration: InputDecoration(
                  hintText: '000.000.000-00',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          actionLabel: actionLabel,
          isLoading: !_expirado && isLoading,
          onAction: onAction,
        );
      },
    );
  }
}
