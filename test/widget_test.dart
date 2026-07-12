import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:my_food_archive/main.dart';
import 'package:my_food_archive/services/local_db_service.dart';

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

  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(dbService: dbService));
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Privacy policy is reachable from the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(dbService: dbService));

    await tester.tap(find.byTooltip('앱 정보 및 개인정보처리방침'));
    await tester.pumpAndSettle();

    expect(find.text('앱 정보 및 개인정보처리방침'), findsOneWidget);
    expect(find.text('AI 분석을 위한 전송'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('온라인 개인정보처리방침 열기'), findsOneWidget);
  });
}
