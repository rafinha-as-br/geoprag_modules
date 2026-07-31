import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/administrador_repository.dart';
import 'solicitacao_promocao_view_model.dart';
import 'solicitacoes_promocao_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega as solicitações de promoção em aberto e registra votos/
/// cancelamentos (GEOPRAG-36). [_usuarioAtualEmail] identifica quem está
/// logado — necessário para calcular se o usuário já votou em cada
/// solicitação e se pode cancelá-la.
class SolicitacoesPromocaoCubit extends Cubit<SolicitacoesPromocaoState> {
  SolicitacoesPromocaoCubit(this._repository, this._usuarioAtualEmail)
    : super(const SolicitacoesPromocaoLoading()) {
    _carregar();
  }

  final AdministradorRepository _repository;
  final String _usuarioAtualEmail;

  Future<void> _carregar({String? avisoAcao}) async {
    try {
      final solicitacoes = await _repository.listarSolicitacoesAbertas();
      final administradores = await _repository.listar();
      final nomesPorEmail = {
        for (final a in administradores) a.email: a.nome,
      };
      emit(
        SolicitacoesPromocaoLoaded(
          solicitacoes
              .map(
                (s) => SolicitacaoPromocaoViewModel.fromEntity(
                  s,
                  _usuarioAtualEmail,
                  nomesPorEmail,
                ),
              )
              .toList(),
          avisoAcao: avisoAcao,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('SolicitacoesPromocaoCubit._carregar', e, stackTrace);
      emit(SolicitacoesPromocaoError(AppErrorMessages.carregamentoGenerico));
    }
  }

  Future<void> votar({required String solicitacaoId, required bool aprovar}) async {
    try {
      await _repository.votar(
        solicitacaoId: solicitacaoId,
        votanteEmail: _usuarioAtualEmail,
        aprovar: aprovar,
      );
      await _carregar(
        avisoAcao: aprovar ? 'Voto de aprovação registrado.' : 'Voto de reprovação registrado.',
      );
    } on EntidadeNaoEncontradaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } on OperacaoNaoPermitidaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('SolicitacoesPromocaoCubit.votar', e, stackTrace);
      await _carregar(avisoAcao: AppErrorMessages.carregamentoGenerico);
    }
  }

  Future<void> cancelar(String solicitacaoId) async {
    try {
      await _repository.cancelarSolicitacao(
        solicitacaoId: solicitacaoId,
        solicitanteEmail: _usuarioAtualEmail,
      );
      await _carregar(avisoAcao: 'Solicitação de promoção cancelada.');
    } on EntidadeNaoEncontradaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } on OperacaoNaoPermitidaException catch (e) {
      await _carregar(avisoAcao: e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('SolicitacoesPromocaoCubit.cancelar', e, stackTrace);
      await _carregar(avisoAcao: AppErrorMessages.carregamentoGenerico);
    }
  }
}
