import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_senha_gerada_dialog.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../widgets/admin_scaffold.dart';
import 'criar_administrador_cubit.dart';

/// Formulário de criação de novo administrador (GEOPRAG-36), migrado para
/// [BaseFormScreen] em GEOPRAG-103. Acesso restrito a quem tem cargo
/// Administrador — o guard é aplicado no `redirect` do GoRouter
/// (`app_administrador/lib/main.dart`), não nesta tela.
///
/// Usa [AdminScaffold] como as demais telas do módulo — abre com o sidebar
/// comum, não como uma tela cheia isolada (feedback de revisão do PR #9).
///
/// O cargo do novo cadastro não é escolhido aqui: todo cadastro novo nasce
/// Sub-Administrador (ver [CriarAdministradorCubit]/`AdministradorRepository`).
class CriacaoDeAdministradorScreen extends StatelessWidget {
  const CriacaoDeAdministradorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/administradores/novo',
      appBar: AppBar(title: const Text('Registrar Novo Administrador')),
      body: BlocListener<CriarAdministradorCubit, BaseFormModel>(
        listenWhen: (previous, current) =>
            current.feedback is AcaoFeedbackSucesso &&
            previous.feedback != current.feedback,
        listener: (context, state) {
          final senha = context.read<CriarAdministradorCubit>().senhaGerada;
          // Só o próprio Cubit garante que `senha` está preenchida antes de
          // emitir sucesso — não há como o tipo expressar essa relação, daí
          // o guard em vez de um `!` direto.
          if (senha == null) return;
          GeopragSenhaGeradaDialog.mostrar(
            context,
            senha: senha,
            onConcluir: () {
              // GEOPRAG-68 (review Rafinha): esta tela é alcançada por
              // pushReplacement (destino de topo, não sub-rota) — não há
              // frame anterior para `.back()`, volta ao dashboard do módulo
              // explicitamente. Navegar só depois do dialog ser concluído.
              AdminNavigatorScope.of(context).toGerenciamentoAdministradores();
            },
          );
        },
        child: const BaseFormScreen<CriarAdministradorCubit>(),
      ),
    );
  }
}
