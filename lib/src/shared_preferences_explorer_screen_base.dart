import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/preference.dart';
import 'package:shared_preferences_explorer/src/preferences.dart';
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
    return Theme(
      data: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: MediaQuery.platformBrightnessOf(context),
      ),
      child: FutureBuilder<Preferences>(
        future: Preferences.init(instanceContainer: instanceContainer),
        builder: (context, snapshot) {
          final preferences = snapshot.data;
          if (preferences == null) {
            return const Scaffold(
              body: Center(child: Text('Loading...')),
            );
          }
          return _SharedPreferencesExplorerScreenBase(preferences: preferences);
        },
      ),
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
        Filter.of(context).state =
            filter.copyWith(searchText: _controller!.text);
      });
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search key or value',
          ),
        ),
        titleSpacing: canPop ? 0 : 16,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: ListTile(
                  leading: Icon(Icons.content_copy),
                  title: Text('Copy as JSON'),
                ),
              ),
              const PopupMenuItem(
                value: 'dump',
                child: ListTile(
                  leading: Icon(Icons.terminal),
                  title: Text('Dump as JSON'),
                ),
              ),
            ],
            onSelected: (value) async {
              final preferences = <String, dynamic>{};
              for (final preference in filteredPreferences) {
                preferences[preference.key] = preference.value;
              }
              final formatted =
                  const JsonEncoder.withIndent('  ').convert(preferences);

              if (value == 'copy') {
                await Clipboard.setData(ClipboardData(text: formatted));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                }
              } else if (value == 'dump') {
                debugPrint(formatted);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dumped to console')),
                  );
                }
              }
            },
          ),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _FilterChips(
                filter: filter,
                onSelected: (valueType, {required isSelected}) {
                  final valueTypes = List<ValueType>.from(filter.valueTypes);
                  isSelected
                      ? valueTypes.add(valueType)
                      : valueTypes.remove(valueType);
                  Filter.of(context).state =
                      filter.copyWith(valueTypes: valueTypes);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('${filteredPreferences.length} results'),
                ],
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
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.onSelected,
  });

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
  const _PreferenceCard({
    required this.preference,
  });

  final Preference preference;

  @override
  Widget build(BuildContext context) {
    const maxLength = 300;
    final isLong = preference.value.toString().length > maxLength;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ValueTypeLabel(type: preference.valueType),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    preference.key,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                isLong
                    // ignore: lines_longer_than_80_chars
                    ? '${preference.value.toString().substring(0, maxLength)}...'
                    : preference.value.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            if (isLong)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (context) {
                          final controller = ScrollController();
                          return AlertDialog(
                            content: Scrollbar(
                              controller: controller,
                              child: SingleChildScrollView(
                                controller: controller,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(preference.value.toString()),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Show all'),
                  ),
                ],
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
