import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_exit_button.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'criar_produto_cubit.dart';

/// Formulário de registro de entrada de produto/lote no estoque
/// (GEOPRAG-105), migrado para [BaseFormScreen]. Ver [CriarProdutoCubit]
/// para a persistência de verdade.
class CadastroProdutoScreen extends StatefulWidget {
  const CadastroProdutoScreen({super.key});

  @override
  State<CadastroProdutoScreen> createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen>
    with FormDirtyState<CadastroProdutoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Entrada de Produto'),
        leading: GeopragExitButton(
          isDirty: dirty,
          onExit: () => AdminNavigatorScope.of(context).toEstoque(),
        ),
      ),
      body: BlocListener<CriarProdutoCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          // GEOPRAG-72: rota alcançada por pushReplacement (destino de topo,
          // não sub-rota) — não há frame anterior para `.back()`.
          AdminNavigatorScope.of(context).toEstoque();
        },
        child: BaseFormScreen<CriarProdutoCubit>(
          onChanged: marcarFormularioAlterado,
        ),
      ),
    );
  }
}
