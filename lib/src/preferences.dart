import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/preference.dart';
import 'package:shared_preferences_explorer/src/shared_preference_type.dart';

class Preferences {
  Preferences._(this._preferences);

  final List<Preference> _preferences;

  static Future<Preferences> init() async {
    final result = <Preference>[];

    // SharedPreferencesAsync can get all including Legacy.
    final preferences = await SharedPreferencesAsync().getAll();
    for (final entry in preferences.entries) {
      assert(entry.value != null, 'Unexpected');
      result.add(
        Preference.fromNativeKey(
          entry.key,
          entry.value!,
        ),
      );
    }

    // SharedPreferencesAsync cannot get Legacy on Android.
    if (!kIsWeb && Platform.isAndroid) {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        final value = prefs.get(key);
        assert(value != null, 'Unexpected');
        result.add(
          Preference.fromKey(
            key,
            value!,
            sharedPreferencesType: SharedPreferencesType.legacy,
          ),
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
