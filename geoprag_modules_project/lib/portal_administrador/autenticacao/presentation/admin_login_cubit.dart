import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/admin_account.dart';
import '../core/admin_auth_exceptions.dart';
import '../core/admin_auth_repository.dart';
import 'auth_action_state.dart';
import '../../../src/errors/app_logger.dart';

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
    } on InvalidCredentialsException {
      emit(const AuthActionFailure('Credenciais inválidas.'));
    } catch (e, stackTrace) {
      AppLogger.error('AdminLoginCubit.submit', e, stackTrace);
      emit(
        const AuthActionFailure('Não foi possível entrar. Tente novamente.'),
      );
    }
  }
}
