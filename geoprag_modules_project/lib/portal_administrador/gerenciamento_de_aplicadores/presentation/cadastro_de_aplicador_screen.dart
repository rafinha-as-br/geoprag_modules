import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_exit_button.dart';
import '../../../src/widgets/geoprag_senha_gerada_dialog.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'criar_aplicador_cubit.dart';

/// Formulário de criação de novo Aplicador (GEOPRAG-65), migrado para
/// [BaseFormScreen] em GEOPRAG-102. Segue o mesmo padrão de tela, campos e
/// validações já usado na criação de Administrador
/// (`criacao_de_administrador_screen.dart`, GEOPRAG-36) — ver
/// [Módulo Gerenciamento de Aplicadores - Cadastro](https://rafinha84dev.atlassian.net/wiki/spaces/Geoprag/pages/38043682)
/// para a especificação completa.
///
/// Diferente do Administrador, o CEP é obrigatório aqui (alimenta o cadastro
/// do ponto de aplicação atribuído ao Aplicador) e não há campo de senha —
/// a senha inicial é gerada automaticamente (ver [CriarAplicadorCubit]).
class CadastroDeAplicadorScreen extends StatefulWidget {
  const CadastroDeAplicadorScreen({super.key});

  @override
  State<CadastroDeAplicadorScreen> createState() =>
      _CadastroDeAplicadorScreenState();
}

class _CadastroDeAplicadorScreenState extends State<CadastroDeAplicadorScreen>
    with FormDirtyState<CadastroDeAplicadorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Aplicador'),
        leading: GeopragExitButton(
          isDirty: dirty,
          onExit: () => AdminNavigatorScope.of(context).toAplicadores(),
        ),
      ),
      body: BlocListener<CriarAplicadorCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          final senha = context.read<CriarAplicadorCubit>().senhaGerada;
          // Só o próprio Cubit garante que `senha` está preenchida antes de
          // emitir sucesso — não há como o tipo expressar essa relação, daí
          // o guard em vez de um `!` direto.
          if (senha == null) return;
          GeopragSenhaGeradaDialog.mostrar(
            context,
            senha: senha,
            onConcluir: () {
              // GEOPRAG-65 (review Rafinha): esta tela é alcançada por
              // pushReplacement (destino de topo, não sub-rota), então não
              // há frame anterior para `.back()` — volta ao dashboard
              // explicitamente, onde o cadastro recém-criado já aparece na
              // listagem.
              AdminNavigatorScope.of(context).toAplicadores();
            },
          );
        },
        child: BaseFormScreen<CriarAplicadorCubit>(
          onChanged: marcarFormularioAlterado,
        ),
      ),
    );
  }
}
