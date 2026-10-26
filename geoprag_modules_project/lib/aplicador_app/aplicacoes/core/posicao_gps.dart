/// Posição lida do GPS do aparelho (GEOPRAG-191).
///
/// [instante] é o relógio do aparelho no momento da leitura. A [precisaoMetros]
/// é só informativa: o modelo do registro (`Aplicacao`/`Subponto`) e o contrato
/// de sincronização não a carregam, então ela não é gravada nem enviada.
class PosicaoGps {
  const PosicaoGps({
    required this.latitude,
    required this.longitude,
    required this.precisaoMetros,
    required this.instante,
  });

  final double latitude;
  final double longitude;
  final double precisaoMetros;
  final DateTime instante;
}
