import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/insumo_repository.dart';
import '../core/recebimento_repository.dart';
import 'insumo_view_model.dart';
import 'inventario_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega o resumo de inventário (estoque atual do insumo principal +
/// contagem de recebimentos pendentes) exibido em `ListaDeInsumosScreen`.
class InventarioCubit extends Cubit<InventarioState> {
  InventarioCubit(this._insumoRepository, this._recebimentoRepository)
    : super(const InventarioLoading()) {
    _carregar();
  }

  final InsumoRepository _insumoRepository;
  final RecebimentoRepository _recebimentoRepository;

  Future<void> _carregar() async {
    try {
      final insumos = await _insumoRepository.listar();
      final pendentes = await _recebimentoRepository.listarPendentes();
      if (insumos.isEmpty) {
        throw const EntidadeNaoEncontradaException(
          'Nenhum insumo cadastrado no inventário.',
        );
      }
      emit(
        InventarioLoaded(
          EstoqueAtualViewModel.fromEntity(insumos.first, pendentes.length),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(InventarioError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('InventarioCubit._carregar', e, stackTrace);
      emit(InventarioError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
