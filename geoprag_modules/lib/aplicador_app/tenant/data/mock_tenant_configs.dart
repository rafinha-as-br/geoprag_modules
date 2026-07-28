import '../core/tenant_config.dart';

/// Configurações de tenant usadas para simular a resposta do backend,
/// indexadas por `tenant_id`.
///
/// TODO(GEOPRAG-24): contrato real do campo `tenant_id` na resposta de
/// login, e origem/processo de geração do pacote `.mbtiles` self-hosted,
/// ainda pendentes de definição com o backend (`geoprag_api`).
final Map<String, TenantConfig> mockTenantConfigs = {
  'gaspar-sc': const TenantConfig(
    tenantId: 'gaspar-sc',
    cityName: 'Gaspar',
    mapBounds: TenantMapBounds(
      southWestLat: -26.9756,
      southWestLng: -48.9976,
      northEastLat: -26.8814,
      northEastLng: -48.8814,
    ),
    mbtilesUrl: 'https://tiles.geoprag.example/gaspar-sc.mbtiles',
    branding: TenantBranding(
      primaryColorHex: '#0B5E3C',
      logoAssetUrl: 'https://tiles.geoprag.example/gaspar-sc/logo.png',
    ),
  ),
};
