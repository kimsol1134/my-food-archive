import 'package:hive_flutter/hive_flutter.dart';

import '../models/archive_item.dart';

class LocalDBService {
  static const String _boxName = 'archiveItems';

  late Box<ArchiveItem> _box;

  Future<void> initDB() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArchiveItemAdapter());
    }
    _box = await Hive.openBox<ArchiveItem>(_boxName);
  }

  Future<void> addItem(ArchiveItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> updateItem(ArchiveItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  List<ArchiveItem> getAllItems() {
    final items = _box.values.toList();
    items.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return items;
  }

  List<ArchiveItem> searchItems(String query) {
    final normalizedQuery = query.replaceAll(' ', '');
    if (normalizedQuery.isEmpty) return getAllItems();

    final items = _box.values
        .where((item) => item.searchKeyword.contains(normalizedQuery))
        .toList();
    items.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return items;
  }
}
