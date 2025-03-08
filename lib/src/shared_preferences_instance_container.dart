import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesInstanceContainer {
  const SharedPreferencesInstanceContainer({
    this.sharedPreferences,
    this.sharedPreferencesAsync,
  }) : assert(
          sharedPreferences != null || sharedPreferencesAsync != null,
          'SharedPreferences or SharedPreferencesAsync must be provided',
        );

  final SharedPreferences? sharedPreferences;
  final SharedPreferencesAsync? sharedPreferencesAsync;
}
