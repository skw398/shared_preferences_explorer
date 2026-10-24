// This file checks how the package behaves in an app that still uses the SDK's
// Material library. Importing it is the point of the test; the deprecation is
// expected until the in-framework library is removed, at which point this test
// should be deleted.
// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
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

  testWidgets('The floating button widgets do not require material_ui', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'counter': 10, 'repeat': true});

    await tester.pumpWidget(
      legacy.MaterialApp(
        home: const SharedPreferencesExplorer(child: legacy.Scaffold()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(mui.FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('2 results'), findsOneWidget);

    // The screen opened by the floating button must also have access to
    // material_ui's ScaffoldMessenger.
    await tester.tap(
      find.descendant(
        of: find.byType(mui.AppBar),
        matching: find.byIcon(mui.Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy as JSON'));
    await tester.pumpAndSettle();

    expect(find.text('Copied to clipboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
