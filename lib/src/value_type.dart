import 'dart:core' as core;

enum ValueType(final core.String label) {
  intOrDouble('int, double'),
  bool('bool'),
  string('String'),
  stringList('List<String>');

  factory from(core.Object? value) {
    if (value is core.int || value is core.double) {
      return .intOrDouble;
    } else if (value is core.bool) {
      return .bool;
    } else if (value is core.String) {
      return .string;
    } else if (value is core.List) {
      return .stringList;
    } else {
      throw core.AssertionError('Unexpected type');
    }
  }
}
