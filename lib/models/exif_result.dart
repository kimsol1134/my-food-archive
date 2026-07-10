/// 사진 EXIF에서 추출한 메타데이터(Implement_plan_android.md Task 10).
///
/// 태그가 없거나 파싱에 실패하면 각 필드는 null로 둔다(Fail-Safe). 빈 인스턴스는
/// `const ExifResult()`로 만든다.
class ExifResult {
  const ExifResult({this.date, this.latitude, this.longitude});

  /// 촬영 일자(EXIF DateTimeOriginal / Image DateTime). 없으면 null.
  final DateTime? date;

  /// 위도(십진수). GPS 태그가 없으면 null.
  final double? latitude;

  /// 경도(십진수). GPS 태그가 없으면 null.
  final double? longitude;

  /// 역지오코딩이 가능한 좌표가 모두 존재하는지 여부.
  bool get hasCoordinates => latitude != null && longitude != null;
}
