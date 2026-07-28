import 'produto_view_model.dart';

sealed class FormulasDosagemState {
  const FormulasDosagemState();
}

class FormulasDosagemLoading extends FormulasDosagemState {
  const FormulasDosagemLoading();
}

class FormulasDosagemLoaded extends FormulasDosagemState {
  final List<FormulaDosagemViewModel> formulas;
  const FormulasDosagemLoaded(this.formulas);
}

class FormulasDosagemError extends FormulasDosagemState {
  final String message;
  const FormulasDosagemError(this.message);
}
