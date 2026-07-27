import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/auth_repository.dart';
import 'auth_action_state.dart';

class VerificarCodigoCubit extends Cubit<AuthActionState<Null>> {
  VerificarCodigoCubit(this._repository) : super(const AuthActionIdle());

  final AuthRepository _repository;

  Future<void> submit({required String code}) async {
    emit(const AuthActionLoading());
    try {
      await _repository.verifyResetCode(code: code);
      emit(const AuthActionSuccess(null));
    } catch (e) {
      emit(const AuthActionFailure('Código inválido ou expirado. Tente novamente.'));
    }
  }
}
