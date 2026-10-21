import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../core/painel_de_sincronizacao.dart';
import 'sincronizacao_state.dart';

/// Indicadores de sincronização do App Aplicador (GEOPRAG-204): situação de
/// cada registro, contador de pendentes, horário da última sincronização e a
/// ação "Sincronizar agora". Atualiza sozinho quando uma sincronização termina.
class SincronizacaoCubit extends Cubit<SincronizacaoState> {
  SincronizacaoCubit(this._painel) : super(const SincronizacaoLoading()) {
    // Uma sincronização que termina sozinha encerra o aviso de uma ação manual
    // anterior que não deu certo.
    _assinatura = _painel.aoMudar.listen((_) => carregar(limparAviso: true));
    carregar();
  }

  static const String avisoSemSincronizar =
      'Não foi possível sincronizar agora. Seus registros continuam salvos e '
      'serão enviados quando houver conexão.';

  final PainelDeSincronizacao _painel;
  StreamSubscription<void>? _assinatura;
  int _ultimaCarga = 0;

  Future<void> carregar({bool limparAviso = false}) async {
    // Cargas podem terminar fora de ordem: só a mais recente vale.
    final numero = ++_ultimaCarga;
    try {
      final situacao = await _painel.carregar();
      if (isClosed || numero != _ultimaCarga) return;
      final atual = state;
      emit(
        atual is SincronizacaoLoaded
            ? atual.copiarCom(
                situacao: situacao,
                aviso: limparAviso ? () => null : null,
              )
            : SincronizacaoLoaded(situacao: situacao),
      );
    } catch (e, stackTrace) {
      AppLogger.error('SincronizacaoCubit.carregar', e, stackTrace);
      // Uma lista já na tela continua valendo; só a primeira carga falha.
      if (!isClosed &&
          numero == _ultimaCarga &&
          state is! SincronizacaoLoaded) {
        emit(const SincronizacaoError(AppErrorMessages.carregamentoGenerico));
      }
    }
  }

  Future<void> sincronizarAgora() async {
    final atual = state;
    if (atual is! SincronizacaoLoaded || atual.sincronizando) return;
    emit(atual.copiarCom(sincronizando: true, aviso: () => null));
    var concluida = false;
    try {
      concluida = await _painel.sincronizarAgora();
    } catch (e, stackTrace) {
      AppLogger.error('SincronizacaoCubit.sincronizarAgora', e, stackTrace);
    }
    if (isClosed) return;
    await carregar();
    if (isClosed) return;
    final depois = state;
    if (depois is SincronizacaoLoaded) {
      emit(
        depois.copiarCom(
          sincronizando: false,
          aviso: () => concluida ? null : avisoSemSincronizar,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _assinatura?.cancel();
    return super.close();
  }
}
