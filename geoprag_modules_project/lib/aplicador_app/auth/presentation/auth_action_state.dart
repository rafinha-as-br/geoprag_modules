/// Estado genérico reaproveitado pelos Cubits de ação única do fluxo de
/// autenticação do Aplicador (login, solicitar código, verificar código,
/// recriar senha) — evita repetir a mesma hierarquia idle/loading/
/// success/failure em cada um.
sealed class AuthActionState<T> {
  const AuthActionState();
}

class AuthActionIdle<T> extends AuthActionState<T> {
  const AuthActionIdle();
}

class AuthActionLoading<T> extends AuthActionState<T> {
  const AuthActionLoading();
}

class AuthActionSuccess<T> extends AuthActionState<T> {
  final T data;
  const AuthActionSuccess(this.data);
}

class AuthActionFailure<T> extends AuthActionState<T> {
  final String message;
  const AuthActionFailure(this.message);
}
