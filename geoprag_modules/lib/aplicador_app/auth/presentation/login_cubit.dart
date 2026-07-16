import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/auth_repository.dart';
import '../core/user.dart';
import 'auth_action_state.dart';

class LoginCubit extends Cubit<AuthActionState<User>> {
  LoginCubit(this._repository) : super(const AuthActionIdle());

  final AuthRepository _repository;

  Future<void> submit({
    required String identifier,
    required String senha,
  }) async {
    emit(const AuthActionLoading());
    try {
      final user = await _repository.login(
        identifier: identifier,
        senha: senha,
      );
      emit(AuthActionSuccess(user));
    } catch (e) {
      emit(AuthActionFailure(e.toString()));
    }
  }
}
