import '../core/tenant_config.dart';
import 'mock_tenant_configs.dart';

/// Implementação de [TenantRepository] com fonte remota mockada
/// (`mockTenantConfigs`, ver TODO no arquivo) e cache local em memória.
///
/// TODO(GEOPRAG-24): trocar o cache em memória por persistência real
/// (ex.: `shared_preferences`) quando o cold start offline for priorizado.
class TenantRepositoryImpl implements TenantRepository {
  TenantConfig? _cached;

  @override
  Future<TenantConfig> fetchByTenantId(String tenantId) async {
    final config = mockTenantConfigs[tenantId];
    if (config == null) {
      throw StateError('Tenant "$tenantId" não encontrado.');
    }
    return config;
  }

  @override
  Future<TenantConfig?> readCached() async => _cached;

  @override
  Future<void> cache(TenantConfig config) async {
    _cached = config;
  }
}
