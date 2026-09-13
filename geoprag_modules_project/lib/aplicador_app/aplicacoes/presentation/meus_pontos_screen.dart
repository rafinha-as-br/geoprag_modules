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
import 'meus_pontos_state.dart';
import 'meus_pontos_view_model.dart';

/// Tela "Meus Pontos de Aplicação" — lista os pontos atribuídos ao
/// aplicador logado, ordenados por urgência (GEOPRAG-111).
///
/// Assume que um [MeusPontosCubit] já foi provido acima na árvore de
/// widgets (ver `AplicadorBootstrap.buildMeusPontosCubit` em
/// `bootstrap.dart`).
class MeusPontosScreen extends StatelessWidget {
  const MeusPontosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pontos de Aplicação')),
      body: Column(
        children: [
          const _BannerOffline(),
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

/// Estrutura de UI para a futura sincronização offline (GEOPRAG-111: "fora
/// de escopo" o motor de persistência real — hoje não existe nenhum no
/// repositório) — sempre visível, sem lógica de conectividade por trás.
class _BannerOffline extends StatelessWidget {
  const _BannerOffline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: GeopragColors.blue600.withOpacity(0.08),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: GeopragColors.blue600),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Sincronização automática ainda não disponível — mantenha-se '
              'conectado à internet ao registrar aplicações.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
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
                  const Icon(Icons.water_drop_outlined, size: 16, color: Colors.grey),
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
