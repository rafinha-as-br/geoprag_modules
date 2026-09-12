import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../core/aplicador_navigator.dart';
import 'criar_denuncia_de_foco_cubit.dart';

/// Formulário de registro de denúncia de foco de infestação (GEOPRAG-107),
/// migrado para [BaseFormScreen]. Ver [CriarDenunciaDeFocoCubit] para a
/// validação e persistência de verdade.
///
/// O botão "Cancelar" fica fora do template — `BaseFormScreen` não tem um
/// slot de ação secundária (diferente de `BaseInterstitialScreen`), e essa
/// tela precisa da opção de desistir sem enviar.
class CadastroDoFocoScreen extends StatelessWidget {
  const CadastroDoFocoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Denúncia')),
      body: BlocListener<CriarDenunciaDeFocoCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          AplicadorNavigatorScope.of(context).toDenuncias();
        },
        child: Column(
          children: [
            const Expanded(
              child: BaseFormScreen<CriarDenunciaDeFocoCubit>(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () => AplicadorNavigatorScope.of(context).back(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
