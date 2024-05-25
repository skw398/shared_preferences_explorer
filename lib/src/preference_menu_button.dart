import 'package:flutter/material.dart';

import 'floating_snack_bar.dart';
import 'menu_tile.dart';
import 'preference.dart';
import 'preferences_notifier.dart';
import 'preferences_provider.dart';
import 'value_type.dart';
import 'value_type_label.dart';

class PreferenceMenuButton extends StatelessWidget {
  const PreferenceMenuButton({
    super.key,
    required this.preference,
  });

  final Preference preference;

  @override
  Widget build(BuildContext context) {
    final preferencesNotifier = PreferencesProvider.of(context);

    return PopupMenuButton(
      padding: const EdgeInsets.all(4),
      onOpened: () {
        primaryFocus?.unfocus();
      },
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await showDialog<void>(
              context: context,
              builder: (context) {
                return _EditDialog(
                  preference: preference,
                  preferencesNotifier: preferencesNotifier,
                );
              },
            );
          case 'remove':
            await showDialog<void>(
              context: context,
              builder: (context) {
                return _RemoveDialog(
                  preference: preference,
                  preferencesNotifier: preferencesNotifier,
                );
              },
            );
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            value: 'edit',
            child: MenuTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'remove',
            child: MenuTile(
              leading: Icon(Icons.delete),
              title: Text('Remove'),
            ),
          ),
        ];
      },
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({
    required this.preference,
    required this.preferencesNotifier,
  });

  final Preference preference;
  final PreferencesNotifier preferencesNotifier;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final ValueNotifier<Object?> value;

  @override
  void initState() {
    super.initState();
    value = ValueNotifier<Object?>(widget.preference.value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          ValueTypeLabel(type: widget.preference.valueType),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.preference.key,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
      content: switch (widget.preference.valueType) {
        ValueType.bool => _BoolEditForm(
            preference: widget.preference,
            value: value,
          ),
        _ => _TextEditForm(
            preference: widget.preference,
            value: value,
          )
      },
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder(
          valueListenable: value,
          builder: (context, value, child) {
            return TextButton(
              onPressed: value == null
                  ? null
                  : () async {
                      final succeeded = await widget.preferencesNotifier.update(
                        widget.preference,
                        value,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (succeeded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            floatingSnackBar(message: 'Successfully saved.'),
                          );
                        }
                      }
                    },
              child: const Text('Save'),
            );
          },
        ),
      ],
    );
  }
}

class _TextEditForm extends StatefulWidget {
  const _TextEditForm({
    required this.preference,
    required this.value,
  });

  final Preference preference;
  final ValueNotifier<Object?> value;

  @override
  State<_TextEditForm> createState() => _TextEditFormState();
}

class _TextEditFormState extends State<_TextEditForm> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller
      ..text = switch (widget.preference.valueType) {
        ValueType.stringList => (() {
            // Always non-null at initialization
            assert(widget.value.value != null, 'Unexpected');
            final stringList = widget.value.value! as List<String>;
            return stringList.join('\n');
          })(),
        _ => widget.value.value.toString(),
      }
      ..addListener(() {
        widget.value.value =
            widget.preference.valueType.validate(_controller.text);
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.value,
      builder: (context, value, child) {
        return TextField(
          controller: _controller,
          keyboardType: widget.preference.valueType.keyboardType,
          autofocus: true,
          maxLines: null,
          decoration: InputDecoration(
            errorText:
                value != null ? null : widget.preference.valueType.errorText,
            helperText: widget.preference.valueType.helperText,
          ),
        );
      },
    );
  }
}

class _BoolEditForm extends StatefulWidget {
  const _BoolEditForm({
    required this.preference,
    required this.value,
  });

  final Preference preference;
  final ValueNotifier<Object?> value;

  @override
  State<_BoolEditForm> createState() => _BoolEditFormState();
}

class _BoolEditFormState extends State<_BoolEditForm> {
  @override
  void dispose() {
    super.dispose();
    widget.value.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.value,
      builder: (context, value, child) {
        return SegmentedButton(
          segments: const [
            ButtonSegment(
              value: true,
              label: Text('True'),
            ),
            ButtonSegment(
              value: false,
              label: Text('False'),
            ),
          ],
          selected: {value},
          onSelectionChanged: (newSelection) {
            widget.value.value = newSelection.first;
          },
        );
      },
    );
  }
}

extension _ValueTypeExtensions on ValueType {
  Object? validate(String text) {
    return switch (this) {
      ValueType.intOrDouble => int.tryParse(text) ?? double.tryParse(text),
      ValueType.bool => throw AssertionError(),
      ValueType.string => text,
      ValueType.stringList => text.split('\n'),
    };
  }

  TextInputType? get keyboardType => switch (this) {
        ValueType.intOrDouble =>
          const TextInputType.numberWithOptions(decimal: true),
        ValueType.bool => throw AssertionError(),
        ValueType.string => TextInputType.multiline,
        ValueType.stringList => TextInputType.multiline,
      };

  String? get errorText {
    return switch (this) {
      ValueType.intOrDouble => 'Invalid input',
      _ => null,
    };
  }

  String? get helperText {
    return switch (this) {
      ValueType.stringList => 'Enter with line breaks',
      _ => null,
    };
  }
}

class _RemoveDialog extends StatelessWidget {
  const _RemoveDialog({
    required this.preference,
    required this.preferencesNotifier,
  });

  final Preference preference;
  final PreferencesNotifier preferencesNotifier;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
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
      content: const Text('Are you sure you want to remove this key?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final succeeded = await preferencesNotifier.remove(preference.key);
            if (context.mounted) {
              Navigator.pop(context);
              if (succeeded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  floatingSnackBar(message: 'Successfully removed.'),
                );
              }
            }
          },
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
