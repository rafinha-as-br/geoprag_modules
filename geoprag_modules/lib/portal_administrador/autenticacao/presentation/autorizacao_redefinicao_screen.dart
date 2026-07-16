import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../core/admin_navigator.dart';

enum _StatusAutorizacao { aguardando, autorizado, negado }

/// Tela 2b · Fluxo B (Sub-Administrador) — painel do Administrador
/// principal para autorizar ou negar a redefinição de senha de um
/// Sub-Administrador, com contato prévio obrigatório antes da autorização
/// (política de recuperação de senha para Administradores e
/// sub-Administradores).
class AutorizacaoRedefinicaoScreen extends StatefulWidget {
  const AutorizacaoRedefinicaoScreen({super.key});

  @override
  State<AutorizacaoRedefinicaoScreen> createState() =>
      _AutorizacaoRedefinicaoScreenState();
}

class _AutorizacaoRedefinicaoScreenState
    extends State<AutorizacaoRedefinicaoScreen> {
  _StatusAutorizacao _status = _StatusAutorizacao.aguardando;

  void _negar() {
    setState(() => _status = _StatusAutorizacao.negado);
  }

  void _autorizar() {
    setState(() => _status = _StatusAutorizacao.autorizado);
  }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: GeopragColors.neutralLight,
                          child: Icon(
                            Icons.person_outline,
                            color: GeopragColors.green900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Célia Ramos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Sub-Administrador',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_status == _StatusAutorizacao.aguardando) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GeopragColors.statusAtrasado.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GeopragColors.statusAtrasado.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: GeopragColors.statusAtrasado,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
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
                              onPressed: _autorizar,
                              child: const Text('Autorizar redefinição'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _negar,
                              child: const Text('Negar'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_status == _StatusAutorizacao.autorizado) ...[
                      Text(
                        'Redefinição autorizada. O código de verificação foi enviado ao usuário.',
                        style: TextStyle(
                          color: GeopragColors.statusEmDia,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => AdminNavigatorScope.of(
                          context,
                        ).toVerificarCodigoSubAdmin(),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'Continuar como Sub-Administrador (Mock)',
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Solicitação negada. O usuário foi notificado.',
                        style: TextStyle(
                          color: GeopragColors.statusAtrasado,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (_status) {
      case _StatusAutorizacao.aguardando:
        return const GeopragStatusBadge(
          status: GeopragStatus.denuncia,
          label: 'Aguardando',
          dense: true,
        );
      case _StatusAutorizacao.autorizado:
        return const GeopragStatusBadge(
          status: GeopragStatus.emDia,
          label: 'Autorizado',
          dense: true,
        );
      case _StatusAutorizacao.negado:
        return const GeopragStatusBadge(
          status: GeopragStatus.atrasado,
          label: 'Negado',
          dense: true,
        );
    }
  }
}
