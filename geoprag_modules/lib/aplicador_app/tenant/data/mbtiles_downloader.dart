/// Provisionador de download em background do pacote `.mbtiles` do tenant.
/// Exclusivo do `aplicador_app` — o `portal_administrador` só consome
/// [TenantConfig], sem baixar o mapa localmente.
///
/// TODO(GEOPRAG-24): integração real de download em background (ex.:
/// `dio` + `path_provider`, com retomada e verificação de integridade) —
/// hoje simula o progresso via [Stream.periodic] sem baixar nenhum arquivo.
class MbtilesDownloader {
  Stream<double> download(String mbtilesUrl) async* {
    const steps = 10;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield i / steps;
    }
  }
}
