import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_explorer/src/value_type.dart';

class const ValueTypeLabel({required final ValueType type, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const .symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: .circular(8),
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
