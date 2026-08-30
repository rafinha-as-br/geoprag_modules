import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'criar_licitacao_cubit.dart';

/// Formulário de registro de licitação/edital homologado (GEOPRAG-105),
/// migrado para [BaseFormScreen]. Ver [CriarLicitacaoCubit] para a
/// persistência de verdade.
class CadastroLicitacaoScreen extends StatelessWidget {
  const CadastroLicitacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Licitação/Edital')),
      body: BlocListener<CriarLicitacaoCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          // GEOPRAG-72: rota alcançada por pushReplacement (destino de topo,
          // não sub-rota) — não há frame anterior para `.back()`.
          AdminNavigatorScope.of(context).toEstoque();
        },
        child: const BaseFormScreen<CriarLicitacaoCubit>(),
      ),
    );
  }
}
