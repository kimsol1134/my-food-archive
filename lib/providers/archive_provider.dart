import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/archive_item.dart';
import '../services/local_db_service.dart';
import '../utils/app_paths.dart';

class ArchiveProvider extends ChangeNotifier {
  final LocalDBService _dbService;

  List<ArchiveItem> _items = [];
  List<ArchiveItem> _filteredItems = [];
  String _searchQuery = '';
  bool _isLoading = false;

  ArchiveProvider(this._dbService);

  List<ArchiveItem> get items =>
      _searchQuery.isEmpty ? _items : _filteredItems;

  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;

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

  Future<void> addItem(ArchiveItem item) async {
    await _dbService.addItem(item);
    await loadItems();
  }

  Future<void> updateItem(ArchiveItem item) async {
    await _dbService.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(ArchiveItem item) async {
    await _dbService.deleteItem(item.id);
    try {
      final file = File(AppPaths.resolve(item.imagePath));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // 파일이 이미 없거나 삭제 실패해도 DB 삭제는 성공이므로 무시
    }
    await loadItems();
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _dbService.searchItems(query);
    }
    notifyListeners();
  }
}
