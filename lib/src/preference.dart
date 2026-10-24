import 'package:shared_preferences_explorer/src/value_type.dart';

class Preference {
  new fromKey(this.key, this.value) {
    valueType = .from(value);
  }

  final String key;
  final Object value;
  late final ValueType valueType;
}
