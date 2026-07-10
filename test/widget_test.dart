// 앱 부트스트랩 스모크 테스트.
//
// Task 5에서 MyApp이 LocalDBService(Hive) 주입을 요구하도록 바뀌었으므로,
// 임시 디렉토리에 실제 Hive Box를 열어 주입한 뒤 앱이 라이트 모드로 정상
// 부팅되는지 확인한다. path_provider는 페이크로 대체해 Hive.initFlutter()가
// 테스트 환경(플러그인 채널 없음)에서도 동작하게 한다.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:my_food_archive/main.dart';
import 'package:my_food_archive/services/local_db_service.dart';

/// `getApplicationDocumentsDirectory()`가 임시 디렉토리를 반환하도록 하는 페이크.
/// Hive.initFlutter()는 이 경로만 사용하므로 나머지 메서드는 구현하지 않는다.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.directory);

  final String directory;

  @override
  Future<String?> getApplicationDocumentsPath() async => directory;
}

void main() {
  late Directory tempDir;
  late LocalDBService dbService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mfa_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);

    dbService = LocalDBService();
    await dbService.initDB();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('앱이 라이트 모드로 부팅된다', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(dbService: dbService));

    // MaterialApp이 라이트 모드로 고정되어 있는지 확인.
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);

    // 흰색 배경의 Scaffold가 렌더링되는지 확인.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
