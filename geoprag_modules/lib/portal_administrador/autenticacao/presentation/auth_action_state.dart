/// Estado genérico reaproveitado pelos Cubits de ação única do fluxo de
/// autenticação do Portal Administrador (login, esqueci senha, recriar
/// senha) — evita repetir a mesma hierarquia idle/loading/success/failure
/// em cada um. Independente do equivalente em `aplicador_app/auth` (cada
/// subárvore tem seus próprios módulos, sem compartilhamento entre elas).
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
