import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';

void main() {
  group('SharedPreferencesExplorer flows', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete flow: open explorer, search, filter, and close', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Alice',
        'user_age': 30,
        'user_score': 95.5,
        'admin_name': 'Bob',
        'admin_level': 5,
        'is_active': true,
        'tags': ['flutter', 'dart', 'mobile'],
      });

      await tester.pumpWidget(
        SharedPreferencesExplorer(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test App')),
              body: const Center(child: Text('Main Content')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
      expect(find.byIcon(Icons.source), findsOneWidget);

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      expect(find.text('Search key or value'), findsOneWidget);
      expect(find.text('7 results'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'user');
      await tester.pumpAndSettle();

      expect(find.text('3 results'), findsOneWidget);
      expect(find.text('user_name'), findsOneWidget);
      expect(find.text('user_age'), findsOneWidget);
      expect(find.text('user_score'), findsOneWidget);
      expect(find.text('admin_name'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'int, double'));
      await tester.pumpAndSettle();

      expect(find.text('2 results'), findsOneWidget);
      expect(find.text('user_age'), findsOneWidget);
      expect(find.text('user_score'), findsOneWidget);
      expect(find.text('user_name'), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Search key or value'), findsNothing);
    });

    testWidgets('List view screen: open, reverse, and navigate back', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'items': ['first', 'second', 'third', 'fourth'],
      });

      await tester.pumpWidget(
        SharedPreferencesExplorer(
          child: MaterialApp(
            home: Scaffold(body: const Center(child: Text('Main Content'))),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      expect(find.text('Show as list'), findsOneWidget);

      await tester.tap(find.text('Show as list'));
      await tester.pumpAndSettle();

      expect(find.text('items'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('first'), findsOneWidget);

      final listTilesBefore = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      final firstSubtitleBefore =
          listTilesBefore.first.subtitle as SelectableText;
      expect(firstSubtitleBefore.data, 'first');

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      final listTilesAfter = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      final firstSubtitleAfter =
          listTilesAfter.first.subtitle as SelectableText;
      expect(firstSubtitleAfter.data, 'fourth');

      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Search key or value'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('Long text view screen: open and navigate back', (
      WidgetTester tester,
    ) async {
      final longText = 'a' * 350;
      SharedPreferences.setMockInitialValues({'long_text': longText});

      await tester.pumpWidget(
        SharedPreferencesExplorer(
          child: MaterialApp(
            home: Scaffold(body: const Center(child: Text('Main Content'))),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      expect(find.text('Show all'), findsOneWidget);

      await tester.tap(find.text('Show all'));
      await tester.pumpAndSettle();

      expect(find.text('long_text'), findsOneWidget);
      expect(find.text(longText), findsOneWidget);
      expect(find.byType(Scrollbar), findsOneWidget);

      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Search key or value'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('Multiple filters combination', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'name': 'Alice',
        'age': 30,
        'active': true,
        'score': 95.5,
        'tags': ['flutter'],
      });

      await tester.pumpWidget(
        SharedPreferencesExplorer(
          child: MaterialApp(
            home: Scaffold(body: const Center(child: Text('Main Content'))),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      expect(find.text('5 results'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'String'));
      await tester.pumpAndSettle();
      expect(find.text('1 results'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'bool'));
      await tester.pumpAndSettle();
      expect(find.text('2 results'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'List<String>'));
      await tester.pumpAndSettle();
      expect(find.text('3 results'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'String'));
      await tester.pumpAndSettle();
      expect(find.text('2 results'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'bool'));
      await tester.pumpAndSettle();
      expect(find.text('1 results'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'List<String>'));
      await tester.pumpAndSettle();
      expect(find.text('5 results'), findsOneWidget);
    });

    testWidgets('Floating button drag and reposition', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        SharedPreferencesExplorer(
          initialFloatingButtonAlignment: FloatingButtonAlignment.bottomRight,
          child: MaterialApp(
            home: Scaffold(body: const Center(child: Text('Main Content'))),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.source), findsOneWidget);

      final initialPosition = tester.getTopLeft(find.byIcon(Icons.source));

      await tester.drag(find.byIcon(Icons.source), const Offset(-300, -200));
      await tester.pumpAndSettle();

      final finalPosition = tester.getTopLeft(find.byIcon(Icons.source));

      expect(finalPosition, isNot(equals(initialPosition)));

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      expect(find.text('Search key or value'), findsOneWidget);
    });

    testWidgets('Empty preferences display', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        SharedPreferencesExplorer(
          child: MaterialApp(
            home: Scaffold(body: const Center(child: Text('Main Content'))),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      expect(find.text('0 results'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('Search persists when reopening explorer', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'key1': 'value1',
        'key2': 'value2',
      });

      await tester.pumpWidget(
        SharedPreferencesExplorer(
          child: MaterialApp(
            home: Scaffold(body: const Center(child: Text('Main Content'))),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'key1');
      await tester.pumpAndSettle();

      expect(find.text('1 results'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.source));
      await tester.pumpAndSettle();

      expect(find.text('1 results'), findsOneWidget);
      expect(find.text('key1'), findsWidgets);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'key1');
    });
  });
}
