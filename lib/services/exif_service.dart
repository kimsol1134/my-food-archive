import 'dart:io';

import 'package:exif/exif.dart';

import '../models/exif_result.dart';

/// 사진 파일에서 EXIF 촬영 일자와 GPS 좌표를 추출하는 서비스
/// (Implement_plan_android.md Task 10).
///
/// 모든 추출은 Fail-Safe다. 태그가 없거나 형식이 깨져도 예외를 던지지 않고
/// 비어있는 [ExifResult]를 돌려준다(스크린샷처럼 EXIF가 없는 사진 대비).
class ExifService {
  Future<ExifResult> extractMetadata(String absolutePath) async {
    try {
      final bytes = await File(absolutePath).readAsBytes();
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) return const ExifResult();

      return ExifResult(
        date: _parseDate(tags),
        latitude: _parseCoordinate(
          tags,
          valueKey: 'GPS GPSLatitude',
          refKey: 'GPS GPSLatitudeRef',
          positiveRef: 'N',
        ),
        longitude: _parseCoordinate(
          tags,
          valueKey: 'GPS GPSLongitude',
          refKey: 'GPS GPSLongitudeRef',
          positiveRef: 'E',
        ),
      );
    } catch (_) {
      return const ExifResult();
    }
  }

  /// "YYYY:MM:DD HH:MM:SS" 형식의 EXIF 날짜 문자열을 [DateTime]으로 변환한다.
  DateTime? _parseDate(Map<String, IfdTag> tags) {
    final raw = tags['EXIF DateTimeOriginal']?.printable ??
        tags['Image DateTime']?.printable;
    if (raw == null) return null;

    final match = RegExp(r'(\d{4}):(\d{2}):(\d{2})[ T](\d{2}):(\d{2}):(\d{2})')
        .firstMatch(raw.trim());
    if (match == null) return null;

    return DateTime(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
      int.parse(match[4]!),
      int.parse(match[5]!),
      int.parse(match[6]!),
    );
  }

  /// DMS(도/분/초) 형태의 GPS 좌표를 십진수로 변환한다.
  /// 기준(Ref)이 S/W면 음수로 뒤집는다. 값이 없으면 null.
  double? _parseCoordinate(
    Map<String, IfdTag> tags, {
    required String valueKey,
    required String refKey,
    required String positiveRef,
  }) {
    final valueTag = tags[valueKey];
    if (valueTag == null) return null;

    final parts = valueTag.values.toList();
    if (parts.length < 3) return null;

    final degrees = _ratioToDouble(parts[0]);
    final minutes = _ratioToDouble(parts[1]);
    final seconds = _ratioToDouble(parts[2]);
    if (degrees == null || minutes == null || seconds == null) return null;

    var decimal = degrees + minutes / 60 + seconds / 3600;

    final ref = tags[refKey]?.printable.trim().toUpperCase();
    if (ref != null && ref != positiveRef) decimal = -decimal;

    return decimal;
  }

  /// exif 패키지의 Ratio(numerator/denominator)를 double로 변환한다.
  double? _ratioToDouble(dynamic ratio) {
    try {
      final num numerator = ratio.numerator as num;
      final num denominator = ratio.denominator as num;
      if (denominator == 0) return null;
      return numerator / denominator;
    } catch (_) {
      return null;
    }
  }
}
