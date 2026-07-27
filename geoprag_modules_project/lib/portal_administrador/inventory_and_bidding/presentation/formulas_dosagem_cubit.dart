import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/produto_repository.dart';
import 'formulas_dosagem_state.dart';
import 'produto_view_model.dart';

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
    } catch (e) {
      emit(FormulasDosagemError('Não foi possível carregar os dados. Tente novamente.'));
    }
  }
}
