import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'criar_produto_cubit.dart';

/// Formulário de registro de entrada de produto/lote no estoque
/// (GEOPRAG-105), migrado para [BaseFormScreen]. Ver [CriarProdutoCubit]
/// para a persistência de verdade.
class CadastroProdutoScreen extends StatelessWidget {
  const CadastroProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Entrada de Produto')),
      body: BlocListener<CriarProdutoCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          // GEOPRAG-72: rota alcançada por pushReplacement (destino de topo,
          // não sub-rota) — não há frame anterior para `.back()`.
          AdminNavigatorScope.of(context).toEstoque();
        },
        child: const BaseFormScreen<CriarProdutoCubit>(),
      ),
    );
  }
}
