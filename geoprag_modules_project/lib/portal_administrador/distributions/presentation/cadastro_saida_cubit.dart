import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/distribuicao_repository.dart';
import 'cadastro_saida_state.dart';
import 'distribuicao_view_model.dart';

/// Carrega os dados de referência (produtos e responsáveis disponíveis)
/// para os dropdowns do formulário de nova distribuição.
class CadastroSaidaCubit extends Cubit<CadastroSaidaState> {
  CadastroSaidaCubit(this._repository) : super(const CadastroSaidaLoading()) {
    _carregar();
  }

  final DistribuicaoRepository _repository;

  Future<void> _carregar() async {
    try {
      final produtos = await _repository.listarProdutosDisponiveis();
      final responsaveis = await _repository.listarResponsaveisDisponiveis();
      emit(
        CadastroSaidaLoaded(
          produtos: produtos.map(ProdutoOpcaoViewModel.fromEntity).toList(),
          responsaveis: responsaveis
              .map(ResponsavelOpcaoViewModel.fromEntity)
              .toList(),
        ),
      );
    } catch (e) {
      emit(CadastroSaidaError(e.toString()));
    }
  }
}
