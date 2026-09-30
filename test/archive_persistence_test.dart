import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:my_food_archive/models/archive_item.dart';
import 'package:my_food_archive/services/local_db_service.dart';

class _TemporaryDocuments extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _TemporaryDocuments(this.path);
  final String path;
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'saved records survive reopening and keyword migration without data loss',
    () async {
      final originalPaths = PathProviderPlatform.instance;
      final temporary = await Directory.systemTemp.createTemp(
        'mfa_persistence_',
      );
      PathProviderPlatform.instance = _TemporaryDocuments(temporary.path);
      try {
        final first = LocalDBService();
        await first.initDB();
        final date = DateTime(2026, 9, 20, 12, 30);
        await first.addItem(
          ArchiveItem(
            id: 'fixture-record',
            imagePath: 'photos/fixture.jpg',
            restaurantName: '테스트 식당',
            menuName: '버섯 국수',
            category: '한식',
            location: '가상 동네',
            date: date,
            searchKeyword: 'legacy-keyword',
          ),
        );
        await Hive.close();

        final reopened = LocalDBService();
        await reopened.initDB();
        final saved = reopened.getAllItems().single;
        expect(saved.id, 'fixture-record');
        expect(saved.imagePath, 'photos/fixture.jpg');
        expect(saved.restaurantName, '테스트 식당');
        expect(saved.menuName, '버섯 국수');
        expect(saved.category, '한식');
        expect(saved.location, '가상 동네');
        expect(saved.date, date);
        expect(reopened.searchItems('버섯 가상').single.id, saved.id);
        expect(reopened.searchItems('없는메뉴'), isEmpty);

        await reopened.updateItem(
          ArchiveItem(
            id: saved.id,
            imagePath: saved.imagePath,
            restaurantName: saved.restaurantName,
            menuName: '수정 메뉴',
            category: saved.category,
            location: saved.location,
            date: saved.date,
            searchKeyword: '테스트식당가상동네수정메뉴한식',
          ),
        );
        await Hive.close();
        final afterEdit = LocalDBService();
        await afterEdit.initDB();
        expect(afterEdit.getAllItems(), hasLength(1));
        expect(
          afterEdit.searchItems('수정 메뉴').single.imagePath,
          'photos/fixture.jpg',
        );
        expect(afterEdit.searchItems('버섯'), isEmpty);
      } finally {
        await Hive.close();
        PathProviderPlatform.instance = originalPaths;
        await temporary.delete(recursive: true);
      }
    },
  );
}
