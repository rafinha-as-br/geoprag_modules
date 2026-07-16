import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/admin_account.dart';
import '../core/admin_auth_repository.dart';
import 'auth_action_state.dart';

class AdminLoginCubit extends Cubit<AuthActionState<AdminAccount>> {
  AdminLoginCubit(this._repository) : super(const AuthActionIdle());

  final AdminAuthRepository _repository;

  Future<void> submit({
    required String identifier,
    required String senha,
  }) async {
    emit(const AuthActionLoading());
    try {
      final account = await _repository.login(
        identifier: identifier,
        senha: senha,
      );
      emit(AuthActionSuccess(account));
    } catch (e) {
      emit(AuthActionFailure(e.toString()));
    }
  }
}
