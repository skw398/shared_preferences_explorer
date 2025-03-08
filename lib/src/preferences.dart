import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/preference.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_instance_container.dart';

class Preferences {
  Preferences._(this._preferences);

  final List<Preference> _preferences;

  static Future<Preferences> init({
    required SharedPreferencesInstanceContainer instanceContainer,
  }) async {
    final result = <Preference>[];

    final sharedPreferences = instanceContainer.sharedPreferences;
    final sharedPreferencesAsync = instanceContainer.sharedPreferencesAsync;

    if (sharedPreferencesAsync != null) {
      final preferences = await sharedPreferencesAsync.getAll();
      for (final entry in preferences.entries) {
        assert(entry.value != null, 'Unexpected');

        // Skip legacy SharedPreferences keys
        const legacyPrefix = 'flutter.';
        if (entry.key.startsWith(legacyPrefix)) {
          continue;
        }

        result.add(
          Preference.fromKey(entry.key, entry.value!),
        );
      }
    }

    if (sharedPreferences != null) {
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        final value = sharedPreferences.get(key);
        assert(value != null, 'Unexpected');

        result.add(
          Preference.fromKey(key, value!),
        );
      }
    }

    result.sort((a, b) => a.key.compareTo(b.key));

    return Preferences._(result);
  }

  List<Preference> filtered(Filter filter) {
    return _preferences.where((preference) {
      final typeMatch = filter.valueTypes.isEmpty ||
          filter.valueTypes.contains(preference.valueType);

      final textMatch = preference.key
              .toLowerCase()
              .contains(filter.searchText.toLowerCase()) ||
          preference.value
              .toString()
              .toLowerCase()
              .contains(filter.searchText.toLowerCase());

      return typeMatch && textMatch;
    }).toList();
  }
}
