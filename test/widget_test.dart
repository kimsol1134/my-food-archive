import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:my_food_archive/main.dart';
import 'package:my_food_archive/services/local_db_service.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await Hive.initFlutter();
    final dbService = LocalDBService();
    await dbService.initDB();

    await tester.pumpWidget(MyApp(dbService: dbService));
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
