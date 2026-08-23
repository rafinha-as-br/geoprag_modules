import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/usuario.dart';
import '../../gestao_de_aplicadores/core/aplicador_repository.dart';
import '../core/ponto_de_aplicacao_repository.dart';
import 'ponto_de_aplicacao_detalhe_state.dart';
import 'view_models/aplicador_opcao_view_model.dart';
import 'view_models/ponto_de_aplicacao_detalhe_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega o detalhe de um ponto de aplicação específico (`pontoId`) e
/// executa as ações de gestão (desativar, atribuir/desatribuir aplicador).
class PontoDeAplicacaoDetalheCubit extends Cubit<PontoDeAplicacaoDetalheState> {
  PontoDeAplicacaoDetalheCubit(
    this._repository,
    this._aplicadorRepository,
    this._pontoId,
  ) : super(const PontoDeAplicacaoDetalheLoading()) {
    _carregar();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final AplicadorRepository _aplicadorRepository;
  final String _pontoId;

  Future<void> _carregar() async {
    try {
      final ponto = await _repository.buscarPorId(_pontoId);
      final nomeDoAplicador = await _resolverNomeAplicador(ponto.aplicadorId);
      emit(
        PontoDeAplicacaoDetalheLoaded(
          PontoDeAplicacaoDetalheViewModel.fromEntity(
            ponto,
            nomeDoAplicador: nomeDoAplicador,
          ),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(PontoDeAplicacaoDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('PontoDeAplicacaoDetalheCubit._carregar', e, stackTrace);
      emit(PontoDeAplicacaoDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }

  Future<String?> _resolverNomeAplicador(String? aplicadorId) async {
    if (aplicadorId == null) return null;
    final aplicadores = await _aplicadorRepository.listar();
    for (final aplicador in aplicadores) {
      if (aplicador.id == aplicadorId) return aplicador.nome;
    }
    return null;
  }

  /// Opções para o dropdown de atribuição — carregadas sob demanda pela
  /// tela (não faz parte do estado emitido, para não duplicar a lista a
  /// cada `Loaded`).
  Future<List<AplicadorOpcaoViewModel>> listarAplicadoresDisponiveis() async {
    final aplicadores = await _aplicadorRepository.listar();
    return aplicadores
        .where((aplicador) => aplicador.status == UsuarioStatus.ativo)
        .map(AplicadorOpcaoViewModel.fromEntity)
        .toList();
  }

  Future<void> desativar() async {
    try {
      await _repository.desativar(_pontoId);
      await _carregar();
    } on EntidadeNaoEncontradaException catch (e) {
      emit(PontoDeAplicacaoDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('PontoDeAplicacaoDetalheCubit.desativar', e, stackTrace);
      emit(PontoDeAplicacaoDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }

  Future<void> atribuirAplicador(String? aplicadorId) async {
    try {
      await _repository.atribuirAplicador(_pontoId, aplicadorId);
      await _carregar();
    } on EntidadeNaoEncontradaException catch (e) {
      emit(PontoDeAplicacaoDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error(
        'PontoDeAplicacaoDetalheCubit.atribuirAplicador',
        e,
        stackTrace,
      );
      emit(PontoDeAplicacaoDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }

  Future<void> editar({
    required String bairro,
    required double lat,
    required double lng,
    double? distanciaAlertaMetros,
  }) async {
    try {
      await _repository.editar(
        _pontoId,
        bairro: bairro,
        lat: lat,
        lng: lng,
        distanciaAlertaMetros: distanciaAlertaMetros,
      );
      await _carregar();
    } on EntidadeNaoEncontradaException catch (e) {
      emit(PontoDeAplicacaoDetalheError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('PontoDeAplicacaoDetalheCubit.editar', e, stackTrace);
      emit(PontoDeAplicacaoDetalheError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
