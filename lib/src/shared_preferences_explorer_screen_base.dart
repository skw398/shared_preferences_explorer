import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_explorer/src/export_menu_button.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/preference.dart';
import 'package:shared_preferences_explorer/src/preferences.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_explorer_theme.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_instance_container.dart';
import 'package:shared_preferences_explorer/src/value_type.dart';
import 'package:shared_preferences_explorer/src/value_type_label.dart';

class SharedPreferencesExplorerScreenBaseStarter extends StatelessWidget {
  const SharedPreferencesExplorerScreenBaseStarter({
    required this.instanceContainer,
    super.key,
  });

  final SharedPreferencesInstanceContainer instanceContainer;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Preferences>(
      future: Preferences.init(instanceContainer: instanceContainer),
      builder: (context, snapshot) {
        final preferences = snapshot.data;
        if (preferences == null) {
          return const Scaffold(body: Center(child: Text('Loading...')));
        }
        return _SharedPreferencesExplorerScreenBase(preferences: preferences);
      },
    );
  }
}

class _SharedPreferencesExplorerScreenBase extends StatefulWidget {
  const _SharedPreferencesExplorerScreenBase({required this.preferences});

  final Preferences preferences;

  @override
  State<_SharedPreferencesExplorerScreenBase> createState() =>
      _SharedPreferencesExplorerScreenBaseState();
}

class _SharedPreferencesExplorerScreenBaseState
    extends State<_SharedPreferencesExplorerScreenBase> {
  TextEditingController? _controller;
  bool _initialized = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final filter = Filter.of(context).state;
    final filteredPreferences = widget.preferences.filtered(filter);

    if (!_initialized) {
      _controller = TextEditingController(text: filter.searchText);
      _controller!.addListener(() {
        final filter = Filter.of(context).state;
        Filter.of(context).state = filter.copyWith(
          searchText: _controller!.text,
        );
      });
      _initialized = true;
    }

    return SharedPreferencesExplorerTheme(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search key or value',
            ),
          ),
          titleSpacing: canPop ? 0 : 16,
          actions: [
            ExportMenuButton(preferences: filteredPreferences),
            const SizedBox(width: 8),
          ],
          leading: canPop
              ? IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const SizedBox(height: 8),
              _FilterChips(
                filter: filter,
                onSelected: (valueType, {required isSelected}) {
                  final valueTypes = List<ValueType>.from(filter.valueTypes);
                  isSelected
                      ? valueTypes.add(valueType)
                      : valueTypes.remove(valueType);
                  Filter.of(context).state = filter.copyWith(
                    valueTypes: valueTypes,
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [Text('${filteredPreferences.length} results')],
                ),
              ),
              ...filteredPreferences.map((preference) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 12,
                  ),
                  child: _PreferenceCard(preference: preference),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.onSelected});

  final Filter filter;
  final void Function(ValueType valueType, {required bool isSelected})
  onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: ValueType.values.asMap().entries.map((entry) {
            final index = entry.key;
            final valueType = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                right: index == ValueType.values.length - 1 ? 0 : 8,
              ),
              child: FilterChip.elevated(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                label: Text(valueType.label),
                selected: filter.valueTypes.contains(valueType),
                onSelected: (isSelected) {
                  onSelected(valueType, isSelected: isSelected);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({required this.preference});

  final Preference preference;

  @override
  Widget build(BuildContext context) {
    const maxLength = 300;
    final isLong = preference.value.toString().length > maxLength;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                ValueTypeLabel(type: preference.valueType),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    preference.key,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ExportMenuButton(preferences: [preference]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(
              isLong
                  ? '${preference.value.toString().substring(0, maxLength)}...'
                  : preference.value.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (preference.value is List<String>)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              _StringListViewScreen(preference: preference),
                        ),
                      );
                    },
                    child: const Text('Show as list'),
                  )
                else if (isLong)
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              _StringViewScreen(preference: preference),
                        ),
                      );
                    },
                    child: const Text('Show all'),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StringListViewScreen extends StatefulWidget {
  const _StringListViewScreen({required this.preference});

  final Preference preference;

  @override
  State<_StringListViewScreen> createState() => _StringListViewScreenState();
}

class _StringListViewScreenState extends State<_StringListViewScreen> {
  late List<String> _items;
  bool _isReversed = false;

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(widget.preference.value as List<String>);
  }

  @override
  Widget build(BuildContext context) {
    return SharedPreferencesExplorerTheme(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.preference.key),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isReversed = !_isReversed;
                  _items = _items.reversed.toList();
                });
              },
              icon: const Icon(Icons.swap_vert),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final originalIndex = _isReversed
                ? _items.length - 1 - index
                : index;
            return ListTile(
              title: SelectableText(originalIndex.toString()),
              subtitle: SelectableText(_items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _StringViewScreen extends StatelessWidget {
  const _StringViewScreen({required this.preference});

  final Preference preference;

  @override
  Widget build(BuildContext context) {
    return SharedPreferencesExplorerTheme(
      child: Scaffold(
        appBar: AppBar(title: Text(preference.key)),
        body: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(preference.value.toString()),
          ),
        ),
      ),
    );
  }
}
