import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../src/state/acao_feedback.dart';
import '../../../../src/widgets/base_list_screen.dart';
import '../../../../src/widgets/geoprag_barra_acao_em_lote.dart';
import '../lote_de_pontos_reconciliacao.dart';
import '../ponto_de_aplicacao_view_model.dart';
import '../pontos_do_bairro_cubit.dart';
import 'batch_progress_dialog.dart';
import 'batch_reconcile_dialog.dart';

/// Barra de ações em lote da tela de Bairro (GEOPRAG-101), sobre o widget
/// compartilhado [GeopragBarraAcaoEmLote] (GEOPRAG-141) — "N selecionado(s)"
/// + botões Ativar/Desativar/Atribuir aplicador/Limpar seleção. Reservada no
/// layout via `BaseListScreenModel.batchActionBar`.
///
/// Orquestra o fluxo dos dois diálogos (o Cubit nunca recebe
/// `BuildContext`): [BatchReconcileDialog] decide quem é elegível e coleta
/// o dado extra da ação (agendamento/aplicador); confirmando, o
/// [BatchProgressDialog] executa de fato, um ponto por vez.
class BarraAcaoEmLotePontos extends StatelessWidget {
  const BarraAcaoEmLotePontos({super.key, required this.cubit});

  final PontosDoBairroCubit cubit;

  Future<void> _iniciarFluxo(BuildContext context, AcaoEmLote acao) async {
    final reconciliacao = cubit.reconciliar(acao);
    List<AplicadorOpcao>? aplicadoresDisponiveis;
    if (acao == AcaoEmLote.atribuirAplicador) {
      aplicadoresDisponiveis = await cubit.listarAplicadoresDisponiveis();
    }
    if (!context.mounted) return;

    final confirmado = await showDialog<BatchReconcileConfirmado>(
      context: context,
      builder: (_) => BatchReconcileDialog(
        acao: acao,
        reconciliacao: reconciliacao,
        aplicadoresDisponiveis: aplicadoresDisponiveis,
      ),
    );
    if (confirmado == null || !reconciliacao.temElegiveis) return;
    if (!context.mounted) return;

    cubit.emitProcessandoAcaoEmLote(true);
    final resultado = await showDialog<BatchProgressResultado>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BatchProgressDialog(
        ids: [for (final item in reconciliacao.elegiveis) item.id],
        executarUm: (id) => cubit.executarUm(acao, id, confirmado),
      ),
    );
    cubit.emitProcessandoAcaoEmLote(false);
    await cubit.recarregarAposLote();

    if (resultado == null) return;
    cubit.emitFeedback(
      resultado.sucessoTotal
          ? AcaoFeedbackSucesso(
              '${resultado.sucesso.length} ponto(s) ${acao.participio} com sucesso.',
            )
          : resultado.falhaTotal
          ? AcaoFeedbackErro(
              'Não foi possível ${acao.rotulo} nenhum dos pontos selecionados.',
            )
          : AcaoFeedbackSucesso(
              '${resultado.sucesso.length} ponto(s) ${acao.participio}; '
              '${resultado.falhas.length} falharam.',
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      PontosDoBairroCubit,
      BaseListScreenModel<PontoDeAplicacaoResumoViewModel>
    >(
      bloc: cubit,
      builder: (context, state) {
        final quantidade = state.idsSelecionados.length;
        final processando = state.processandoAcaoEmLote;
        return GeopragBarraAcaoEmLote(
          ignorePointerKey: const Key('barraAcaoEmLotePontos_ignorePointer'),
          opacityKey: const Key('barraAcaoEmLotePontos_opacity'),
          limparSelecaoKey: const Key('barraAcaoEmLotePontos_limparSelecao'),
          quantidade: quantidade,
          processando: processando,
          onLimparSelecao: cubit.limparSelecao,
          acoes: [
            GeopragAcaoEmLoteBotao(
              key: const Key('barraAcaoEmLotePontos_ativar'),
              icon: Icons.check_circle_outline,
              label: 'Ativar',
              onPressed: processando
                  ? null
                  : () => _iniciarFluxo(context, AcaoEmLote.ativar),
            ),
            GeopragAcaoEmLoteBotao(
              key: const Key('barraAcaoEmLotePontos_desativar'),
              icon: Icons.block,
              label: 'Desativar',
              onPressed: processando
                  ? null
                  : () => _iniciarFluxo(context, AcaoEmLote.desativar),
            ),
            GeopragAcaoEmLoteBotao(
              key: const Key('barraAcaoEmLotePontos_atribuirAplicador'),
              icon: Icons.person_add_alt,
              label: 'Atribuir aplicador',
              onPressed: processando
                  ? null
                  : () => _iniciarFluxo(context, AcaoEmLote.atribuirAplicador),
            ),
          ],
        );
      },
    );
  }
}
