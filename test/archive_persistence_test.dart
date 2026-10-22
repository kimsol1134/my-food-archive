import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_food_archive/models/archive_item.dart';
import 'package:my_food_archive/providers/archive_provider.dart';

import 'support/archive_test_environment.dart';

ArchiveItem record(
  String id, {
  String menu = '크림 파스타',
  String location = '연남동',
  DateTime? date,
  String? keyword,
}) => ArchiveItem(
  id: id,
  imagePath: 'images/$id.jpg',
  restaurantName: '맛있는 집',
  menuName: menu,
  category: '양식',
  location: location,
  date: date,
  searchKeyword:
      keyword ??
      ArchiveItem.generateSearchKeyword(
        restaurantName: '맛있는 집',
        menuName: menu,
        category: '양식',
        location: location,
      ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final env = ArchiveTestEnvironment();
  setUpAll(env.open);
  setUp(env.clear);
  tearDownAll(env.close);

  test(
    'saved fields and photo survive closing and reopening the database',
    () async {
      final item = record('saved', date: DateTime(2026, 10, 22));
      final photo = File('${env.directory.path}/${item.imagePath}');
      await photo.writeAsBytes([1, 2, 3]);
      await env.db.addItem(item);
      await env.reopen();
      final saved = env.db.getAllItems().single;
      expect(saved.id, 'saved');
      expect(saved.restaurantName, '맛있는 집');
      expect(saved.menuName, '크림 파스타');
      expect(saved.category, '양식');
      expect(saved.location, '연남동');
      expect(saved.date, DateTime(2026, 10, 22));
      expect(saved.imagePath, 'images/saved.jpg');
      expect(await photo.readAsBytes(), [1, 2, 3]);
    },
  );

  test(
    'multi-word search requires all terms, ignores extra whitespace, and sorts dates',
    () async {
      await env.db.addItem(record('old', date: DateTime(2025)));
      await env.db.addItem(record('new', date: DateTime(2026)));
      await env.db.addItem(record('undated'));
      await env.db.addItem(record('other-menu', menu: '피자'));
      await env.db.addItem(record('other-area', location: '강남'));
      expect(env.db.searchItems('  연남동 \t 파스타\n').map((x) => x.id), [
        'new',
        'old',
        'undated',
      ]);
      expect(env.db.searchItems('연남동 초밥'), isEmpty);
      expect(env.db.searchItems('맛있는집').length, 5);
      expect(env.db.searchItems('   ').length, 5);
    },
  );

  test(
    'editing refreshes an active search and persists without duplicating the record',
    () async {
      final provider = ArchiveProvider(env.db);
      addTearDown(provider.dispose);
      await provider.addItem(record('edit'));
      provider.search('파스타');
      expect(provider.items, hasLength(1));
      await provider.updateItem(record('edit', menu: '피자'));
      expect(provider.items, isEmpty);
      provider.search('피자');
      expect(provider.items.single.id, 'edit');
      await env.reopen();
      expect(env.db.getAllItems(), hasLength(1));
      expect(env.db.searchItems('파스타'), isEmpty);
      expect(env.db.searchItems('피자').single.menuName, '피자');
    },
  );

  test(
    'delete removes the record and its photo but preserves other photos',
    () async {
      final provider = ArchiveProvider(env.db);
      addTearDown(provider.dispose);
      final item = record('delete');
      final photo = File('${env.directory.path}/${item.imagePath}');
      final other = File('${env.directory.path}/images/keep.jpg');
      await photo.writeAsBytes([1]);
      await other.writeAsBytes([2]);
      await provider.addItem(item);
      provider.search('파스타');
      await provider.deleteItem(item);
      expect(provider.items, isEmpty);
      expect(await photo.exists(), isFalse);
      expect(await other.readAsBytes(), [2]);
      await env.reopen();
      expect(env.db.getAllItems(), isEmpty);
    },
  );

  test('delete still succeeds when the photo is already missing', () async {
    final provider = ArchiveProvider(env.db);
    addTearDown(provider.dispose);
    final item = record('missing-photo');
    await provider.addItem(item);
    await provider.deleteItem(item);
    expect(provider.items, isEmpty);
    await env.reopen();
    expect(env.db.getAllItems(), isEmpty);
  });

  test(
    'reopening rebuilds legacy search keywords without losing record fields',
    () async {
      await env.db.addItem(
        record('legacy', keyword: 'stale', date: DateTime(2026)),
      );
      await env.reopen();
      final saved = env.db.searchItems('연남동 파스타').single;
      expect(saved.id, 'legacy');
      expect(saved.date, DateTime(2026));
      expect(saved.restaurantName, '맛있는 집');
      expect(saved.imagePath, 'images/legacy.jpg');
      expect(env.db.searchItems('stale'), isEmpty);
    },
  );
}
