import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_explorer/src/preference.dart';

class ExportMenuButton extends StatelessWidget {
  const ExportMenuButton({super.key, required this.preferences});

  final List<Preference> preferences;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Action>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        for (final action in _Action.values)
          PopupMenuItem(
            value: action,
            child:
                ListTile(leading: Icon(action.icon), title: Text(action.label)),
          ),
      ],
      onSelected: (action) async {
        final data = <String, dynamic>{
          for (final pref in preferences) pref.key: pref.value,
        };
        action.execute(data);

        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(action.message)));
        }
      },
    );
  }
}

enum _Action {
  copy(Icons.content_copy, 'Copy as JSON', 'Copied to clipboard'),
  dump(Icons.terminal, 'Dump as JSON', 'Dumped to console');

  const _Action(this.icon, this.label, this.message);

  final IconData icon;
  final String label;
  final String message;

  void execute(Map<String, dynamic> data) {
    final formatted = const JsonEncoder.withIndent('  ').convert(data);

    switch (this) {
      case _Action.copy:
        Clipboard.setData(ClipboardData(text: formatted));
      case _Action.dump:
        debugPrint(formatted);
    }
  }
}
