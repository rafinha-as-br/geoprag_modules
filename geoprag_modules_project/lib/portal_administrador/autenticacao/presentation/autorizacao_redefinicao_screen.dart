import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../core/admin_navigator.dart';
import '../core/solicitacao_redefinicao.dart';
import 'autorizacao_redefinicao_cubit.dart';
import 'autorizacao_redefinicao_state.dart';
import 'solicitacao_redefinicao_view_model.dart';

/// Tela 2b · Fluxo B (Sub-Administrador) — painel do Administrador
/// principal para autorizar ou negar a redefinição de senha de um
/// Sub-Administrador, com contato prévio obrigatório antes da autorização
/// (política de recuperação de senha para Administradores e
/// sub-Administradores).
class AutorizacaoRedefinicaoScreen extends StatelessWidget {
  const AutorizacaoRedefinicaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações de redefinição de senha')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocBuilder<
                  AutorizacaoRedefinicaoCubit,
                  AutorizacaoRedefinicaoState
                >(
                  builder: (context, state) {
                    return switch (state) {
                      AutorizacaoRedefinicaoLoading() => const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      AutorizacaoRedefinicaoError(:final message) => Text(
                        'Não foi possível carregar a solicitação: $message',
                        style: const TextStyle(color: GeopragColors.statusAtrasado),
                      ),
                      AutorizacaoRedefinicaoLoaded(:final solicitacao) =>
                        _SolicitacaoContent(solicitacao: solicitacao),
                    };
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SolicitacaoContent extends StatelessWidget {
  const _SolicitacaoContent({required this.solicitacao});

  final SolicitacaoRedefinicaoViewModel solicitacao;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: GeopragColors.neutralLight,
              child: Icon(Icons.person_outline, color: GeopragColors.green900),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    solicitacao.nomeSolicitante,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    solicitacao.cargo,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: solicitacao.status),
          ],
        ),
        const SizedBox(height: 20),
        if (solicitacao.status == StatusSolicitacaoRedefinicao.aguardando) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GeopragColors.statusAtrasado.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: GeopragColors.statusAtrasado.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: GeopragColors.statusAtrasado,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Entre em contato IMEDIATAMENTE com o usuário antes de autorizar.',
                    style: TextStyle(
                      color: GeopragColors.statusAtrasado,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<AutorizacaoRedefinicaoCubit>().autorizar(),
                  child: const Text('Autorizar redefinição'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<AutorizacaoRedefinicaoCubit>().negar(),
                  child: const Text('Negar'),
                ),
              ),
            ],
          ),
        ] else if (solicitacao.status ==
            StatusSolicitacaoRedefinicao.autorizado) ...[
          const Text(
            'Redefinição autorizada. O código de verificação foi enviado ao usuário.',
            style: TextStyle(
              color: GeopragColors.statusEmDia,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          // TODO(GEOPRAG-24): em produção, o Sub-Administrador é notificado
          // e continua o fluxo no próprio dispositivo dele — este atalho
          // simula essa continuação enquanto não há integração real entre
          // sessões/dispositivos.
          OutlinedButton.icon(
            onPressed: () => AdminNavigatorScope.of(
              context,
            ).toVerificarCodigoSubAdmin(),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar como Sub-Administrador'),
          ),
        ] else ...[
          const Text(
            'Solicitação negada. O usuário foi notificado.',
            style: TextStyle(
              color: GeopragColors.statusAtrasado,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StatusSolicitacaoRedefinicao status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      StatusSolicitacaoRedefinicao.aguardando => const GeopragStatusBadge(
        status: GeopragStatus.denuncia,
        label: 'Aguardando',
        dense: true,
      ),
      StatusSolicitacaoRedefinicao.autorizado => const GeopragStatusBadge(
        status: GeopragStatus.emDia,
        label: 'Autorizado',
        dense: true,
      ),
      StatusSolicitacaoRedefinicao.negado => const GeopragStatusBadge(
        status: GeopragStatus.atrasado,
        label: 'Negado',
        dense: true,
      ),
    };
  }
}
