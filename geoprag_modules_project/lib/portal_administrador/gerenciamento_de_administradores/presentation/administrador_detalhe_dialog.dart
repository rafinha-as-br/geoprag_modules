import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../autenticacao/core/admin_account.dart';
import 'administrador_view_model.dart';
import 'administradores_cubit.dart';
import 'widgets/geoprag_detail_dialog.dart';

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

/// Dialog com todos os dados cadastrais de um [AdministradorViewModel] e as
/// ações disponíveis para ele (desativar/reativar, promover, rebaixar) —
/// GEOPRAG-36. Substitui os ícones de ação que antes ficavam na coluna
/// "Ações" da tabela: agora a linha inteira abre este dialog, e as ações
/// vivem só aqui dentro.
Future<void> showAdministradorDetalheDialog(
  BuildContext context, {
  required AdministradorViewModel administrador,
  required AdminAccount? contaAtual,
}) {
  final cubit = context.read<AdministradoresCubit>();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: cubit,
      child: _AdministradorDetalheDialog(
        administrador: administrador,
        contaAtual: contaAtual,
      ),
    ),
  );
}

class _AdministradorDetalheDialog extends StatelessWidget {
  final AdministradorViewModel administrador;
  final AdminAccount? contaAtual;

  const _AdministradorDetalheDialog({
    required this.administrador,
    required this.contaAtual,
  });

  @override
  Widget build(BuildContext context) {
    return GeopragDetailDialog(
      title: administrador.nome,
      subtitle: administrador.cargoLabel,
      statusBadge: GeopragStatusBadge(
        status: administrador.ativo
            ? GeopragStatus.emDia
            : GeopragStatus.atrasado,
        label: administrador.ativo ? 'Ativo' : 'Desativado',
      ),
      banner: administrador.ativo
          ? null
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GeopragStatus.atrasado.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.block,
                    color: GeopragStatus.atrasado.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este cadastro está desativado desde '
                      '${administrador.dataDesativacao != null ? _formatarData(administrador.dataDesativacao!) : 'data desconhecida'}.',
                      style: TextStyle(color: GeopragStatus.atrasado.color),
                    ),
                  ),
                ],
              ),
            ),
      infoRows: [
        GeopragInfoRow(label: 'E-mail', valor: administrador.email),
        GeopragInfoRow(label: 'CPF', valor: administrador.cpf),
        GeopragInfoRow(
          label: 'Data de nascimento',
          valor: _formatarData(administrador.dataNascimento),
        ),
        GeopragInfoRow(label: 'Sexo', valor: administrador.sexo),
        GeopragInfoRow(label: 'Cargo', valor: administrador.cargoLabel),
        GeopragInfoRow(
          label: 'Cadastrado em',
          valor: _formatarData(administrador.dataCriacao),
        ),
        if (administrador.dataDesativacao != null)
          GeopragInfoRow(
            label: 'Última desativação',
            valor: _formatarData(administrador.dataDesativacao!),
          ),
      ],
      actions: contaAtual != null ? _buildAcoes(context) : const [],
    );
  }

  List<Widget> _buildAcoes(BuildContext context) {
    final acoes = <Widget>[];
    final contaAtualNaoNula = contaAtual!;

    if (administrador.ativo && !administrador.isAdministrador) {
      acoes.add(
        OutlinedButton.icon(
          onPressed: () => _confirmarPromocao(context, contaAtualNaoNula),
          icon: const Icon(Icons.arrow_upward, color: Colors.green),
          label: const Text('Promover a Administrador'),
        ),
      );
    }

    if (administrador.ativo &&
        administrador.isAdministrador &&
        contaAtualNaoNula.email != administrador.email) {
      acoes.add(
        OutlinedButton.icon(
          onPressed: () => _confirmarRebaixamento(context, contaAtualNaoNula),
          icon: const Icon(Icons.arrow_downward, color: Colors.orange),
          label: const Text('Rebaixar a Sub-Administrador'),
        ),
      );
    }

    if (administrador.ativo) {
      acoes.add(
        ElevatedButton.icon(
          onPressed: () => _confirmarDesativacao(context, contaAtualNaoNula),
          icon: const Icon(Icons.block),
          label: const Text('Desativar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else {
      acoes.add(
        ElevatedButton.icon(
          onPressed: () => _confirmarReativacao(context, contaAtualNaoNula),
          icon: const Icon(Icons.replay),
          label: const Text('Reativar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return acoes;
  }

  Future<void> _confirmarDesativacao(
    BuildContext context,
    AdminAccount contaAtual,
  ) async {
    final cubit = context.read<AdministradoresCubit>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar cadastro'),
        content: Text(
          'Tem certeza que deseja desativar o cadastro de "${administrador.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await cubit.desativar(
        email: administrador.email,
        executorEmail: contaAtual.email,
      );
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmarReativacao(
    BuildContext context,
    AdminAccount contaAtual,
  ) async {
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

  Future<void> _confirmarRebaixamento(
    BuildContext context,
    AdminAccount contaAtual,
  ) async {
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

  Future<void> _confirmarPromocao(
    BuildContext context,
    AdminAccount contaAtual,
  ) async {
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
