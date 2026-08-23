import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/ponto_de_aplicacao_repository.dart';
import 'pontos_de_aplicacao_state.dart';
import 'view_models/ponto_de_aplicacao_resumo_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a listagem de pontos de aplicação ativos — usada tanto pelo
/// dashboard geral (`bairro: null`, todos os bairros) quanto pela
/// visualização de um bairro específico (`bairro` informado).
class PontosDeAplicacaoCubit extends Cubit<PontosDeAplicacaoState> {
  PontosDeAplicacaoCubit(this._repository, {String? bairro})
    : _bairro = bairro,
      super(const PontosDeAplicacaoLoading()) {
    _carregar();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final String? _bairro;

  Future<void> _carregar() async {
    try {
      final pontos = await _repository.listar();
      final filtrados = pontos.where(
        (ponto) => ponto.ativo && (_bairro == null || ponto.bairro == _bairro),
      );
      emit(
        PontosDeAplicacaoLoaded(
          filtrados.map(PontoDeAplicacaoResumoViewModel.fromEntity).toList(),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(PontosDeAplicacaoError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('PontosDeAplicacaoCubit._carregar', e, stackTrace);
      emit(PontosDeAplicacaoError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
