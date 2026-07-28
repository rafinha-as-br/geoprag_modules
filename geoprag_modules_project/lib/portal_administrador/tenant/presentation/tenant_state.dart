import '../../../src/entities/tenant_config.dart';

sealed class AdminTenantState {
  const AdminTenantState();
}

class AdminTenantInitial extends AdminTenantState {
  const AdminTenantInitial();
}

class AdminTenantDownloading extends AdminTenantState {
  final double progress;
  const AdminTenantDownloading(this.progress);
}

class AdminTenantReady extends AdminTenantState {
  final TenantConfig config;
  const AdminTenantReady(this.config);
}

class AdminTenantError extends AdminTenantState {
  final String message;
  const AdminTenantError(this.message);
}
