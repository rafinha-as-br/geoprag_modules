/// Estado genérico reaproveitado pelos Cubits de ação única do fluxo de
/// autenticação do Portal Administrador (login, esqueci senha, recriar
/// senha) — evita repetir a mesma hierarquia idle/loading/success/failure
/// em cada um. Independente do equivalente em `aplicador_app/auth` (cada
/// subárvore tem seus próprios módulos, sem compartilhamento entre elas).
///
/// Todos os subtipos sobrescrevem `==`/`hashCode` (GEOPRAG-100): sem isso,
/// comparações de estado em `blocTest` (`expect: () => [...]`) checam
/// identidade de instância em vez de valor, e nunca batem para
/// [AuthActionSuccess]/[AuthActionFailure], que carregam dado.
sealed class AuthActionState<T> {
  const AuthActionState();
}

class AuthActionIdle<T> extends AuthActionState<T> {
  const AuthActionIdle();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthActionIdle<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthActionLoading<T> extends AuthActionState<T> {
  const AuthActionLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthActionLoading<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthActionSuccess<T> extends AuthActionState<T> {
  final T data;
  const AuthActionSuccess(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthActionSuccess<T> && other.data == data);

  @override
  int get hashCode => Object.hash(runtimeType, data);
}

class AuthActionFailure<T> extends AuthActionState<T> {
  final String message;
  const AuthActionFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthActionFailure<T> && other.message == message);

  @override
  int get hashCode => Object.hash(runtimeType, message);
}
