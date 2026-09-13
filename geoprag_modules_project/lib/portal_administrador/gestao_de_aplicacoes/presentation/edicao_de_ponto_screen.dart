import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'editar_ponto_de_aplicacao_cubit.dart';

/// Formulário de edição de um Ponto de Aplicação já cadastrado (GEOPRAG-109).
/// Ver [EditarPontoDeAplicacaoCubit] para a persistência e o predicado de
/// bloqueio de campos.
class EdicaoDePontoScreen extends StatelessWidget {
  const EdicaoDePontoScreen({super.key, required this.pontoId});

  final String pontoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ponto de Aplicação')),
      body: BlocListener<EditarPontoDeAplicacaoCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) =>
            AdminNavigatorScope.of(context).toAplicacaoDetalhes(pontoId),
        child: const BaseFormScreen<EditarPontoDeAplicacaoCubit>(),
      ),
    );
  }
}
