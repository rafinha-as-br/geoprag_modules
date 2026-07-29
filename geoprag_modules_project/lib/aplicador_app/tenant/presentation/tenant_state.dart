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
}

class TenantReady extends TenantState {
  final TenantConfig config;
  const TenantReady(this.config);
}

class TenantError extends TenantState {
  final String message;
  const TenantError(this.message);
}
