class Aplicacao {
  final String id;
  final DateTime data;
  final double lat;
  final double lng;
  final double dosagem;
  final String aplicadorId;

  const Aplicacao({
    required this.id,
    required this.data,
    required this.lat,
    required this.lng,
    required this.dosagem,
    required this.aplicadorId,
  });
}
