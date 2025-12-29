import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/preference.dart';
import 'package:shared_preferences_explorer/src/preferences.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_instance_container.dart';
import 'package:shared_preferences_explorer/src/value_type.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('Preferences.init (SharedPreferences)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes from empty SharedPreferences', () async {
      final sharedPrefs = await SharedPreferences.getInstance();
      final container = SharedPreferencesInstanceContainer(
        sharedPreferences: sharedPrefs,
      );

      final prefs = await Preferences.init(instanceContainer: container);
      final result = prefs.filtered(const Filter());

      expect(result, isEmpty);
    });

    test('Correctly loads data of multiple types', () async {
      SharedPreferences.setMockInitialValues({
        'username': 'Alice',
        'age': 25,
        'score': 95.5,
        'is_active': true,
        'tags': <String>['flutter', 'dart'],
      });
      final sharedPrefs = await SharedPreferences.getInstance();
      final container = SharedPreferencesInstanceContainer(
        sharedPreferences: sharedPrefs,
      );

      final prefs = await Preferences.init(instanceContainer: container);
      final result = prefs.filtered(const Filter());

      expect(result.length, 5);
      expect(result[0].key, 'age');
      expect(result[0].valueType, ValueType.intOrDouble);
      expect(result[1].key, 'is_active');
      expect(result[1].valueType, ValueType.bool);
      expect(result[2].key, 'score');
      expect(result[2].valueType, ValueType.intOrDouble);
      expect(result[3].key, 'tags');
      expect(result[3].valueType, ValueType.stringList);
      expect(result[4].key, 'username');
      expect(result[4].valueType, ValueType.string);
    });

    test('Sorted by key name', () async {
      SharedPreferences.setMockInitialValues({
        'zebra': 'z',
        'apple': 'a',
        'mango': 'm',
      });
      final sharedPrefs = await SharedPreferences.getInstance();
      final container = SharedPreferencesInstanceContainer(
        sharedPreferences: sharedPrefs,
      );

      final prefs = await Preferences.init(instanceContainer: container);
      final result = prefs.filtered(const Filter());

      expect(result[0].key, 'apple');
      expect(result[1].key, 'mango');
      expect(result[2].key, 'zebra');
    });

    test('Can filter after initialization', () async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Alice',
        'user_age': 25,
        'admin_name': 'Bob',
        'admin_level': 5,
      });
      final sharedPrefs = await SharedPreferences.getInstance();
      final container = SharedPreferencesInstanceContainer(
        sharedPreferences: sharedPrefs,
      );

      final prefs = await Preferences.init(instanceContainer: container);

      final userPrefs = prefs.filtered(const Filter(searchText: 'user'));
      expect(userPrefs.length, 2);
      expect(userPrefs[0].key, 'user_age');
      expect(userPrefs[1].key, 'user_name');

      final intPrefs = prefs.filtered(
        const Filter(valueTypes: [ValueType.intOrDouble]),
      );
      expect(intPrefs.length, 2);
      expect(intPrefs[0].key, 'admin_level');
      expect(intPrefs[1].key, 'user_age');
    });
  });

  group('Preferences.init (SharedPreferencesAsync)', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('Initializes from empty SharedPreferencesAsync', () async {
      final fakeAsync = SharedPreferencesAsync();
      final container = SharedPreferencesInstanceContainer(
        sharedPreferencesAsync: fakeAsync,
      );

      final prefs = await Preferences.init(instanceContainer: container);
      final result = prefs.filtered(const Filter());

      expect(result, isEmpty);
    });

    test('Correctly loads data of multiple types', () async {
      final fakeAsync = SharedPreferencesAsync();
      await fakeAsync.setString('username', 'Alice');
      await fakeAsync.setInt('age', 25);
      await fakeAsync.setDouble('score', 95.5);
      await fakeAsync.setBool('is_active', true);
      await fakeAsync.setStringList('tags', <String>['flutter', 'dart']);

      final container = SharedPreferencesInstanceContainer(
        sharedPreferencesAsync: fakeAsync,
      );

      final prefs = await Preferences.init(instanceContainer: container);
      final result = prefs.filtered(const Filter());

      expect(result.length, 5);
      expect(result[0].key, 'age');
      expect(result[0].valueType, ValueType.intOrDouble);
      expect(result[1].key, 'is_active');
      expect(result[1].valueType, ValueType.bool);
      expect(result[2].key, 'score');
      expect(result[2].valueType, ValueType.intOrDouble);
      expect(result[3].key, 'tags');
      expect(result[3].valueType, ValueType.stringList);
      expect(result[4].key, 'username');
      expect(result[4].valueType, ValueType.string);
    });

    test('Skips legacy keys starting with flutter.', () async {
      final fakeAsync = SharedPreferencesAsync();
      await fakeAsync.setString('flutter.skippedKey', 'should be skipped');
      await fakeAsync.setInt('flutter.anotherLegacy', 42);
      await fakeAsync.setString('normalKey', 'visible');
      await fakeAsync.setBool('user_setting', true);

      final container = SharedPreferencesInstanceContainer(
        sharedPreferencesAsync: fakeAsync,
      );

      final prefs = await Preferences.init(instanceContainer: container);
      final result = prefs.filtered(const Filter());

      expect(result.length, 2);
      expect(result[0].key, 'normalKey');
      expect(result[1].key, 'user_setting');
      expect(result.any((p) => p.key.startsWith('flutter.')), isFalse);
    });

    test('Sorted by key name', () async {
      final fakeAsync = SharedPreferencesAsync();
      await fakeAsync.setString('zebra', 'z');
      await fakeAsync.setString('apple', 'a');
      await fakeAsync.setString('mango', 'm');

      final container = SharedPreferencesInstanceContainer(
        sharedPreferencesAsync: fakeAsync,
      );

      final prefs = await Preferences.init(instanceContainer: container);
      final result = prefs.filtered(const Filter());

      expect(result[0].key, 'apple');
      expect(result[1].key, 'mango');
      expect(result[2].key, 'zebra');
    });
  });

  group('Preferences.filtered', () {
    test('Can filter by valueTypes with filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('key1', 'string value'),
        Preference.fromKey('key2', 42),
        Preference.fromKey('key3', true),
        Preference.fromKey('key4', 3.14),
      ]);

      const filter = Filter(
        valueTypes: [ValueType.intOrDouble],
      );

      final result = prefs.filtered(filter);

      expect(result.length, 2);
      expect(result[0].key, 'key2');
      expect(result[1].key, 'key4');
    });

    test('Can filter by key with searchText in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('user_name', 'Alice'),
        Preference.fromKey('user_age', 25),
        Preference.fromKey('settings_theme', 'dark'),
        Preference.fromKey('settings_language', 'en'),
      ]);

      const filter = Filter(
        searchText: 'user',
      );

      final result = prefs.filtered(filter);

      expect(result.length, 2);
      expect(result[0].key, 'user_name');
      expect(result[1].key, 'user_age');
    });

    test('Can filter by value with searchText in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('name', 'Alice'),
        Preference.fromKey('city', 'Tokyo'),
        Preference.fromKey('country', 'Japan'),
      ]);

      const filter = Filter(
        searchText: 'Japan',
      );

      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'country');
    });

    test(
        'Can filter List<String> with multiple partial matches in filtered method',
        () {
      final prefs = Preferences([
        Preference.fromKey('tags', ['flutter_plugin', 'love_flutter', 'dart']),
        Preference.fromKey('another_key', 'some value'),
      ]);

      const filter = Filter(
        searchText: 'flutter',
      );

      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'tags');
    });

    test('Can filter case-insensitively in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('userName', 'Alice'),
        Preference.fromKey('PASSWORD', 'secret'),
        Preference.fromKey('email', 'alice@example.com'),
      ]);

      const filter = Filter(
        searchText: 'password',
      );

      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'PASSWORD');
    });

    test('Can filter by numeric value with searchText in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('count', 123),
        Preference.fromKey('another_key', 456),
      ]);

      const filter = Filter(
        searchText: '23',
      );

      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'count');
    });

    test('Can filter by boolean value with searchText in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('is_active', true),
        Preference.fromKey('is_enabled', false),
      ]);

      const filter = Filter(
        searchText: 'true',
      );

      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'is_active');
    });

    test('Can filter by both valueTypes and searchText in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('user_count', 100),
        Preference.fromKey('user_name', 'Bob'),
        Preference.fromKey('admin_count', 5),
        Preference.fromKey('admin_name', 'Alice'),
      ]);

      const filter = Filter(
        valueTypes: [ValueType.intOrDouble],
        searchText: 'user',
      );

      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'user_count');
      expect(result[0].value, 100);
    });

    test('All types included if valueTypes is empty in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('key1', 'string'),
        Preference.fromKey('key2', 42),
        Preference.fromKey('key3', true),
      ]);

      const filter = Filter();

      final result = prefs.filtered(filter);

      expect(result.length, 3);
    });

    test('Returns empty list if no match in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('key1', 'value1'),
        Preference.fromKey('key2', 'value2'),
      ]);

      const filter = Filter(
        valueTypes: [ValueType.intOrDouble],
      );

      final result = prefs.filtered(filter);

      expect(result, isEmpty);
    });

    test('Returns all if no filter in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('key1', 'value1'),
        Preference.fromKey('key2', 42),
        Preference.fromKey('key3', true),
      ]);

      const filter = Filter();

      final result = prefs.filtered(filter);

      expect(result.length, 3);
    });

    test('Can filter by multiple valueTypes', () {
      final prefs = Preferences([
        Preference.fromKey('key1', 'string'),
        Preference.fromKey('key2', 42),
        Preference.fromKey('key3', true),
        Preference.fromKey('key4', <String>['list']),
      ]);

      const filter = Filter(
        valueTypes: [ValueType.string, ValueType.bool, ValueType.stringList],
      );

      final result = prefs.filtered(filter);

      expect(result.length, 3);
      expect(result[0].key, 'key1');
      expect(result[1].key, 'key3');
      expect(result[2].key, 'key4');
    });

    test('Returns all items if searchText is empty in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('key1', 'value1'),
        Preference.fromKey('key2', 42),
      ]);

      const filter = Filter();
      final result = prefs.filtered(filter);

      expect(result.length, 2);
    });

    test('Can filter by value case-insensitively in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('name', 'Alice'),
        Preference.fromKey('city', 'Tokyo'),
      ]);

      const filter = Filter(searchText: 'alice');
      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'name');
    });

    test('Can filter List<String> case-insensitively in filtered method', () {
      final prefs = Preferences([
        Preference.fromKey('tags', ['Flutter', 'DART']),
        Preference.fromKey('another_key', 'some value'),
      ]);

      const filter = Filter(searchText: 'flutter');
      final result = prefs.filtered(filter);

      expect(result.length, 1);
      expect(result[0].key, 'tags');
    });
  });
}
