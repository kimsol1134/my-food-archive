import 'package:geocoding/geocoding.dart';

/// EXIF GPS 좌표를 한국어 동/구 텍스트로 변환하는 역지오코딩 서비스
/// (Implement_plan_android.md Task 10).
///
/// Android Geocoder를 사용하며, 디바이스/네트워크 상황에 따라 실패할 수 있으므로
/// 모든 경로에서 Fail-Safe로 빈 문자열을 돌려준다(앱 흐름을 막지 않는다).
class LocationService {
  /// `setLocaleIdentifier`는 프로세스 전역 1회만 적용하면 충분하다.
  bool _localeApplied = false;

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

      final place = placemarks.first;
      // 우선순위: 동(subLocality) > 도로명(thoroughfare) > 시(locality) > 구(subAdministrativeArea)
      for (final candidate in [
        place.subLocality,
        place.thoroughfare,
        place.locality,
        place.subAdministrativeArea,
      ]) {
        final value = candidate?.trim() ?? '';
        if (value.isNotEmpty) return value;
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}
