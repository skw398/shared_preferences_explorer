import 'package:shared_preferences_explorer/src/shared_preference_type.dart';
import 'package:shared_preferences_explorer/src/value_type.dart';

class Preference {
  Preference.fromKey(
    this.key,
    this.value, {
    required this.sharedPreferencesType,
  }) {
    valueType = ValueType.from(value);
  }

  Preference.fromNativeKey(
    String key,
    this.value,
  ) {
    const legazyPrefix = 'flutter.';
    final isLegacy = key.startsWith(legazyPrefix);
    this.key = isLegacy ? key.substring(legazyPrefix.length) : key;
    sharedPreferencesType = isLegacy
        ? SharedPreferencesType.legacy
        : SharedPreferencesType.asyncOrWithCache;
    valueType = ValueType.from(value);
  }

  late final String key;
  final Object value;
  late final SharedPreferencesType sharedPreferencesType;
  late final ValueType valueType;
}
