import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/corrego_repository.dart';
import 'bairro_detalhe_state.dart';
import 'bairro_view_model.dart';

/// Carrega o detalhe agregado de um Bairro específico (`bairroId`) e os
/// córregos que o atravessam, para a tela de detalhe do bairro.
///
/// TODO(GEOPRAG-24): hoje `AdminNavigator.toMapaBairro()` não carrega um id
/// (ver `core/admin_navigator.dart`) — o `bairroId` é passado pelo app
/// consumidor ao montar este Cubit em `bootstrap.dart`; falta o roteamento
/// real repassar qual bairro foi selecionado no mapa/listagem. Mesma
/// limitação já registrada em
/// `gestao_de_aplicadores/presentation/aplicador_detalhe_cubit.dart`.
class BairroDetalheCubit extends Cubit<BairroDetalheState> {
  BairroDetalheCubit(this._repository, this._bairroId)
    : super(const BairroDetalheLoading()) {
    _carregar();
  }

  final CorregoRepository _repository;
  final String _bairroId;

  Future<void> _carregar() async {
    try {
      final bairro = await _repository.buscarBairroPorId(_bairroId);
      final corregos = await _repository.listarCorregosDoBairro(_bairroId);
      emit(
        BairroDetalheLoaded(
          BairroDetalhadoViewModel.fromEntity(bairro, corregos),
        ),
      );
    } catch (e) {
      emit(BairroDetalheError('Não foi possível carregar os dados. Tente novamente.'));
    }
  }
}
