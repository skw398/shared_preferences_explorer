import 'package:flutter/material.dart';

import 'filter.dart';
import 'general_menu_button.dart';
import 'preference.dart';
import 'preference_menu_button.dart';
import 'preferences_notifier.dart';
import 'preferences_provider.dart';
import 'value_type.dart';
import 'value_type_label.dart';

class SharedPreferencesExplorerScreenStarter extends StatelessWidget {
  const SharedPreferencesExplorerScreenStarter({
    super.key,
    required this.filter,
  });

  final Filter filter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreferencesNotifier>(
      // False positive
      // ignore: discarded_futures
      future: PreferencesNotifier.init(),
      builder: (context, snapshot) {
        final preferencesNotifier = snapshot.data;
        if (preferencesNotifier == null) {
          return const Scaffold(
            body: Center(
              child: Text('Loading...'),
            ),
          );
        }
        return PreferencesProvider(
          notifier: preferencesNotifier,
          child: _SharedPreferencesExplorerScreen(filter: filter),
        );
      },
    );
  }
}

class _SharedPreferencesExplorerScreen extends StatefulWidget {
  const _SharedPreferencesExplorerScreen({
    required this.filter,
  });

  final Filter filter;

  @override
  State<_SharedPreferencesExplorerScreen> createState() =>
      _SharedPreferencesExplorerScreenState();
}

class _SharedPreferencesExplorerScreenState
    extends State<_SharedPreferencesExplorerScreen> {
  late final Filter _filter;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.filter;
    _controller
      ..text = _filter.text
      ..addListener(() {
        setState(() => _filter.text = _controller.text);
      });
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final filteredPreferences =
        PreferencesProvider.of(context).filtered(_filter);

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
            hintText: 'Search key',
          ),
        ),
        titleSpacing: canPop ? 0 : 16,
        leading: canPop
            ? IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: 'Close',
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: [
          IconButton(
            onPressed: () {
              _controller.text = '';
            },
            tooltip: 'Clear text',
            icon: const Icon(Icons.close),
          ),
          const GeneralMenuButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _FilterChips(
                filter: _filter,
                onSelected: (valueType, {required isSelected}) {
                  setState(() {
                    if (isSelected) {
                      _filter.valueTypes.add(valueType);
                    } else {
                      _filter.valueTypes.remove(valueType);
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text('${filteredPreferences.length} Results'),
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
    return Wrap(
      spacing: 8,
      children: ValueType.values.map((valueType) {
        return FilterChip.elevated(
          materialTapTargetSize: MaterialTapTargetSize.padded,
          label: Text(valueType.label),
          selected: filter.valueTypes.contains(valueType),
          onSelected: (isSelected) {
            onSelected(valueType, isSelected: isSelected);
          },
        );
      }).toList(),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 12),
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
                PreferenceMenuButton(preference: preference),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 16),
              child: Text(
                preference.value.toString(),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
