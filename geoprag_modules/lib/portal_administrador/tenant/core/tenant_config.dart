/// Bounding box do mapa hidrológico do município (tenant), usado para
/// centralizar/restringir a viewport do mapa carregado do pacote `.mbtiles`.
class TenantMapBounds {
  final double southWestLat;
  final double southWestLng;
  final double northEastLat;
  final double northEastLng;

  const TenantMapBounds({
    required this.southWestLat,
    required this.southWestLng,
    required this.northEastLat,
    required this.northEastLng,
  });
}

/// Identidade visual (branding) do tenant exibida no portal.
class TenantBranding {
  final String primaryColorHex;
  final String logoAssetUrl;

  const TenantBranding({
    required this.primaryColorHex,
    required this.logoAssetUrl,
  });
}

/// Configuração de uma prefeitura (tenant) no modelo multi-prefeitura.
class TenantConfig {
  final String tenantId;
  final String cityName;
  final TenantMapBounds mapBounds;
  final String mbtilesUrl;
  final TenantBranding branding;

  const TenantConfig({
    required this.tenantId,
    required this.cityName,
    required this.mapBounds,
    required this.mbtilesUrl,
    required this.branding,
  });
}

/// Fonte de dados de configuração de tenant: busca remota por `tenant_id`
/// (retornado no login) e cache local para cold start offline.
abstract class TenantRepository {
  Future<TenantConfig> fetchByTenantId(String tenantId);
  Future<TenantConfig?> readCached();
  Future<void> cache(TenantConfig config);
}
