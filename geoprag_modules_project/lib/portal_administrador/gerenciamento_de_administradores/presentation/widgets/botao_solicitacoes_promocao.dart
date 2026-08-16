import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../autenticacao/core/admin_navigator.dart';
import '../administradores_cubit.dart';
import '../solicitacoes_promocao_cubit.dart';
import '../solicitacoes_promocao_state.dart';
import 'geoprag_badge_button.dart';

/// Botão que leva à tela de Solicitações de Promoção, com indicador de
/// quantas solicitações em aberto ainda aguardam o voto do usuário atual
/// (RN "Promoção e Rebaixamento de Cargo de Administrador", seção 4, regra
/// 6). Separado em arquivo próprio dentro de `presentation/widgets`
/// (feedback de revisão do PR #9).
class BotaoSolicitacoesPromocao extends StatelessWidget {
  const BotaoSolicitacoesPromocao({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
      builder: (context, state) {
        final pendentes = state is SolicitacoesPromocaoLoaded
            ? state.solicitacoes
                  .where((s) => !s.jaVotei && !s.souOSolicitante)
                  .length
            : 0;
        return GeopragBadgeButton(
          icon: Icons.how_to_vote,
          label: 'Solicitações de Promoção',
          badgeCount: pendentes,
          onPressed: () async {
            await AdminNavigatorScope.of(
              context,
            ).toSolicitacoesPromocaoAdministrador();
            if (context.mounted) {
              // A votação nesta tela roda sobre uma instância própria de
              // SolicitacoesPromocaoCubit (rota separada) — recarrega tanto
              // o badge quanto a lista do Dashboard, já que um voto pode
              // resolver a promoção e mudar o cargo exibido (GEOPRAG-36,
              // QA GEOPRAG-TC-9).
              context.read<SolicitacoesPromocaoCubit>().recarregar();
              context.read<AdministradoresCubit>().recarregar();
            }
          },
        );
      },
    );
  }
}
