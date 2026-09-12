import '../../../src/entities/tenant_config.dart';

sealed class TenantState {
  const TenantState();
}

class TenantInitial extends TenantState {
  const TenantInitial();
}

class TenantDownloading extends TenantState {
  final double progress;
  const TenantDownloading(this.progress);

  // Sobrescrito para comparações de estado em blocTest (GEOPRAG-100) —
  // sem isso, duas instâncias com o mesmo progress nunca são iguais.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TenantDownloading && other.progress == progress);

  @override
  int get hashCode => Object.hash(runtimeType, progress);
}

class TenantReady extends TenantState {
  final TenantConfig config;
  const TenantReady(this.config);
}

class TenantError extends TenantState {
  final String message;
  const TenantError(this.message);
}
