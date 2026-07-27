import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/auth_repository.dart';
import 'auth_action_state.dart';

class EsqueciSenhaCubit extends Cubit<AuthActionState<Null>> {
  EsqueciSenhaCubit(this._repository) : super(const AuthActionIdle());

  final AuthRepository _repository;

  Future<void> submit({required String email}) async {
    emit(const AuthActionLoading());
    try {
      await _repository.requestPasswordReset(email: email);
      emit(const AuthActionSuccess(null));
    } catch (e) {
      emit(const AuthActionFailure('Não foi possível enviar o código. Tente novamente.'));
    }
  }
}
