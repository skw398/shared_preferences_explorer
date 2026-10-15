import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('SharedPreferencesExplorerScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'action': 'Start',
        'counter': 10,
        'repeat': true,
      });
    });

    Future<void> pumpExplorer(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SharedPreferencesExplorerScreen(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Lists all saved values', (tester) async {
      await pumpExplorer(tester);

      expect(find.text('3 results'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.text('action'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('counter'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('repeat'), findsOneWidget);
      expect(find.text('true'), findsOneWidget);
    });

    testWidgets('Lists no value when nothing is saved', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await pumpExplorer(tester);

      expect(find.text('0 results'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('Filters values by search text', (tester) async {
      await pumpExplorer(tester);

      await tester.enterText(find.byType(TextField), 'repeat');
      await tester.pumpAndSettle();

      expect(find.text('1 results'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('true'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
      expect(find.text('10'), findsNothing);
    });

    testWidgets('Filters values by value type chip', (tester) async {
      await pumpExplorer(tester);

      await tester.tap(find.widgetWithText(FilterChip, 'bool'));
      await tester.pumpAndSettle();

      expect(find.text('1 results'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('repeat'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
      expect(find.text('10'), findsNothing);
    });

    testWidgets('Exports the filtered values', (tester) async {
      await pumpExplorer(tester);

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('Copy as JSON'), findsOneWidget);
      expect(find.text('Dump as JSON'), findsOneWidget);

      await tester.tap(find.text('Copy as JSON'));
      await tester.pumpAndSettle();

      expect(find.text('Copied to clipboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SharedPreferencesAsyncExplorerScreen', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    testWidgets('Lists and filters values from SharedPreferencesAsync',
        (tester) async {
      final prefs = SharedPreferencesAsync();
      await prefs.setString('action', 'Stop');
      await prefs.setInt('counter', 10);

      await tester.pumpWidget(
        MaterialApp(
          home: SharedPreferencesAsyncExplorerScreen(instance: prefs),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 results'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Stop'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'stop');
      await tester.pumpAndSettle();

      expect(find.text('1 results'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('action'), findsOneWidget);
      expect(find.text('counter'), findsNothing);
    });
  });
}
