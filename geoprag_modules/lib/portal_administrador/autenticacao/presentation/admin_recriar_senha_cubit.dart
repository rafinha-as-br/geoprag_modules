import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/admin_auth_repository.dart';
import 'auth_action_state.dart';

class AdminRecriarSenhaCubit extends Cubit<AuthActionState<Null>> {
  AdminRecriarSenhaCubit(this._repository) : super(const AuthActionIdle());

  final AdminAuthRepository _repository;

  Future<void> submit({required String novaSenha}) async {
    emit(const AuthActionLoading());
    try {
      await _repository.resetPassword(novaSenha: novaSenha);
      emit(const AuthActionSuccess(null));
    } catch (e) {
      emit(AuthActionFailure(e.toString()));
    }
  }
}
