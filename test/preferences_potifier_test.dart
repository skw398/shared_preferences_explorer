import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/preferences_notifier.dart';
import 'package:shared_preferences_explorer/src/value_type.dart';

void main() {
  group('PreferencesNotifier', () {
    late SharedPreferences sharedPreferences;
    late PreferencesNotifier preferences;

    setUp(() async {
      final values = <String, Object>{
        'counter': 10,
        'repeat': true,
        'decimal': 1.5,
        'action': 'Start',
        'items': ['Earth', 'Moon', 'Sun'],
      };
      SharedPreferences.setMockInitialValues(values);
      sharedPreferences = await SharedPreferences.getInstance();
      preferences =
          await PreferencesNotifier.init(sharedPreferences: sharedPreferences);
    });

    test('init', () async {
      expect(preferences.value.length, 5);
      expect(preferences.value[0].key, 'action');
      expect(preferences.value[0].value, 'Start');
      expect(preferences.value[1].key, 'counter');
      expect(preferences.value[1].value, 10);
      expect(preferences.value[2].key, 'decimal');
      expect(preferences.value[2].value, 1.5);
      expect(preferences.value[3].key, 'items');
      expect(preferences.value[3].value, ['Earth', 'Moon', 'Sun']);
      expect(preferences.value[4].key, 'repeat');
      expect(preferences.value[4].value, true);
    });

    test('update', () async {
      await preferences.update(preferences.value[1], 20);
      expect(preferences.value[1].value, 20);
      await preferences.update(preferences.value[4], false);
      expect(preferences.value[4].value, false);
      await preferences.update(preferences.value[2], 2.5);
      expect(preferences.value[2].value, 2.5);
      await preferences.update(preferences.value[0], 'Stop');
      expect(preferences.value[0].value, 'Stop');
      await preferences
          .update(preferences.value[3], ['Mars', 'Jupiter', 'Saturn']);
      expect(preferences.value[3].value, ['Mars', 'Jupiter', 'Saturn']);
    });

    test('remove', () async {
      await preferences.remove('counter');
      expect(preferences.value.length, 4);
      expect(
        preferences.value.where((pref) => pref.key == 'counter').isEmpty,
        true,
      );
    });

    test('clear', () async {
      await preferences.clear();
      expect(preferences.value.isEmpty, true);
    });

    test('filtered', () {
      final filter = Filter()
        ..valueTypes = [ValueType.intOrDouble, ValueType.stringList]
        ..text = 'e';

      final filtered = preferences.filtered(filter);
      expect(filtered.length, 3);
      expect(filtered[0].key, 'counter');
      expect(filtered[1].key, 'decimal');
      expect(filtered[2].key, 'items');
    });
  });
}
