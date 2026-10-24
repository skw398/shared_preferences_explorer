import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';

void main() {
  testWidgets('Screen widgets explain that a material_ui host is required', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'counter': 10});

    await tester.pumpWidget(
      legacy.MaterialApp(home: const SharedPreferencesExplorerScreen()),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('material_ui'));
    expect(error.toString(), contains('migrate_design_widgets'));
  });
}
