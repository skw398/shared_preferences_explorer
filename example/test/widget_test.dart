import 'package:example/my_app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'counter': 0});
  });

  testWidgets('Counter increments and resets the saved value', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getInt('counter'), 1);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getInt('counter'), 0);
  });

  testWidgets('Debug menu opens the shared preferences explorer', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'counter': 10,
      'repeat': true,
      'action': 'Start',
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('DEBUG'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SharedPreferences values'));
    await tester.pumpAndSettle();

    expect(find.text('3 results'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
