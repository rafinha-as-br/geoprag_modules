import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../autenticacao/core/admin_account.dart';
import '../administrador_view_model.dart';
import '../administradores_cubit.dart';

/// Botão que reativa um cadastro de administrador desativado, com diálogo
/// de confirmação — extraído de `_AdministradorDetalheDialog` (feedback de
/// revisão do PR #9).
class BotaoReativarAdministrador extends StatelessWidget {
  final AdministradorViewModel administrador;
  final AdminAccount contaAtual;

  const BotaoReativarAdministrador({
    super.key,
    required this.administrador,
    required this.contaAtual,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _confirmar(context),
      icon: const Icon(Icons.replay),
      label: const Text('Reativar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _confirmar(BuildContext context) async {
    final cubit = context.read<AdministradoresCubit>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reativar cadastro'),
        content: Text(
          'Tem certeza que deseja reativar o cadastro de "${administrador.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reativar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await cubit.reativar(
        email: administrador.email,
        executorEmail: contaAtual.email,
      );
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
