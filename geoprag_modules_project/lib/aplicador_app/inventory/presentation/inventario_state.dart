import 'insumo_view_model.dart';

sealed class InventarioState {
  const InventarioState();
}

class InventarioLoading extends InventarioState {
  const InventarioLoading();
}

class InventarioLoaded extends InventarioState {
  final EstoqueAtualViewModel estoqueAtual;
  const InventarioLoaded(this.estoqueAtual);
}

class InventarioError extends InventarioState {
  final String message;
  const InventarioError(this.message);
}
