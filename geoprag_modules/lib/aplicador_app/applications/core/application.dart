class Application {
  final String id;
  final DateTime date;
  final double lat;
  final double lng;
  final double dosage;
  final String applicatorId;

  const Application({
    required this.id,
    required this.date,
    required this.lat,
    required this.lng,
    required this.dosage,
    required this.applicatorId,
  });
}
