import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_exit_button.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'criar_ponto_de_aplicacao_cubit.dart';

/// Formulário de cadastro de Ponto de Aplicação. Ver
/// [CriarPontoDeAplicacaoCubit] para a persistência.
class CriacaoDePontoScreen extends StatefulWidget {
  const CriacaoDePontoScreen({super.key});

  @override
  State<CriacaoDePontoScreen> createState() => _CriacaoDePontoScreenState();
}

class _CriacaoDePontoScreenState extends State<CriacaoDePontoScreen>
    with FormDirtyState<CriacaoDePontoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Ponto de Aplicação'),
        leading: GeopragExitButton(
          isDirty: dirty,
          onExit: () => AdminNavigatorScope.of(context).toAplicacoes(),
        ),
      ),
      body: BlocListener<CriarPontoDeAplicacaoCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        // GEOPRAG-72: rota alcançada por pushReplacement — não há frame
        // anterior para `.back()`.
        listener: (context, state) =>
            AdminNavigatorScope.of(context).toAplicacoes(),
        child: BaseFormScreen<CriarPontoDeAplicacaoCubit>(
          onChanged: marcarFormularioAlterado,
        ),
      ),
    );
  }
}
