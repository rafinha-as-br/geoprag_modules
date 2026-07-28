import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/auth_exceptions.dart';
import '../core/auth_repository.dart';
import '../core/usuario.dart';
import 'auth_action_state.dart';
import '../../../src/errors/app_logger.dart';

class LoginCubit extends Cubit<AuthActionState<Usuario>> {
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
    } on InvalidCredentialsException {
      emit(const AuthActionFailure('CPF/e-mail ou senha inválidos.'));
    } catch (e, stackTrace) {
      AppLogger.error('LoginCubit.submit', e, stackTrace);
      emit(const AuthActionFailure('Não foi possível entrar. Tente novamente.'));
    }
  }
}
