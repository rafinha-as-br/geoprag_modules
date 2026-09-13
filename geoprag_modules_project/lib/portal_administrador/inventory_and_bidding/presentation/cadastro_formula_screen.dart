import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_exit_button.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'criar_formula_cubit.dart';

/// Formulário de cadastro da fórmula de dosagem de BTI de um produto do
/// fabricante (GEOPRAG-105), migrado para [BaseFormScreen]. Ver
/// [CriarFormulaCubit] para a persistência de verdade.
class CadastroFormulaScreen extends StatefulWidget {
  const CadastroFormulaScreen({super.key});

  @override
  State<CadastroFormulaScreen> createState() => _CadastroFormulaScreenState();
}

class _CadastroFormulaScreenState extends State<CadastroFormulaScreen>
    with FormDirtyState<CadastroFormulaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fórmula de Dosagem (Fabricante)'),
        // GEOPRAG-150: X leva ao dashboard do módulo (Estoque), diferente do
        // sucesso de envio (que volta à listagem de fórmulas).
        leading: GeopragExitButton(
          isDirty: dirty,
          onExit: () => AdminNavigatorScope.of(context).toEstoque(),
        ),
      ),
      body: BlocListener<CriarFormulaCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          // GEOPRAG-72: rota alcançada por pushReplacement (destino de topo,
          // não sub-rota) — não há frame anterior para `.back()`.
          AdminNavigatorScope.of(context).toEstoqueFormula();
        },
        child: BaseFormScreen<CriarFormulaCubit>(
          onChanged: marcarFormularioAlterado,
        ),
      ),
    );
  }
}
