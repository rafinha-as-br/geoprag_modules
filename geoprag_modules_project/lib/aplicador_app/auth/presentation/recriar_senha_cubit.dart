import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/auth_repository.dart';
import 'auth_action_state.dart';

class RecriarSenhaCubit extends Cubit<AuthActionState<Null>> {
  RecriarSenhaCubit(this._repository) : super(const AuthActionIdle());

  final AuthRepository _repository;

  Future<void> submit({required String novaSenha}) async {
    emit(const AuthActionLoading());
    try {
      await _repository.resetPassword(novaSenha: novaSenha);
      emit(const AuthActionSuccess(null));
    } catch (e) {
      emit(const AuthActionFailure('Não foi possível redefinir a senha. Tente novamente.'));
    }
  }
}
