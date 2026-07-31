import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/admin_account.dart';
import '../core/admin_auth_repository.dart';
import 'auth_action_state.dart';
import '../../../src/errors/app_logger.dart';

/// Resolve o papel (Administrador principal ou Sub-Administrador) da conta
/// pelo e-mail informado — o restante do fluxo de "esqueci minha senha"
/// depende desse papel (ver [AdminRole]).
class AdminEsqueciSenhaCubit extends Cubit<AuthActionState<AdminRole>> {
  AdminEsqueciSenhaCubit(this._repository) : super(const AuthActionIdle());

  final AdminAuthRepository _repository;

  Future<void> submit({required String email}) async {
    emit(const AuthActionLoading());
    try {
      final account = await _repository.findByEmail(email);
      final role = account?.role ?? AdminRole.subAdministrador;
      emit(AuthActionSuccess(role));
    } catch (e, stackTrace) {
      AppLogger.error('AdminEsqueciSenhaCubit.submit', e, stackTrace);
      emit(
        const AuthActionFailure(
          'Não foi possível enviar o código. Tente novamente.',
        ),
      );
    }
  }
}
