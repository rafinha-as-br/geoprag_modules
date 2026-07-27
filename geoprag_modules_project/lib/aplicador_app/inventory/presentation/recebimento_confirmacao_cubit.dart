import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/recebimento.dart';
import '../core/recebimento_repository.dart';
import 'recebimento_confirmacao_state.dart';
import 'recebimento_view_model.dart';

/// Carrega o recebimento a ser confirmado em `ReceberProdutoScreen` e
/// executa a confirmação de entrega.
///
/// Quando [recebimentoId] não é informado (navegação ainda não propaga qual
/// card foi selecionado em `RecebimentosScreen`), carrega o primeiro
/// recebimento pendente da fila.
///
/// TODO(GEOPRAG-24): propagar o id do recebimento selecionado assim que a
/// navegação do `aplicador_app` suportar parâmetros de rota.
class RecebimentoConfirmacaoCubit extends Cubit<RecebimentoConfirmacaoState> {
  RecebimentoConfirmacaoCubit(this._repository, {String? recebimentoId})
    : super(const RecebimentoConfirmacaoLoading()) {
    _carregar(recebimentoId);
  }

  final RecebimentoRepository _repository;

  Future<void> _carregar(String? recebimentoId) async {
    try {
      final Recebimento recebimento;
      if (recebimentoId != null) {
        recebimento = await _repository.buscarPorId(recebimentoId);
      } else {
        final pendentes = await _repository.listarPendentes();
        if (pendentes.isEmpty) {
          throw StateError('Não há recebimentos pendentes de confirmação.');
        }
        recebimento = pendentes.first;
      }
      emit(
        RecebimentoConfirmacaoLoaded(
          RecebimentoDetalheViewModel.fromEntity(recebimento),
        ),
      );
    } catch (e) {
      emit(RecebimentoConfirmacaoError('Não foi possível carregar os dados. Tente novamente.'));
    }
  }

  Future<void> confirmar() async {
    final atual = state;
    if (atual is! RecebimentoConfirmacaoLoaded) return;
    await _repository.confirmar(atual.recebimento.id);
  }
}
