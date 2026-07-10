import 'package:hive_flutter/hive_flutter.dart';

import '../models/archive_item.dart';

/// Hive 로컬 DB를 초기화하고 `ArchiveItem`의 CRUD를 담당하는 서비스.
///
/// TRD_android.md §2-B `LocalDBService` 스펙 구현. 백엔드 없이 모든 데이터를
/// 앱 전용 저장소(`getApplicationDocumentsDirectory`)에 보관한다.
/// 각 항목은 `id`(UUID)를 Box key로 사용하여 저장하므로 수정/삭제가 O(1)이다.
class LocalDBService {
  /// Box 이름. iOS 원본과 동일하게 camelCase를 유지한다.
  /// (snake_case로 바꾸면 기존 데이터 호환이 깨진다)
  static const String _boxName = 'archiveItems';

  Box<ArchiveItem>? _box;

  /// initDB() 호출 이전 접근을 막는다.
  Box<ArchiveItem> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError(
        'LocalDBService가 초기화되지 않았습니다. main()에서 initDB()를 먼저 호출하세요.',
      );
    }
    return box;
  }

  /// Hive 초기화 + TypeAdapter 등록 + Box 열기.
  /// main()에서 `runApp` 이전에 한 번만 호출한다(Task 5).
  Future<void> initDB() async {
    // 서브디렉토리 없이 초기화 → Box 파일이 app_flutter/ 바로 아래에 생성된다.
    await Hive.initFlutter();
    // typeId 0 = ArchiveItem. 중복 등록 방지(핫 리스타트 대비).
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArchiveItemAdapter());
    }
    _box = await Hive.openBox<ArchiveItem>(_boxName);
  }

  /// 신규 기록 저장(Insert).
  Future<void> addItem(ArchiveItem item) async {
    await _requireBox.put(item.id, item);
  }

  /// 기존 기록 갱신(Update). 같은 id로 덮어쓴다.
  Future<void> updateItem(ArchiveItem item) async {
    await _requireBox.put(item.id, item);
  }

  /// id로 기록 삭제(Delete).
  Future<void> deleteItem(String id) async {
    await _requireBox.delete(id);
  }

  /// 전체 기록 조회. 방문 일자 기준 최신순으로 정렬한다.
  /// 날짜가 없는(EXIF 부재) 항목은 목록 맨 뒤로 보낸다.
  List<ArchiveItem> getAllItems() {
    final items = _requireBox.values.toList();
    items.sort((a, b) {
      final aDate = a.date;
      final bDate = b.date;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return items;
  }

  /// 키워드 검색. `searchKeyword.contains(정규화된 query)`로 필터링한다.
  /// query를 모델과 동일한 방식(공백 제거 + 소문자)으로 정규화하므로
  /// "연남동 한식" → "연남동한식"으로 변환되어 매칭된다(Task 14).
  /// 빈 검색어면 전체 목록을 반환한다.
  List<ArchiveItem> searchItems(String query) {
    final normalized = query.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    if (normalized.isEmpty) return getAllItems();
    return getAllItems()
        .where((item) => item.searchKeyword.contains(normalized))
        .toList();
  }
}
