import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../core/registro_sincronizavel.dart';
import 'botao_sincronizar_agora.dart';
import 'sincronizacao_cubit.dart';
import 'sincronizacao_state.dart';
import 'textos_da_sincronizacao.dart';

/// Tela "Sincronização": o que ainda não foi enviado, o que o servidor já
/// recebeu e o que ele recusou, com o motivo (GEOPRAG-204). Um registro
/// recusado é só de consulta: a tela não oferece nenhuma ação sobre ele.
///
/// Assume que um [SincronizacaoCubit] já foi provido acima na árvore de
/// widgets (ver `ResumoDaSincronizacao`, que abre esta tela).
class SincronizacaoScreen extends StatelessWidget {
  const SincronizacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronização')),
      body: BlocBuilder<SincronizacaoCubit, SincronizacaoState>(
        builder: (context, state) => switch (state) {
          SincronizacaoLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SincronizacaoError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center),
            ),
          ),
          SincronizacaoLoaded() => _Conteudo(state: state),
        },
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.state});

  final SincronizacaoLoaded state;

  @override
  Widget build(BuildContext context) {
    final registros = state.situacao.registros;
    // Posição 0: cabeçalho; depois, vazio ou um cartão por registro.
    final itens = registros.isEmpty ? 1 : registros.length;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1 + itens,
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _Cabecalho(state: state),
          );
        }
        if (registros.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Nenhum registro feito neste aparelho ainda.',
              textAlign: TextAlign.center,
            ),
          );
        }
        final registro = registros[indice - 1];
        return _CartaoDoRegistro(
          key: ValueKey(registro.id),
          registro: registro,
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.state});

  final SincronizacaoLoaded state;

  @override
  Widget build(BuildContext context) {
    final situacao = state.situacao;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textoDosPendentes(situacao.pendentes),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              textoDaUltimaSincronizacao(situacao.ultimaSincronizacao),
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (state.aviso != null) ...[
              const SizedBox(height: 8),
              Text(
                state.aviso!,
                style: const TextStyle(color: GeopragColors.statusAtrasado),
              ),
            ],
            const SizedBox(height: 12),
            BotaoSincronizarAgora(state: state),
          ],
        ),
      ),
    );
  }
}

class _CartaoDoRegistro extends StatelessWidget {
  const _CartaoDoRegistro({super.key, required this.registro});

  final RegistroSincronizavel registro;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    registro.pontoNome ?? 'Ponto de aplicação',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                GeopragStatusBadge(
                  status: registro.situacao.status,
                  label: registro.situacao.rotulo,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Registrado em ${formatarDataHora(registro.registradoEm)}',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            if (registro.motivo != null) ...[
              const SizedBox(height: 8),
              Text(
                registro.motivo!,
                style: const TextStyle(color: GeopragColors.statusAtrasado),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension on SituacaoDoRegistro {
  String get rotulo => switch (this) {
    SituacaoDoRegistro.pendente => 'Pendente',
    SituacaoDoRegistro.enviado => 'Enviado',
    SituacaoDoRegistro.rejeitado => 'Rejeitado',
  };

  GeopragStatus get status => switch (this) {
    SituacaoDoRegistro.pendente => GeopragStatus.denuncia,
    SituacaoDoRegistro.enviado => GeopragStatus.emDia,
    SituacaoDoRegistro.rejeitado => GeopragStatus.atrasado,
  };
}
