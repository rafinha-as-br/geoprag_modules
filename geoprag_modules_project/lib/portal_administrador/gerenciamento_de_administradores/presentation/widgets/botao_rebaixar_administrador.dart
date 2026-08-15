import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../autenticacao/core/admin_account.dart';
import '../administrador_view_model.dart';
import '../administradores_cubit.dart';

/// Botão que rebaixa um Administrador a Sub-Administrador, com diálogo de
/// confirmação — extraído de `_AdministradorDetalheDialog` (feedback de
/// revisão do PR #9).
class BotaoRebaixarAdministrador extends StatelessWidget {
  final AdministradorViewModel administrador;
  final AdminAccount contaAtual;

  const BotaoRebaixarAdministrador({
    super.key,
    required this.administrador,
    required this.contaAtual,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmar(context),
      icon: const Icon(Icons.arrow_downward, color: Colors.orange),
      label: const Text('Rebaixar a Sub-Administrador'),
    );
  }

  Future<void> _confirmar(BuildContext context) async {
    final cubit = context.read<AdministradoresCubit>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rebaixar administrador'),
        content: Text(
          'Tem certeza que deseja rebaixar "${administrador.nome}" a '
          'Sub-Administrador? A ação é imediata e não passa por votação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Rebaixar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await cubit.rebaixar(
        email: administrador.email,
        executorEmail: contaAtual.email,
      );
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
