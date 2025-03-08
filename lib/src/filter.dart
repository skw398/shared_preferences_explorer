import 'package:flutter/widgets.dart';
import 'package:shared_preferences_explorer/src/value_type.dart';

class Filter {
  const Filter({
    this.valueTypes = const [],
    this.searchText = '',
  });

  final List<ValueType> valueTypes;
  final String searchText;

  Filter copyWith({
    List<ValueType>? valueTypes,
    String? searchText,
  }) {
    return Filter(
      valueTypes: valueTypes ?? this.valueTypes,
      searchText: searchText ?? this.searchText,
    );
  }

  static FilterNotifier of(BuildContext context) {
    final inheritedWidget =
        context.dependOnInheritedWidgetOfExactType<_FilterProviderInherited>();
    if (inheritedWidget == null) {
      throw FlutterError('FilterProvider not found in context');
    }
    return inheritedWidget.notifier!;
  }
}

class FilterContext extends StatefulWidget {
  const FilterContext({
    required this.child,
    super.key,
    this.filter = const Filter(),
  });

  final Widget child;
  final Filter filter;

  @override
  FilterContextState createState() => FilterContextState();
}

class FilterContextState extends State<FilterContext> {
  late FilterNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = FilterNotifier();
    _notifier.state = widget.filter;
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FilterProviderInherited(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class FilterNotifier extends ChangeNotifier {
  Filter _filter = const Filter();

  Filter get state => _filter;

  set state(Filter value) {
    _filter = value;
    notifyListeners();
  }
}

class _FilterProviderInherited extends InheritedNotifier<FilterNotifier> {
  const _FilterProviderInherited({
    required FilterNotifier super.notifier,
    required super.child,
  });
}
