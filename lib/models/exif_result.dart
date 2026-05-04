class ExifResult {
  final DateTime? date;
  final double? latitude;
  final double? longitude;

  const ExifResult({this.date, this.latitude, this.longitude});

  bool get hasGps => latitude != null && longitude != null;
}
