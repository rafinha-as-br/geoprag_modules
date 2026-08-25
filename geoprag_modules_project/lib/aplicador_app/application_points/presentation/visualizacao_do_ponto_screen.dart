import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/aplicador_bottom_nav.dart';
import '../../../src/widgets/base_card_list_screen.dart';
import '../../core/aplicador_navigator.dart';
import 'ponto_de_aplicacao_cubit.dart';
import 'ponto_de_aplicacao_state.dart';
import 'ponto_de_aplicacao_view_model.dart';

/// Tela de visão geral do ponto de aplicação do aplicador logado.
///
/// Assume que um [PontoDeAplicacaoCubit] já foi provido acima na árvore de
/// widgets (ver `AplicadorBootstrap.buildPontoDeAplicacaoCubit` em
/// `bootstrap.dart`).
class VisualizacaoDoPontoScreen extends StatelessWidget {
  const VisualizacaoDoPontoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Ponto'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<PontoDeAplicacaoCubit, PontoDeAplicacaoState>(
        builder: (context, state) {
          return BaseCardListScreen<PontoDeAplicacaoViewModel>(
            model: BaseCardListScreenModel(
              isLoading: state is PontoDeAplicacaoLoading,
              errorMessage: state is PontoDeAplicacaoError
                  ? 'Não foi possível carregar o ponto: ${state.message}'
                  : null,
              items: state is PontoDeAplicacaoLoaded ? [state.ponto] : null,
              itemBuilder: (context, ponto) =>
                  _PontoDeAplicacaoContent(ponto: ponto),
              separatorBuilder: (context, index) => const SizedBox(),
            ),
          );
        },
      ),
      bottomNavigationBar: const AplicadorBottomNav(currentIndex: 0),
    );
  }
}

class _PontoDeAplicacaoContent extends StatelessWidget {
  const _PontoDeAplicacaoContent({required this.ponto});

  final PontoDeAplicacaoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    final statusColor = ponto.estaNoPrazo
        ? GeopragColors.statusEmDia
        : GeopragColors.statusAtrasado;
    final statusText = ponto.estaNoPrazo
        ? 'Ciclo no Prazo'
        : 'Aplicação Atrasada';
    final statusIcon = ponto.estaNoPrazo
        ? Icons.check_circle_outline
        : Icons.warning_amber_rounded;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bem-vindo, Voluntário!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aqui está o resumo do seu ponto de aplicação atual.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          // Application Point Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ponto.nomePonto,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ponto.referencia,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Última Aplicação',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  ponto.dataUltimaAplicacaoFormatada,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Próxima (Estimada)',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  ponto.dataProximaAplicacaoEstimadaFormatada,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AplicadorNavigatorScope.of(
                                context,
                              ).toAplicacaoInfo();
                            },
                            icon: const Icon(Icons.water_drop),
                            label: const Text('Registrar Aplicação'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: statusColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              AplicadorNavigatorScope.of(context).toPontoMarcar();
            },
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: const Text('Remarcar Ponto Inicial (GPS)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GeopragColors.green900,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
