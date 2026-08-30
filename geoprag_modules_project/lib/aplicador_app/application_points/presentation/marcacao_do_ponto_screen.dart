import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_map_placeholder.dart';
import '../../core/aplicador_navigator.dart';
import 'marcacao_do_ponto_cubit.dart';

/// Tela de (re)marcação da localização inicial do ponto de aplicação via
/// GPS, migrada para [BaseFormScreen] (GEOPRAG-108).
///
/// A pré-visualização do mapa fica fora do template — `BaseFormScreen` é um
/// card de campos centralizado, sem espaço para a área de mapa em tela
/// cheia que esta tela sempre teve; e o botão "Cancelar" também fica fora
/// pelo mesmo motivo já registrado em `CadastroDoFocoScreen` (GEOPRAG-107):
/// o template não tem slot de ação secundária.
///
/// Assume que um [MarcacaoDoPontoCubit] já foi provido acima na árvore de
/// widgets (ver `AplicadorBootstrap.buildMarcacaoDoPontoCubit` em
/// `bootstrap.dart`).
class MarcacaoDoPontoScreen extends StatelessWidget {
  const MarcacaoDoPontoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marcação do Ponto Inicial')),
      body: BlocListener<MarcacaoDoPontoCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) =>
            AplicadorNavigatorScope.of(context).back(),
        // BaseFormScreen também escuta este mesmo Cubit (para rolar ao topo
        // em novo feedback) — as duas assinaturas reagem a gatilhos
        // diferentes e não se substituem.
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: GeopragMapPlaceholder(
                        message: '[Mapa Interativo]',
                        backgroundColor: Colors.grey,
                        borderColor: Colors.grey,
                        textColor: Colors.black54,
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: GeopragColors.green900.withOpacity(0.2),
                        border: Border.all(
                          color: GeopragColors.green900,
                          width: 2,
                        ),
                      ),
                    ),
                    const Icon(Icons.location_on, size: 48, color: Colors.red),
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 3,
              child: BaseFormScreen<MarcacaoDoPontoCubit>(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () => AplicadorNavigatorScope.of(context).back(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
