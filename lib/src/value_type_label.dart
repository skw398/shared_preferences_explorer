import 'package:flutter/material.dart';
import 'package:shared_preferences_explorer/src/value_type.dart';

class ValueTypeLabel extends StatelessWidget {
  const ValueTypeLabel({
    required this.type,
    super.key,
  });

  final ValueType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
