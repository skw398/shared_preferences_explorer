import 'package:flutter/material.dart';

import 'floating_snack_bar.dart';
import 'menu_tile.dart';
import 'preferences_notifier.dart';
import 'preferences_provider.dart';

class GeneralMenuButton extends StatelessWidget {
  const GeneralMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesNotifier = PreferencesProvider.of(context);

    return PopupMenuButton(
      onOpened: () {
        primaryFocus?.unfocus();
      },
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'clear':
            await showDialog<void>(
              context: context,
              builder: (context) {
                return _ClearDialog(preferencesNotifier: preferencesNotifier);
              },
            );
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            value: 'clear',
            child: MenuTile(
              leading: Icon(Icons.delete),
              title: Text('Clear'),
            ),
          ),
        ];
      },
    );
  }
}

class _ClearDialog extends StatelessWidget {
  const _ClearDialog({
    required this.preferencesNotifier,
  });

  final PreferencesNotifier preferencesNotifier;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text('Are you sure you want to remove all keys?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final succeeded = await preferencesNotifier.clear();
            if (context.mounted) {
              Navigator.pop(context);
              if (succeeded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  floatingSnackBar(message: 'Successfully cleared.'),
                );
              }
            }
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
