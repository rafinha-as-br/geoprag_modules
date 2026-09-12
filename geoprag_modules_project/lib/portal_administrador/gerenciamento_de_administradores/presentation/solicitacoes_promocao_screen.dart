import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/base_card_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'solicitacao_promocao_view_model.dart';
import 'solicitacoes_promocao_cubit.dart';
import 'solicitacoes_promocao_state.dart';

/// Tela de Solicitações de Promoção (GEOPRAG-36) — votação de 2/3 entre
/// Administradores, conforme RN "Promoção e Rebaixamento de Cargo de
/// Administrador" e "Mecânica da Votação 2/3". Só mostra a contagem
/// agregada de votos (sigilo do voto individual).
class SolicitacoesPromocaoScreen extends StatelessWidget {
  const SolicitacoesPromocaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/administradores/solicitacoes',
      appBar: AppBar(title: const Text('Solicitações de Promoção')),
      body: BlocListener<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
        listener: (context, state) {
          if (state is SolicitacoesPromocaoLoaded && state.avisoAcao != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.avisoAcao!)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Solicitações de Promoção em Aberto',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Durante a votação, só a contagem agregada de votos é '
                'exibida — a identidade de quem votou o quê não é '
                'mostrada a ninguém.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Expanded(
                child:
                    BlocBuilder<
                      SolicitacoesPromocaoCubit,
                      SolicitacoesPromocaoState
                    >(
                      builder: (context, state) {
                        return BaseCardListScreen<
                          SolicitacaoPromocaoViewModel
                        >(
                          model: BaseCardListScreenModel(
                            isLoading: state is SolicitacoesPromocaoLoading,
                            errorMessage: state is SolicitacoesPromocaoError
                                ? 'Não foi possível carregar as solicitações: ${state.message}'
                                : null,
                            items: state is SolicitacoesPromocaoLoaded
                                ? state.solicitacoes
                                : null,
                            itemBuilder: (context, solicitacao) =>
                                _SolicitacaoCard(solicitacao: solicitacao),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            emptyStateMessage:
                                'Nenhuma solicitação de promoção em aberto.',
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolicitacaoCard extends StatelessWidget {
  final SolicitacaoPromocaoViewModel solicitacao;

  const _SolicitacaoCard({required this.solicitacao});

  @override
  Widget build(BuildContext context) {
    final podeVotar = !solicitacao.jaVotei && !solicitacao.souOSolicitante;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Promoção de ${solicitacao.subAdministradorNome} a Administrador',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Solicitado por ${solicitacao.solicitanteNome}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ContadorVoto(
                  label: 'A favor',
                  valor: solicitacao.votosFavoraveis,
                  cor: Colors.green,
                ),
                const SizedBox(width: 16),
                _ContadorVoto(
                  label: 'Contra',
                  valor: solicitacao.votosContrarios,
                  cor: Colors.red,
                ),
                const SizedBox(width: 16),
                Text('Limiar de aprovação/reprovação: ${solicitacao.limiar}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (podeVotar) ...[
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<SolicitacoesPromocaoCubit>()
                        .votar(solicitacaoId: solicitacao.id, aprovar: true),
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Aprovar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<SolicitacoesPromocaoCubit>()
                        .votar(solicitacaoId: solicitacao.id, aprovar: false),
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('Reprovar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ] else if (solicitacao.jaVotei)
                  const Text(
                    'Você já votou nesta solicitação.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                const Spacer(),
                if (solicitacao.souOSolicitante)
                  TextButton(
                    onPressed: () => context
                        .read<SolicitacoesPromocaoCubit>()
                        .cancelar(solicitacao.id),
                    child: const Text('Cancelar solicitação'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContadorVoto extends StatelessWidget {
  final String label;
  final int valor;
  final Color cor;

  const _ContadorVoto({
    required this.label,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: $valor'),
      ],
    );
  }
}
