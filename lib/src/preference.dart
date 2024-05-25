import 'value_type.dart';

class Preference {
  Preference(
    this.key,
    this.value,
  ) {
    valueType = ValueType.from(value);
  }

  final String key;
  final Object value;
  late final ValueType valueType;
}
