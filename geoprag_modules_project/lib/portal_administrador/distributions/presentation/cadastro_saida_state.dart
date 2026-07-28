import 'distribuicao_view_model.dart';

sealed class CadastroSaidaState {
  const CadastroSaidaState();
}

class CadastroSaidaLoading extends CadastroSaidaState {
  const CadastroSaidaLoading();
}

class CadastroSaidaLoaded extends CadastroSaidaState {
  final List<ProdutoOpcaoViewModel> produtos;
  final List<ResponsavelOpcaoViewModel> responsaveis;

  const CadastroSaidaLoaded({
    required this.produtos,
    required this.responsaveis,
  });
}

class CadastroSaidaError extends CadastroSaidaState {
  final String message;
  const CadastroSaidaError(this.message);
}
