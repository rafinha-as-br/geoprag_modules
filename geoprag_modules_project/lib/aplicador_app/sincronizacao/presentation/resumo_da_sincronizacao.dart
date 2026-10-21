import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../nucleo_offline.dart';
import '../core/painel_de_sincronizacao.dart';
import 'sincronizacao_cubit.dart';
import 'botao_sincronizar_agora.dart';
import 'sincronizacao_screen.dart';
import 'sincronizacao_state.dart';
import 'textos_da_sincronizacao.dart';

/// Faixa fixa no topo de "Meus Pontos" (GEOPRAG-204): quantos registros estão
/// pendentes, quando foi a última sincronização e o botão "Sincronizar agora".
/// Tocar na faixa abre a lista de registros ([SincronizacaoScreen]).
///
/// Sem o núcleo offline aberto (`AplicadorBootstrap.iniciarNucleoOffline`), a
/// faixa não aparece: não há fila a mostrar. Por isso o cubit padrão é criado
/// aqui, a partir do núcleo; [criarCubit] existe para os testes.
class ResumoDaSincronizacao extends StatefulWidget {
  const ResumoDaSincronizacao({super.key, this.criarCubit});

  final SincronizacaoCubit Function()? criarCubit;

  @override
  State<ResumoDaSincronizacao> createState() => _ResumoDaSincronizacaoState();
}

class _ResumoDaSincronizacaoState extends State<ResumoDaSincronizacao> {
  SincronizacaoCubit? _cubit;

  @override
  void initState() {
    super.initState();
    final criar = widget.criarCubit;
    if (criar != null) {
      _cubit = criar();
      return;
    }
    final painel = _painelDoNucleo();
    if (painel != null) _cubit = SincronizacaoCubit(painel);
  }

  /// O painel do núcleo offline, ou `null` se ele ainda não foi aberto.
  static PainelDeSincronizacao? _painelDoNucleo() {
    try {
      return NucleoOffline.instancia.painel;
    } on StateError {
      return null;
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) return const SizedBox.shrink();
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<SincronizacaoCubit, SincronizacaoState>(
        builder: (context, state) => switch (state) {
          SincronizacaoLoaded() => _Faixa(state: state),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _Faixa extends StatelessWidget {
  const _Faixa({required this.state});

  final SincronizacaoLoaded state;

  @override
  Widget build(BuildContext context) {
    final situacao = state.situacao;
    final comPendentes = situacao.pendentes > 0;
    return Material(
      color: GeopragColors.blue600.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<SincronizacaoCubit>(),
              child: const SincronizacaoScreen(),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                comPendentes
                    ? Icons.cloud_upload_outlined
                    : Icons.cloud_done_outlined,
                size: 18,
                color: GeopragColors.blue600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textoDosPendentes(situacao.pendentes),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      textoDaUltimaSincronizacao(situacao.ultimaSincronizacao),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    if (state.aviso != null)
                      Text(
                        state.aviso!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GeopragColors.statusAtrasado,
                        ),
                      ),
                  ],
                ),
              ),
              BotaoSincronizarAgora(state: state),
            ],
          ),
        ),
      ),
    );
  }
}
