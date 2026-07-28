class Report {
  final String id;
  final double lat;
  final double lng;
  final String infestationLevel;
  final String description;
  final String status;

  const Report({
    required this.id,
    required this.lat,
    required this.lng,
    required this.infestationLevel,
    required this.description,
    required this.status,
  });
}
