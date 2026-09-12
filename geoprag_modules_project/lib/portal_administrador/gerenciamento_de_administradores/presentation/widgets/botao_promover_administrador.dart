import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../autenticacao/core/admin_account.dart';
import '../administrador_view_model.dart';
import '../administradores_cubit.dart';

/// Botão que abre a votação de promoção de um Sub-Administrador a
/// Administrador, com diálogo de confirmação — extraído de
/// `_AdministradorDetalheDialog` (feedback de revisão do PR #9).
class BotaoPromoverAdministrador extends StatelessWidget {
  final AdministradorViewModel administrador;
  final AdminAccount contaAtual;

  const BotaoPromoverAdministrador({
    super.key,
    required this.administrador,
    required this.contaAtual,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmar(context),
      icon: const Icon(Icons.arrow_upward, color: Colors.green),
      label: const Text('Promover a Administrador'),
    );
  }

  Future<void> _confirmar(BuildContext context) async {
    final cubit = context.read<AdministradoresCubit>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Solicitar promoção'),
        content: Text(
          'Abrir uma votação para promover "${administrador.nome}" a '
          'Administrador? A promoção exige aprovação de 2/3 dos demais '
          'Administradores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await cubit.solicitarPromocao(
        solicitanteEmail: contaAtual.email,
        subAdministradorEmail: administrador.email,
      );
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
