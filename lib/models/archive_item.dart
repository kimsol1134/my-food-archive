import 'package:hive/hive.dart';

part 'archive_item.g.dart';

/// 맛집 기록 한 건을 표현하는 핵심 데이터 모델.
///
/// IA.md §1 / TRD_android.md §2-A의 `ArchiveItem` 스펙을 그대로 구현한다.
/// Hive 로컬 DB에 직렬화되어 저장되며, `typeId`는 0으로 고정한다.
/// (typeId를 바꾸면 기존에 저장된 데이터를 더 이상 읽지 못한다)
@HiveType(typeId: 0)
class ArchiveItem {
  /// 고유 식별자 (UUID). Hive Box의 key로도 사용한다.
  @HiveField(0)
  final String id;

  /// 기기 내부 사진 저장 경로 (앱 전용 디렉토리 기준 상대 경로).
  @HiveField(1)
  final String imagePath;

  /// 식당명 — 사용자 직접 입력(필수).
  @HiveField(2)
  final String restaurantName;

  /// 메뉴명 — AI 자동 추출, 사용자 수정 가능.
  @HiveField(3)
  final String menuName;

  /// 카테고리(한식/카페 등) — AI 자동 추출, 사용자 수정 가능.
  @HiveField(4)
  final String category;

  /// 지역명 — EXIF 좌표 역지오코딩 결과, 사용자 수정 가능.
  @HiveField(5)
  final String location;

  /// 방문 일자 — EXIF 기반. 메타데이터가 없으면 null.
  @HiveField(6)
  final DateTime? date;

  /// 검색용 통합 문자열 (시스템 자동 생성).
  /// 예: "연남동오스테리아크림파스타양식"
  @HiveField(7)
  final String searchKeyword;

  ArchiveItem({
    required this.id,
    required this.imagePath,
    required this.restaurantName,
    this.menuName = '',
    this.category = '',
    this.location = '',
    this.date,
    String? searchKeyword,
  }) : searchKeyword = searchKeyword ??
            generateSearchKeyword(
              restaurantName: restaurantName,
              menuName: menuName,
              category: category,
              location: location,
            );

  /// 검색 최적화용 통합 문자열을 생성한다.
  ///
  /// 지역명 + 식당명 + 메뉴명 + 카테고리를 공백 없이 이어 붙인 뒤,
  /// 모든 공백을 제거하고 소문자로 정규화한다. (TRD_android.md §1-5,
  /// Usecase.md UC-03 step10) 검색 시에도 동일한 정규화를 적용하므로
  /// 영문 입력은 대소문자 구분 없이 매칭된다.
  static String generateSearchKeyword({
    required String restaurantName,
    required String menuName,
    required String category,
    required String location,
  }) {
    final combined = '$location$restaurantName$menuName$category';
    return combined.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }

  /// 일부 필드만 바꾼 새 인스턴스를 만든다.
  /// 변경된 필드를 기준으로 `searchKeyword`가 자동 재생성된다.
  /// (수정 모드 저장 시 `id`/`imagePath`는 유지하고 나머지만 갱신 — Task 12)
  ///
  /// 주의: `date`는 null로 되돌릴 수 없다(기존 값 유지). MVP 범위에서는
  /// 방문 일자를 비우는 시나리오가 없으므로 의도된 단순화다.
  ArchiveItem copyWith({
    String? id,
    String? imagePath,
    String? restaurantName,
    String? menuName,
    String? category,
    String? location,
    DateTime? date,
  }) {
    return ArchiveItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      restaurantName: restaurantName ?? this.restaurantName,
      menuName: menuName ?? this.menuName,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
    );
  }
}
