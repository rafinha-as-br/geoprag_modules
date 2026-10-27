import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/aplicador_bottom_nav.dart';
import '../../../src/widgets/base_card_list_screen.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../../portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_view_model.dart'
    show EstadoPontoDeAplicacaoApresentacao;
import '../../core/aplicador_navigator.dart';
import 'meus_pontos_cubit.dart';
import 'mensagem_de_atraso.dart';
import 'meus_pontos_state.dart';
import 'meus_pontos_view_model.dart';

/// Tela "Meus Pontos de Aplicação" — lista os pontos atribuídos ao
/// aplicador logado, ordenados por urgência (GEOPRAG-111).
///
/// Assume que um [MeusPontosCubit] já foi provido acima na árvore de
/// widgets (ver `AplicadorBootstrap.buildMeusPontosCubit` em
/// `bootstrap.dart`).
///
/// [resumoDaSincronizacao] é a faixa com os indicadores de sincronização
/// (GEOPRAG-204; ver `AplicadorBootstrap.buildResumoDaSincronizacao`). Vem de
/// fora porque a sincronização depende de pacotes que o portal web não carrega.
class MeusPontosScreen extends StatelessWidget {
  const MeusPontosScreen({super.key, this.resumoDaSincronizacao});

  final Widget? resumoDaSincronizacao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pontos de Aplicação')),
      body: Column(
        children: [
          resumoDaSincronizacao ?? const SizedBox.shrink(),
          Expanded(
            child: BlocBuilder<MeusPontosCubit, MeusPontosState>(
              builder: (context, state) {
                return BaseCardListScreen<PontoDoAplicadorResumoViewModel>(
                  model: BaseCardListScreenModel(
                    isLoading: state is MeusPontosLoading,
                    errorMessage: state is MeusPontosError
                        ? 'Não foi possível carregar seus pontos: ${state.message}'
                        : null,
                    items: state is MeusPontosLoaded ? state.pontos : null,
                    emptyStateMessage:
                        'Nenhum ponto de aplicação atribuído a você ainda.',
                    itemBuilder: (context, ponto) =>
                        _PontoDoAplicadorCard(ponto: ponto),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AplicadorBottomNav(currentIndex: 0),
    );
  }
}

class _PontoDoAplicadorCard extends StatelessWidget {
  const _PontoDoAplicadorCard({required this.ponto});

  final PontoDoAplicadorResumoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            AplicadorNavigatorScope.of(context).toPontoDetalhe(ponto.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ponto.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GeopragStatusBadge(
                    status: ponto.estado.status,
                    label: ponto.estado.rotulo,
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${ponto.identificador} · ${ponto.bairro}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.water_drop_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text('Dosagem: ${ponto.dosagemFormatada}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.timeline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${ponto.execucoesRegistradas}/${ponto.quantidadeDeSubpontos} subpontos',
                  ),
                ],
              ),
              if (ponto.emAtraso) ...[
                const SizedBox(height: 8),
                Row(
                  key: Key('meusPontosScreen_atraso_${ponto.id}'),
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: GeopragColors.statusAtrasado,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mensagemDeAtrasoDoPonto,
                        style: TextStyle(
                          color: GeopragColors.statusAtrasado,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (ponto.ativoSemRegistro) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: GeopragColors.statusAtrasado,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ativo e sem nenhuma aplicação registrada',
                      style: TextStyle(
                        color: GeopragColors.statusAtrasado,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
