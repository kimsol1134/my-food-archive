import 'package:geocoding/geocoding.dart';

class LocationService {
  static bool _localeApplied = false;

  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (!_localeApplied) {
        await setLocaleIdentifier('ko_KR');
        _localeApplied = true;
      }
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return '';

      final p = placemarks.first;
      return _firstNonEmpty([
        p.subLocality,
        p.thoroughfare,
        p.locality,
        p.subAdministrativeArea,
      ]);
    } catch (_) {
      return '';
    }
  }

  String _firstNonEmpty(List<String?> candidates) {
    for (final c in candidates) {
      final trimmed = c?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }
}
