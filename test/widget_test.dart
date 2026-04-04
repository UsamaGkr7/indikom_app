import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indikom_app/main.dart';
import 'package:indikom_app/core/constants/hive_keys.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for tests
    await Hive.initFlutter();
    await Hive.openBox(HiveKeys.authBox);
    await Hive.openBox(HiveKeys.settingsBox);
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create a settings box instance
    final settingsBox = Hive.box(HiveKeys.settingsBox);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(settingsBox: settingsBox));

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
