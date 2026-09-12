import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_auth_step_screen.dart';
import '../../../src/widgets/geoprag_countdown.dart';
import '../../../src/widgets/geoprag_otp_input.dart';
import '../core/admin_navigator.dart';
import 'auth_action_state.dart';
import 'verificar_codigo_sub_admin_cubit.dart';

/// Tela 3 · Fluxo B (Sub-Administrador) — verificação do código de 6
/// dígitos, liberado após a autorização do Administrador principal, com
/// janela de 15 minutos e uma segunda tentativa (que exige nova
/// autorização) antes do bloqueio de 24 horas.
class VerificarCodigoSubAdminScreen extends StatefulWidget {
  const VerificarCodigoSubAdminScreen({super.key});

  @override
  State<VerificarCodigoSubAdminScreen> createState() =>
      _VerificarCodigoSubAdminScreenState();
}

class _VerificarCodigoSubAdminScreenState
    extends State<VerificarCodigoSubAdminScreen> {
  static const _duracao = Duration(minutes: 15);

  bool _expirado = false;
  String _codigo = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificarCodigoSubAdminCubit, AuthActionState<Null>>(
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
          actionLabel = 'Solicitar nova redefinição';
          onAction = () =>
              AdminNavigatorScope.of(context).toAguardandoAutorizacao();
        } else {
          actionLabel = 'Confirmar código';
          onAction = _codigo.length == 6 && !isLoading
              ? () => context.read<VerificarCodigoSubAdminCubit>().submit(
                  code: _codigo,
                )
              : null;
        }

        return BaseAuthStepScreen(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verifique seu e-mail',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: GeopragColors.green900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Autorizado pelo Administrador. Código enviado.',
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
                        'Código expirado. Solicite uma nova autorização ao Administrador principal.',
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
