import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sincronizacao_cubit.dart';
import 'sincronizacao_state.dart';

/// Botão "Sincronizar agora"; fica desligado enquanto uma sincronização manual
/// está em andamento (GEOPRAG-204).
class BotaoSincronizarAgora extends StatelessWidget {
  const BotaoSincronizarAgora({super.key, required this.state});

  final SincronizacaoLoaded state;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: state.sincronizando
          ? null
          : () => context.read<SincronizacaoCubit>().sincronizarAgora(),
      icon: state.sincronizando
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      label: Text(state.sincronizando ? 'Sincronizando…' : 'Sincronizar agora'),
    );
  }
}
