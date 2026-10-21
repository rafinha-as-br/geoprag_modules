import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_logger.dart';
import '../core/auth_repository.dart';
import '../core/usuario.dart';
import 'aplicador_sessao_state.dart';

/// Sessão do aplicador logado (GEOPRAG-187). Provido na raiz da árvore de
/// widgets, pelo mesmo motivo do `TenantCubit`: o `redirect` do GoRouter
/// precisa saber se há sessão antes de qualquer tela existir.
class AplicadorSessaoCubit extends Cubit<AplicadorSessaoState> {
  AplicadorSessaoCubit(this._repository)
    : super(const AplicadorSessaoSemAcesso());

  final AuthRepository _repository;

  /// Reabre a sessão guardada no aparelho, sem rede. Chamado uma vez, antes de
  /// o app aparecer.
  Future<void> restaurar() async {
    try {
      final usuario = await _repository.sessaoAtual();
      if (usuario != null) emit(AplicadorSessaoAutenticada(usuario));
    } catch (e, stackTrace) {
      AppLogger.error('AplicadorSessaoCubit.restaurar', e, stackTrace);
    }
  }

  void iniciarSessao(Usuario usuario) =>
      emit(AplicadorSessaoAutenticada(usuario));

  /// Logout voluntário: apaga a sessão do aparelho e volta ao estado sem acesso.
  Future<void> encerrarSessao() async {
    try {
      await _repository.logout();
    } catch (e, stackTrace) {
      AppLogger.error('AplicadorSessaoCubit.encerrarSessao', e, stackTrace);
    }
    emit(const AplicadorSessaoSemAcesso());
  }

  /// A API já apagou os tokens (refresh recusado): só falta voltar ao login.
  void sessaoPerdida() => emit(const AplicadorSessaoSemAcesso());
}
