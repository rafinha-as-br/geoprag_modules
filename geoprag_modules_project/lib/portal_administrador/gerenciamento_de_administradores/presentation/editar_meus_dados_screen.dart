import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/base_form_screen.dart';
import '../../autenticacao/presentation/admin_session_cubit.dart';
import 'editar_meus_dados_cubit.dart';

/// Tela de edição dos próprios dados do administrador logado (GEOPRAG-148),
/// alcançada pelo dropdown de conta do rodapé do side menu (GEOPRAG-146).
class EditarMeusDadosScreen extends StatelessWidget {
  const EditarMeusDadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus dados')),
      body: BlocListener<EditarMeusDadosCubit, BaseFormModel>(
        // Dispara em qualquer mudança de feedback, não só sucesso: no
        // caminho de "sucesso parcial" (nome/e-mail salvos, troca de senha
        // falhou por senha atual incorreta), o Cubit emite um
        // AcaoFeedbackErro — mas contaAtualizada já foi preenchida antes
        // disso, e o side menu (GEOPRAG-146) precisa refletir o nome/e-mail
        // novos mesmo nesse caso.
        listenWhen: (previous, current) =>
            previous.feedback != current.feedback,
        listener: (context, state) {
          final contaAtualizada = context
              .read<EditarMeusDadosCubit>()
              .contaAtualizada;
          if (contaAtualizada != null) {
            context.read<AdminSessionCubit>().iniciarSessao(contaAtualizada);
          }
        },
        child: const BaseFormScreen<EditarMeusDadosCubit>(),
      ),
    );
  }
}
