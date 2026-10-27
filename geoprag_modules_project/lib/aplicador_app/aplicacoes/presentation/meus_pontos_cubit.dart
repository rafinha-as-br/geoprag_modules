import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../sincronizacao/core/servico_de_sincronizacao.dart';
import '../core/aplicador_ponto_de_aplicacao_repository.dart';
import 'meus_pontos_state.dart';
import 'meus_pontos_view_model.dart';

/// Carrega os pontos de aplicação atribuídos ao aplicador logado
/// (`aplicadorId`), ordenados por urgência.
///
/// Lê sempre do banco do aparelho (GEOPRAG-203), então a lista aparece sem
/// rede. [sincronizacao] abastece o banco: com o aparelho ainda sem nenhum
/// ponto (primeira carga, ou aplicador novo), o cubit pede uma sincronização e
/// espera por ela; se ela falha e continua sem nada para mostrar, é erro. Depois
/// disso, cada sincronização que termina ([aoSincronizar]: automática ou
/// "Sincronizar agora") relê a lista sem passar pelo carregamento.
class MeusPontosCubit extends Cubit<MeusPontosState> {
  MeusPontosCubit(
    this._repository,
    this._aplicadorId, {
    ServicoDeSincronizacao? sincronizacao,
    Stream<void>? aoSincronizar,
  }) : _sincronizacao = sincronizacao,
       super(const MeusPontosLoading()) {
    _assinatura = aoSincronizar?.listen((_) => _aoSincronizar());
    carregar();
  }

  final AplicadorPontoDeAplicacaoRepository _repository;
  final String _aplicadorId;
  final ServicoDeSincronizacao? _sincronizacao;
  StreamSubscription<void>? _assinatura;

  /// A carga completa está em curso: ela mesma relê o banco ao terminar.
  bool _carregando = false;

  Future<void> carregar() async {
    _carregando = true;
    emit(const MeusPontosLoading());
    try {
      var pontos = await _ler();
      var sincronizou = true;
      if (pontos.isEmpty && _sincronizacao != null) {
        sincronizou = await _sincronizar(_sincronizacao);
        pontos = await _ler();
      }
      if (isClosed) return;
      emit(
        pontos.isEmpty && !sincronizou
            ? const MeusPontosError(AppErrorMessages.semConexao)
            : MeusPontosLoaded(pontos),
      );
    } catch (e, stackTrace) {
      AppLogger.error('MeusPontosCubit.carregar', e, stackTrace);
      if (!isClosed) {
        emit(const MeusPontosError(AppErrorMessages.carregamentoGenerico));
      }
    } finally {
      _carregando = false;
    }
  }

  /// `true` se a sincronização concluiu; falha de rede não lança, e uma falha
  /// inesperada conta como não concluída.
  Future<bool> _sincronizar(ServicoDeSincronizacao servico) async {
    try {
      return (await servico.sincronizar()).concluida;
    } catch (e, stackTrace) {
      AppLogger.error('MeusPontosCubit._sincronizar', e, stackTrace);
      return false;
    }
  }

  /// Relê o banco depois de uma sincronização, sem piscar o carregamento. Sem
  /// nada para mostrar e já em erro, continua em erro: quem tem a tela de erro
  /// só sai dela com pontos ou ao tentar de novo.
  Future<void> _aoSincronizar() async {
    if (_carregando) return;
    try {
      final pontos = await _ler();
      if (isClosed || _carregando) return;
      if (pontos.isEmpty && state is MeusPontosError) return;
      emit(MeusPontosLoaded(pontos));
    } catch (e, stackTrace) {
      AppLogger.error('MeusPontosCubit._aoSincronizar', e, stackTrace);
    }
  }

  Future<List<PontoDoAplicadorResumoViewModel>> _ler() async {
    final pontos = await _repository.listarMeusPontos(_aplicadorId);
    final emAtraso = await _repository.idsDePontosEmAtraso(_aplicadorId);
    final ordenados = [...pontos]..sort(compararPontosDoAplicadorPorUrgencia);
    return [
      for (final ponto in ordenados)
        PontoDoAplicadorResumoViewModel.fromEntity(
          ponto,
          emAtraso: emAtraso.contains(ponto.id),
        ),
    ];
  }

  @override
  Future<void> close() {
    _assinatura?.cancel();
    return super.close();
  }
}
