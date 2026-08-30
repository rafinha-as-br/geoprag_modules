import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../core/admin_navigator.dart';
import '../core/solicitacao_redefinicao.dart';
import 'autorizacao_redefinicao_cubit.dart';
import 'autorizacao_redefinicao_state.dart';

/// Tela 2 · Fluxo B (Sub-Administrador) — aguardando autorização do
/// Administrador principal, notificado por e-mail e painel, conforme
/// política de recuperação de senha para Administradores e
/// sub-Administradores.
///
/// Reflete o estado real da solicitação (via [AutorizacaoRedefinicaoCubit],
/// compartilhado com `autorizacao_redefinicao_screen.dart` desde a raiz do
/// app — GEOPRAG-89) em vez de simular sucesso incondicionalmente.
class AguardandoAutorizacaoScreen extends StatelessWidget {
  const AguardandoAutorizacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child:
                BlocBuilder<
                  AutorizacaoRedefinicaoCubit,
                  AutorizacaoRedefinicaoState
                >(
                  builder: (context, state) {
                    return switch (state) {
                      AutorizacaoRedefinicaoLoading() => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      AutorizacaoRedefinicaoError(:final message) => Text(
                        'Não foi possível carregar a solicitação: $message',
                        style: const TextStyle(
                          color: GeopragColors.statusAtrasado,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AutorizacaoRedefinicaoLoaded(:final solicitacao) =>
                        switch (solicitacao.status) {
                          StatusSolicitacaoRedefinicao.aguardando =>
                            const _Aguardando(),
                          StatusSolicitacaoRedefinicao.autorizado =>
                            const _Autorizado(),
                          StatusSolicitacaoRedefinicao.negado =>
                            const _Negado(),
                        },
                    };
                  },
                ),
          ),
        ),
      ),
    );
  }
}

class _Aguardando extends StatelessWidget {
  const _Aguardando();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.hourglass_top_outlined,
          size: 64,
          color: GeopragColors.green900,
        ),
        const SizedBox(height: 24),
        const Text(
          'Aguardando autorização',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: GeopragColors.green900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Administrador principal notificado por e-mail e painel.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const GeopragStatusBadge(
          status: GeopragStatus.denuncia,
          label: 'Pendente',
        ),
        const SizedBox(height: 40),
        // TODO(GEOPRAG-24): em produção esta tela reage a uma notificação
        // push/poll quando o Administrador principal decide — este atalho
        // simula a mudança de dispositivo enquanto não há integração real
        // de notificação entre dispositivos. O estado exibido acima, porém,
        // já reflete a solicitação real e compartilhada (GEOPRAG-89).
        OutlinedButton.icon(
          onPressed: () =>
              AdminNavigatorScope.of(context).toAutorizarRedefinicao(),
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: const Text('Ver painel do Administrador principal'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => AdminNavigatorScope.of(context).back(),
          child: const Text('Cancelar solicitação'),
        ),
      ],
    );
  }
}

class _Autorizado extends StatelessWidget {
  const _Autorizado();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 64,
          color: GeopragColors.statusEmDia,
        ),
        const SizedBox(height: 24),
        const Text(
          'Autorização concedida',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: GeopragColors.green900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'O Administrador principal autorizou sua redefinição de senha. '
          'O código de verificação foi enviado ao seu e-mail.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () =>
              AdminNavigatorScope.of(context).toVerificarCodigoSubAdmin(),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

class _Negado extends StatelessWidget {
  const _Negado();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.cancel_outlined,
          size: 64,
          color: GeopragColors.statusAtrasado,
        ),
        const SizedBox(height: 24),
        const Text(
          'Solicitação negada',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: GeopragColors.green900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'O Administrador principal negou esta solicitação de redefinição de senha.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => AdminNavigatorScope.of(context).back(),
          child: const Text('Voltar ao login'),
        ),
      ],
    );
  }
}
