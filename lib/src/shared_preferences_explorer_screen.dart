import 'package:flutter/material.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_explorer_screen_base.dart';

class SharedPreferencesExplorerScreen extends StatelessWidget {
  /// Use in your app's debug menu, etc.
  ///
  /// ```dart
  /// Navigator.of(context).push(
  ///   MaterialPageRoute<void>(
  ///     builder: (context) => const SharedPreferencesExplorerScreen(),
  ///   ),
  /// );
  /// ```
  const SharedPreferencesExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const FilterContext(child: SharedPreferencesExplorerScreenBaseStarter());
}
