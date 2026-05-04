import 'dart:io';

import 'package:exif/exif.dart';

import '../models/exif_result.dart';

class ExifService {
  Future<ExifResult> extract(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) return const ExifResult();

      final date = _parseDate(tags);
      final (lat, lng) = _parseGps(tags);

      return ExifResult(date: date, latitude: lat, longitude: lng);
    } catch (_) {
      return const ExifResult();
    }
  }

  DateTime? _parseDate(Map<String, IfdTag> tags) {
    final raw = tags['EXIF DateTimeOriginal']?.printable ??
        tags['Image DateTime']?.printable;
    if (raw == null || raw.isEmpty) return null;

    try {
      final parts = raw.trim().split(' ');
      if (parts.length != 2) return null;

      final dateParts = parts[0].split(':');
      final timeParts = parts[1].split(':');
      if (dateParts.length != 3 || timeParts.length != 3) return null;

      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  (double?, double?) _parseGps(Map<String, IfdTag> tags) {
    final latTag = tags['GPS GPSLatitude'];
    final latRef = tags['GPS GPSLatitudeRef'];
    final lngTag = tags['GPS GPSLongitude'];
    final lngRef = tags['GPS GPSLongitudeRef'];
    if (latTag == null || latRef == null || lngTag == null || lngRef == null) {
      return (null, null);
    }

    final lat = _ratiosToDecimal(latTag, latRef);
    final lng = _ratiosToDecimal(lngTag, lngRef);
    if (lat == null || lng == null) return (null, null);
    if (lat == 0.0 && lng == 0.0) return (null, null);

    return (lat, lng);
  }

  double? _ratiosToDecimal(IfdTag coord, IfdTag ref) {
    final values = coord.values.toList();
    if (values.length < 3) return null;

    final parts = <double>[];
    for (var i = 0; i < 3; i++) {
      final v = values[i];
      if (v is! Ratio) return null;
      if (v.denominator == 0) return null;
      parts.add(v.numerator / v.denominator);
    }

    var decimal = parts[0] + parts[1] / 60.0 + parts[2] / 3600.0;
    final refValue = ref.printable.trim().toUpperCase();
    if (refValue == 'S' || refValue == 'W') decimal = -decimal;

    return decimal;
  }
}
