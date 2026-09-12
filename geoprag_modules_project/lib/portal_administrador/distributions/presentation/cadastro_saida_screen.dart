import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'cadastro_saida_cubit.dart';

/// Formulário de registro de nova saída de distribuição (GEOPRAG-24),
/// migrado para [BaseFormScreen] em GEOPRAG-104 — ver [CadastroSaidaCubit]
/// para o carregamento das opções e a persistência de verdade.
class CadastroSaidaScreen extends StatelessWidget {
  const CadastroSaidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nova Saída')),
      body: BlocListener<CadastroSaidaCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          // GEOPRAG-72: rota alcançada por pushReplacement (destino de topo,
          // não sub-rota) — não há frame anterior para `.back()`.
          AdminNavigatorScope.of(context).toDistribuicoes();
        },
        child: const BaseFormScreen<CadastroSaidaCubit>(),
      ),
    );
  }
}
