import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/administrador_repository.dart';
import '../core/resultado_solicitacao_promocao.dart';
import 'administrador_view_model.dart';
import 'administradores_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a listagem de administradores para o dashboard e executa as
/// ações de desativar e solicitar promoção (GEOPRAG-36).
class AdministradoresCubit extends Cubit<AdministradoresState> {
  AdministradoresCubit(this._repository) : super(const AdministradoresLoading()) {
    _carregar();
  }

  final AdministradorRepository _repository;

  Future<void> _carregar({String? avisoAcao}) async {
    try {
      final administradores = await _repository.listar();
      emit(
        AdministradoresLoaded(
          administradores.map(AdministradorViewModel.fromEntity).toList(),
          avisoAcao: avisoAcao,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit._carregar', e, stackTrace);
      emit(AdministradoresError(AppErrorMessages.carregamentoGenerico));
    }
  }

  Future<void> desativar({
    required String email,
    required String executorEmail,
  }) async {
    try {
      await _repository.desativar(email: email, executorEmail: executorEmail);
      await _carregar(avisoAcao: 'Cadastro desativado com sucesso.');
    } on EntidadeNaoEncontradaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } on OperacaoNaoPermitidaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit.desativar', e, stackTrace);
      await _carregar(avisoAcao: AppErrorMessages.carregamentoGenerico);
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
      await _carregar(avisoAcao: aviso);
    } on EntidadeNaoEncontradaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } on OperacaoNaoPermitidaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('AdministradoresCubit.solicitarPromocao', e, stackTrace);
      await _carregar(avisoAcao: AppErrorMessages.carregamentoGenerico);
    }
  }
}
