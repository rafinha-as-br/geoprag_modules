import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../src/state/acao_feedback.dart';
import '../../../../src/widgets/base_list_screen.dart';
import '../lote_de_pontos_reconciliacao.dart';
import '../ponto_de_aplicacao_view_model.dart';
import '../pontos_do_bairro_cubit.dart';
import 'batch_progress_dialog.dart';
import 'batch_reconcile_dialog.dart';

/// Barra de ações em lote da tela de Bairro (GEOPRAG-101) — "N
/// selecionado(s)" + botões Ativar/Desativar/Atribuir aplicador/Limpar
/// seleção. Reservada no layout via `BaseListScreenModel.batchActionBar`;
/// só fica visível (e clicável) quando há seleção, seguindo o mesmo motivo
/// documentado em `_BarraAcaoEmMassa` (`dashboard_aplicadores_screen.dart`,
/// GEOPRAG-67/130): manter a posição de tela estável entre um clique e o
/// próximo, em vez de a barra empurrar a tabela ao aparecer/sumir.
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
        return IgnorePointer(
          key: const Key('barraAcaoEmLotePontos_ignorePointer'),
          ignoring: quantidade == 0,
          child: Opacity(
            key: const Key('barraAcaoEmLotePontos_opacity'),
            opacity: quantidade == 0 ? 0 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    '$quantidade selecionado(s)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: processando
                        ? null
                        : () => _iniciarFluxo(context, AcaoEmLote.ativar),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ativar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: processando
                        ? null
                        : () => _iniciarFluxo(context, AcaoEmLote.desativar),
                    icon: const Icon(Icons.block),
                    label: const Text('Desativar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: processando
                        ? null
                        : () =>
                              _iniciarFluxo(context, AcaoEmLote.atribuirAplicador),
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Atribuir aplicador'),
                  ),
                  TextButton(
                    onPressed: processando ? null : cubit.limparSelecao,
                    child: const Text('Limpar seleção'),
                  ),
                  if (processando)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
