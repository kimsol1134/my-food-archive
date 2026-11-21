import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_food_archive/models/ai_result.dart';
import 'package:my_food_archive/models/exif_result.dart';
import 'package:my_food_archive/providers/archive_provider.dart';
import 'package:my_food_archive/screens/add_edit_record_screen.dart';
import 'package:my_food_archive/services/exif_service.dart';
import 'package:my_food_archive/services/vision_ai_service.dart';

import 'support/archive_test_environment.dart';

class _ControlledAI extends VisionAIService {
  final result = Completer<AiResult?>();
  @override
  Future<AiResult?> analyzeImage(String imagePath) => result.future;
}

class _NoMetadata extends ExifService {
  @override
  Future<ExifResult> extract(String imagePath) async => const ExifResult();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final env = ArchiveTestEnvironment();
  setUpAll(env.open);
  setUp(env.clear);
  tearDownAll(env.close);

  for (final aiSucceeds in [false, true]) {
    testWidgets(
      aiSucceeds
          ? 'AI suggestions remain editable and the corrected values are saved'
          : 'AI failure unlocks manual entry and the record survives reopening',
      (tester) async {
        final provider = ArchiveProvider(env.db);
        final ai = _ControlledAI();
        addTearDown(provider.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: provider,
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AddEditRecordScreen(
                          imagePath: 'images/example.jpg',
                          visionAIService: ai,
                          exifService: _NoMetadata(),
                        ),
                      ),
                    ),
                    child: const Text('기록 시작'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('기록 시작'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('AI가 사진을 분석하고 있어요...'), findsOneWidget);
        ElevatedButton saveButton() => tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('저장'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(saveButton().onPressed, isNull);

        ai.result.complete(
          aiSucceeds ? const AiResult(menuName: 'AI 메뉴', category: '양식') : null,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.text('AI가 사진을 분석하고 있어요...'), findsNothing);
        if (!aiSucceeds) {
          expect(find.text('정보를 직접 입력해 주세요'), findsOneWidget);
        } else {
          expect(find.text('AI 메뉴'), findsOneWidget);
        }
        expect(saveButton().onPressed, isNull);
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), '   ');
        await tester.pump();
        expect(saveButton().onPressed, isNull);
        await tester.enterText(fields.at(0), '  나의 식당  ');
        await tester.enterText(fields.at(1), '연남동');
        await tester.enterText(fields.at(2), '수정한 메뉴');
        await tester.enterText(fields.at(3), '한식');
        await tester.pump();
        expect(saveButton().onPressed, isNotNull);

        // Hive uses real filesystem I/O, outside the widget test's fake clock.
        await tester.runAsync(
          saveButton().onPressed! as Future<void> Function(),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(find.text('기록 시작'), findsOneWidget);
        await tester.runAsync(env.reopen);
        final saved = env.db.getAllItems().single;
        expect(saved.restaurantName, '나의 식당');
        expect(saved.menuName, '수정한 메뉴');
        expect(saved.category, '한식');
        expect(saved.location, '연남동');
        expect(saved.imagePath, 'images/example.jpg');
        expect(saved.date, isNull);
        expect(env.db.searchItems('연남동 수정한메뉴').single.id, saved.id);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
