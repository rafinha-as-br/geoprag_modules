import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/denuncia_de_foco_repository.dart';
import 'denuncia_de_foco_view_model.dart';
import 'denuncias_de_foco_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a listagem de Denúncias de Foco registradas pelo aplicador para
/// o seu dashboard.
class DenunciasDeFocoCubit extends Cubit<DenunciasDeFocoState> {
  DenunciasDeFocoCubit(this._repository)
    : super(const DenunciasDeFocoLoading()) {
    _carregar();
  }

  final DenunciaDeFocoRepository _repository;

  Future<void> _carregar() async {
    try {
      final denuncias = await _repository.listar();
      emit(
        DenunciasDeFocoLoaded(
          denuncias.map(DenunciaDeFocoViewModel.fromEntity).toList(),
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emit(DenunciasDeFocoError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('DenunciasDeFocoCubit._carregar', e, stackTrace);
      emit(DenunciasDeFocoError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
