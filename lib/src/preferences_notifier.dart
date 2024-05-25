import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'filter.dart';
import 'preference.dart';

class PreferencesNotifier extends ValueNotifier<List<Preference>> {
  PreferencesNotifier._(this._sharedPreferences) : super([]);

  final SharedPreferences _sharedPreferences;

  static Future<PreferencesNotifier> init({
    SharedPreferences? sharedPreferences,
  }) async {
    final result = PreferencesNotifier._(
      sharedPreferences ?? await SharedPreferences.getInstance(),
    );
    await result._load();
    return result;
  }

  Future<bool> update(Preference preference, Object newValue) async {
    bool succeeded;

    if (newValue is int) {
      succeeded = await _sharedPreferences.setInt(preference.key, newValue);
    } else if (newValue is double) {
      succeeded = await _sharedPreferences.setDouble(preference.key, newValue);
    } else if (newValue is bool) {
      succeeded = await _sharedPreferences.setBool(preference.key, newValue);
    } else if (newValue is String) {
      succeeded = await _sharedPreferences.setString(preference.key, newValue);
    } else if (newValue is List<String>) {
      succeeded =
          await _sharedPreferences.setStringList(preference.key, newValue);
    } else {
      throw AssertionError('Unexpected type');
    }

    if (succeeded) {
      final newPreferences = List<Preference>.from(value);
      final key = preference.key;

      final index =
          newPreferences.indexWhere((preference) => preference.key == key);
      final newPreference = _preferenceFor(key);
      assert(index != -1 && newPreference != null, 'Unexpected');
      newPreferences[index] = newPreference!;

      value = newPreferences;
    }

    return succeeded;
  }

  Future<bool> remove(String key) async {
    final succeeded = await _sharedPreferences.remove(key);
    value = List<Preference>.from(value)
      ..removeWhere((pref) => pref.key == key);
    return succeeded;
  }

  Future<bool> clear() async {
    final succeeded = await _sharedPreferences.clear();
    value = [];
    return succeeded;
  }

  List<Preference> filtered(Filter filter) {
    return value.where((preference) {
      final typeMatch = filter.valueTypes.isEmpty ||
          filter.valueTypes.contains(preference.valueType);
      final textMatch =
          preference.key.toLowerCase().contains(filter.text.toLowerCase());

      return typeMatch && textMatch;
    }).toList();
  }

  Future<void> _load() async {
    final result = <Preference>[];

    final keys = _sharedPreferences.getKeys();
    for (final key in keys) {
      final preference = _preferenceFor(key);
      assert(preference != null, 'Unexpected');
      result.add(preference!);
    }
    result.sort((a, b) => a.key.compareTo(b.key));

    value = result;
  }

  Preference? _preferenceFor(String key) {
    final value = _sharedPreferences.get(key);
    if (value != null) {
      return Preference(key, value);
    } else {
      return null;
    }
  }
}
