import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../src/permissions/capacidade.dart';
import '../autenticacao/presentation/admin_session_cubit.dart';

/// Botão de ação sujeito ao esquema de permissões por capacidade
/// (GEOPRAG-112). Nunca esconde a ação: ela aparece sempre visível e,
/// quando não pode ser executada, fica desabilitada com um [Tooltip]
/// explicando o motivo — seja por [capacidade] ausente no cargo atual, seja
/// por [desabilitadoPorEstado] (ex.: ponto já ativo, operação em
/// andamento).
class GatedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Capacidade capacidade;
  final VoidCallback onPressed;
  final bool desabilitadoPorEstado;
  final String? motivoDesabilitadoPorEstado;

  const GatedActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.capacidade,
    required this.onPressed,
    this.desabilitadoPorEstado = false,
    this.motivoDesabilitadoPorEstado,
  }) : assert(
         !desabilitadoPorEstado || motivoDesabilitadoPorEstado != null,
         'motivoDesabilitadoPorEstado é obrigatório quando '
         'desabilitadoPorEstado é true — a ação nunca deve ficar '
         'desabilitada sem explicação.',
       );

  @override
  Widget build(BuildContext context) {
    final podeExecutar = context.watch<AdminSessionCubit>().podeExecutar(
      capacidade,
    );

    final String? motivo = !podeExecutar
        ? 'Seu cargo não tem permissão para esta ação.'
        : desabilitadoPorEstado
        ? motivoDesabilitadoPorEstado
        : null;

    final button = OutlinedButton.icon(
      onPressed: motivo == null ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
    );

    return motivo == null ? button : Tooltip(message: motivo, child: button);
  }
}
