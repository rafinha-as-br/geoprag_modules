import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_auth_step_screen.dart';
import '../../../src/widgets/geoprag_countdown.dart';
import '../../../src/widgets/geoprag_otp_input.dart';
import '../../core/aplicador_navigator.dart';
import 'auth_action_state.dart';
import 'verificar_codigo_cubit.dart';

/// Tela 2 · Fluxo A (Aplicador) — verificação do código de 6 dígitos
/// enviado por e-mail, com janela de 15 minutos e uma segunda tentativa
/// permitida antes do bloqueio de 24 horas (política de recuperação de
/// senha para usuários Aplicadores).
class VerificarCodigoScreen extends StatefulWidget {
  const VerificarCodigoScreen({super.key});

  @override
  State<VerificarCodigoScreen> createState() => _VerificarCodigoScreenState();
}

class _VerificarCodigoScreenState extends State<VerificarCodigoScreen> {
  static const _duracao = Duration(minutes: 15);

  bool _expirado = false;
  bool _segundaTentativa = false;
  bool _bloqueado = false;
  String _codigo = '';
  Key _timerKey = UniqueKey();

  void _reenviarCodigo() {
    setState(() {
      _expirado = false;
      _segundaTentativa = true;
      _codigo = '';
      _timerKey = UniqueKey();
    });
  }

  void _onExpirado() {
    setState(() {
      if (_segundaTentativa) {
        _bloqueado = true;
      } else {
        _expirado = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificarCodigoCubit, AuthActionState<Null>>(
      listener: (context, state) {
        if (state is AuthActionSuccess<Null>) {
          AplicadorNavigatorScope.of(context).toRecriarSenha();
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
        final bool actionLoading;
        if (_bloqueado) {
          actionLabel = 'Voltar ao login';
          onAction = () =>
              AplicadorNavigatorScope.of(context).toLoginResetStack();
          actionLoading = false;
        } else if (_expirado) {
          actionLabel = 'Reenviar código (2ª tentativa)';
          onAction = _reenviarCodigo;
          actionLoading = false;
        } else {
          actionLabel = 'Confirmar código';
          onAction = _codigo.length == 6 && !isLoading
              ? () =>
                    context.read<VerificarCodigoCubit>().submit(code: _codigo)
              : null;
          actionLoading = isLoading;
        }

        return BaseAuthStepScreen(
          title: 'Verifique seu e-mail',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Verifique seu e-mail',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: GeopragColors.green900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Código de 6 dígitos enviado para jo***@exemplo.com.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_bloqueado)
                _buildBloqueado()
              else ...[
                GeopragOtpInput(
                  key: _timerKey,
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
                          ),
                        )
                      : GeopragCountdown(
                          key: _timerKey,
                          duration: _duracao,
                          onExpired: _onExpirado,
                        ),
                ),
              ],
            ],
          ),
          actionLabel: actionLabel,
          isLoading: actionLoading,
          onAction: onAction,
        );
      },
    );
  }

  Widget _buildBloqueado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.lock_clock_outlined,
          size: 56,
          color: GeopragColors.statusAtrasado,
        ),
        const SizedBox(height: 16),
        Text(
          'Não será possível redefinir a senha pelas próximas 24 horas.',
          style: TextStyle(
            color: GeopragColors.statusAtrasado,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
