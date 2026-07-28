import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/produto_repository.dart';
import 'formulas_dosagem_state.dart';
import 'produto_view_model.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a listagem de fórmulas de dosagem de BTI vinculadas aos produtos
/// do fabricante, exibida em [FormulaDeDosagemScreen].
class FormulasDosagemCubit extends Cubit<FormulasDosagemState> {
  FormulasDosagemCubit(this._repository)
    : super(const FormulasDosagemLoading()) {
    _carregar();
  }

  final ProdutoRepository _repository;

  Future<void> _carregar() async {
    try {
      final formulas = await _repository.listarFormulas();
      emit(
        FormulasDosagemLoaded(
          formulas.map(FormulaDosagemViewModel.fromEntity).toList(),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(FormulasDosagemError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('FormulasDosagemCubit._carregar', e, stackTrace);
      emit(FormulasDosagemError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
