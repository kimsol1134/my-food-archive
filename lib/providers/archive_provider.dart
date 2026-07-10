import 'package:flutter/foundation.dart';

import '../models/archive_item.dart';
import '../services/local_db_service.dart';

/// UI와 [LocalDBService] 사이의 상태 관리 계층 (Implement_plan_android.md Task 5).
///
/// 모든 화면은 이 Provider를 통해서만 데이터를 읽고(`items`) 변경(add/update/
/// delete)을 요청한다. 변경 작업은 항상 DB에 먼저 반영한 뒤 [loadItems]로
/// 메모리 캐시를 다시 채워, 단일 소스(Hive Box)와 화면을 동기화한다.
class ArchiveProvider extends ChangeNotifier {
  ArchiveProvider(this._dbService);

  final LocalDBService _dbService;

  /// 전체 기록(최신순). DB와 동기화된 메모리 캐시.
  List<ArchiveItem> _items = const [];

  /// 검색 결과. 검색어가 있을 때만 채워진다.
  List<ArchiveItem> _filteredItems = const [];

  /// 현재 검색어(공백 trim 후). 비어있으면 전체 목록을 노출한다.
  String _searchQuery = '';

  /// DB 로딩 중 여부.
  bool _isLoading = false;

  /// 화면에 노출할 목록. 검색 중이면 필터 결과, 아니면 전체 목록을 반환한다.
  List<ArchiveItem> get items =>
      _searchQuery.isEmpty ? _items : _filteredItems;

  /// 현재 검색어(공백 trim 후).
  String get searchQuery => _searchQuery;

  /// 검색 중인지 여부.
  bool get isSearching => _searchQuery.isNotEmpty;

  /// 초기 로딩 등 DB 작업 진행 상태.
  bool get isLoading => _isLoading;

  /// 저장된 기록이 한 건도 없는지 여부(HomeScreen Empty State 판단용 — Task 6).
  bool get isEmpty => _items.isEmpty;

  /// DB 전체를 다시 읽어 메모리 캐시를 갱신한다.
  /// 검색 중이었다면 동일 검색어로 필터 결과도 함께 재계산한다.
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = _dbService.getAllItems();
    if (_searchQuery.isNotEmpty) {
      _filteredItems = _dbService.searchItems(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 신규 기록을 저장한 뒤 목록을 갱신한다(Task 12).
  Future<void> addItem(ArchiveItem item) async {
    await _dbService.addItem(item);
    await loadItems();
  }

  /// 기존 기록을 수정한 뒤 목록을 갱신한다(Task 12).
  Future<void> updateItem(ArchiveItem item) async {
    await _dbService.updateItem(item);
    await loadItems();
  }

  /// 기록을 삭제한 뒤 목록을 갱신한다(Task 13).
  Future<void> deleteItem(String id) async {
    await _dbService.deleteItem(id);
    await loadItems();
  }

  /// 실시간 키워드 검색(Task 14).
  ///
  /// 검색어를 저장하고 [LocalDBService.searchItems]로 필터링한다.
  /// 정규화(공백 제거 + 소문자)는 DB 서비스가 담당하므로 여기서는 trim만 한다.
  /// 빈/공백 검색어면 전체 목록으로 복원한다.
  void search(String query) {
    final trimmed = query.trim();
    if (trimmed == _searchQuery) return;

    _searchQuery = trimmed;
    _filteredItems =
        trimmed.isEmpty ? const [] : _dbService.searchItems(trimmed);
    notifyListeners();
  }
}
