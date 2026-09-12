import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/admin_auth_repository.dart';
import 'auth_action_state.dart';
import '../../../src/errors/app_logger.dart';

class VerificarCodigoAdminCubit extends Cubit<AuthActionState<Null>> {
  VerificarCodigoAdminCubit(this._repository) : super(const AuthActionIdle());

  final AdminAuthRepository _repository;

  Future<void> submit({required String code}) async {
    emit(const AuthActionLoading());
    try {
      await _repository.verifyResetCode(code: code);
      emit(const AuthActionSuccess(null));
    } catch (e, stackTrace) {
      AppLogger.error('VerificarCodigoAdminCubit.submit', e, stackTrace);
      emit(
        const AuthActionFailure(
          'Código inválido ou expirado. Tente novamente.',
        ),
      );
    }
  }
}
