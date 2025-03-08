import 'package:shared_preferences_explorer/src/value_type.dart';

class Preference {
  Preference.fromKey(this.key, this.value) {
    valueType = ValueType.from(value);
  }

  final String key;
  final Object value;
  late final ValueType valueType;
}
