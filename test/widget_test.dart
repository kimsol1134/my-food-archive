import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_food_archive/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
