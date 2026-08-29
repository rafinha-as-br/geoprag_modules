import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_search_field.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../autenticacao/presentation/admin_session_cubit.dart';
import '../../autenticacao/presentation/admin_session_state.dart';
import '../core/administrador_repository.dart';
import '../core/resultado_solicitacao_promocao.dart';
import 'administrador_detalhe_dialog.dart';
import 'administrador_view_model.dart';
import 'widgets/botao_solicitacoes_promocao.dart';
import 'widgets/geoprag_data_table.dart';

/// Carrega a listagem de administradores para o [BaseListScreen] e executa
/// as ações de desativar/reativar/rebaixar/solicitar promoção (GEOPRAG-36,
/// migrado para o template em GEOPRAG-90).
class AdministradoresCubit
    extends BaseListScreenController<AdministradorViewModel> {
  AdministradoresCubit(this._repository) : super(_initialModel()) {
    emit(
      state.copyWith(
        filter: GeopragSearchField(
          hintText: 'Buscar por nome, e-mail ou cargo...',
          onChanged: buscar,
        ),
      ),
    );
    _carregar();
  }

  final AdministradorRepository _repository;

  List<AdministradorViewModel> _todos = [];
  String _busca = '';

  static BaseListScreenModel<AdministradorViewModel> _initialModel() {
    return BaseListScreenModel<AdministradorViewModel>(
      title: 'Administradores Cadastrados',
      entityLabel: 'os administradores',
      emptyState: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhum administrador encontrado.'),
      ),
      actions: [
        const BotaoSolicitacoesPromocao(),
        Builder(
          builder: (context) => ElevatedButton.icon(
            onPressed: () async {
              await AdminNavigatorScope.of(context).toCriarAdministrador();
              if (context.mounted) {
                context.read<AdministradoresCubit>().recarregar();
              }
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Novo Administrador'),
          ),
        ),
      ],
      columns: [
        GeopragDataColumn(
          label: 'Nome',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, a) => Text(a.nome),
        ),
        GeopragDataColumn(
          label: 'E-mail',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, a) => Text(a.email),
        ),
        GeopragDataColumn(
          label: 'Cargo',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, a) => Text(a.cargoLabel),
        ),
        GeopragDataColumn(
          label: 'Status',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, a) => GeopragStatusBadge(
            status: a.ativo ? GeopragStatus.emDia : GeopragStatus.atrasado,
            label: a.ativo ? 'Ativo' : 'Desativado',
            dense: true,
          ),
        ),
        GeopragDataColumn(
          label: 'Detalhes',
          width: const FixedColumnWidth(56),
          cellBuilder: (context, a) => IconButton(
            key: ValueKey('detalhes-${a.email}'),
            icon: const Icon(Icons.visibility, color: Colors.blue),
            tooltip: 'Ver detalhes',
            onPressed: () {
              final sessionState = context.read<AdminSessionCubit>().state;
              showAdministradorDetalheDialog(
                context,
                administrador: a,
                contaAtual: sessionState is AdminSessionAutenticado
                    ? sessionState.conta
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Recarrega a listagem. Usado pelo Dashboard para se atualizar ao voltar
  /// de outra tela (criação, votação de promoção) que alterou o estado de um
  /// administrador por fora deste Cubit — como o GoRouter mantém esta rota
  /// (e este Cubit) viva por baixo da pilha de navegação, sem isso a lista
  /// ficava desatualizada até uma renavegação manual (GEOPRAG-36, QA
  /// GEOPRAG-TC-4/TC-9).
  Future<void> recarregar() => _carregar();

  Future<void> _carregar() async {
    emitLoading();
    try {
      _todos = (await _repository.listar())
          .map(AdministradorViewModel.fromEntity)
          .toList();
      emitItems(_filtrados());
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit._carregar', e, stackTrace);
      emitError(AppErrorMessages.carregamentoGenerico);
    }
  }

  /// Filtra a listagem carregada por nome, e-mail ou cargo — acionado pelo
  /// `TextField` do campo de busca (`filter` do model, aplicado via
  /// [buscaController]).
  void buscar(String query) {
    _busca = query.trim().toLowerCase();
    emitItems(_filtrados());
  }

  List<AdministradorViewModel> _filtrados() {
    if (_busca.isEmpty) return _todos;
    return _todos
        .where(
          (a) =>
              a.nome.toLowerCase().contains(_busca) ||
              a.email.toLowerCase().contains(_busca) ||
              a.cargoLabel.toLowerCase().contains(_busca),
        )
        .toList();
  }

  Future<void> desativar({
    required String email,
    required String executorEmail,
  }) async {
    try {
      await _repository.desativar(email: email, executorEmail: executorEmail);
      await _carregar();
      emitFeedback(
        const AcaoFeedbackSucesso('Cadastro desativado com sucesso.'),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } on OperacaoNaoPermitidaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit.desativar', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  Future<void> reativar({
    required String email,
    required String executorEmail,
  }) async {
    try {
      await _repository.reativar(email: email, executorEmail: executorEmail);
      await _carregar();
      emitFeedback(
        const AcaoFeedbackSucesso('Cadastro reativado com sucesso.'),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } on OperacaoNaoPermitidaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit.reativar', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  Future<void> rebaixar({
    required String email,
    required String executorEmail,
  }) async {
    try {
      await _repository.rebaixar(email: email, executorEmail: executorEmail);
      await _carregar();
      emitFeedback(
        const AcaoFeedbackSucesso(
          'Administrador rebaixado a Sub-Administrador com sucesso.',
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } on OperacaoNaoPermitidaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit.rebaixar', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  Future<void> solicitarPromocao({
    required String solicitanteEmail,
    required String subAdministradorEmail,
  }) async {
    try {
      final resultado = await _repository.solicitarPromocao(
        solicitanteEmail: solicitanteEmail,
        subAdministradorEmail: subAdministradorEmail,
      );
      final aviso = switch (resultado) {
        PromocaoAutomatica(:final conta) =>
          '${conta.nome} promovido(a) automaticamente a Administrador — '
              'não havia outros Administradores para votar.',
        SolicitacaoPromocaoAberta() =>
          'Votação de promoção aberta. Acompanhe em "Solicitações de '
              'Promoção".',
      };
      await _carregar();
      emitFeedback(AcaoFeedbackSucesso(aviso));
    } on EntidadeNaoEncontradaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } on OperacaoNaoPermitidaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit.solicitarPromocao', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }
}
