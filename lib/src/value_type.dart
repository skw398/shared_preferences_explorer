import 'dart:core' as core;

enum ValueType {
  intOrDouble('int, double'),
  bool('bool'),
  string('String'),
  stringList('List<String>'),
  ;

  const ValueType(this.label);

  factory ValueType.from(core.Object? value) {
    if (value is core.int || value is core.double) {
      return ValueType.intOrDouble;
    } else if (value is core.bool) {
      return ValueType.bool;
    } else if (value is core.String) {
      return ValueType.string;
    } else if (value is core.List) {
      return ValueType.stringList;
    } else {
      throw core.AssertionError('Unexpected type');
    }
  }

  final core.String label;
}
