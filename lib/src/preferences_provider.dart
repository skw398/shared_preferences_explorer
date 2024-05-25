import 'package:flutter/material.dart';

import 'preferences_notifier.dart';

class PreferencesProvider extends InheritedNotifier<PreferencesNotifier> {
  const PreferencesProvider({
    super.key,
    required PreferencesNotifier super.notifier,
    required super.child,
  });

  static PreferencesNotifier of(BuildContext context) {
    final notifier = context
        .dependOnInheritedWidgetOfExactType<PreferencesProvider>()!
        .notifier;
    assert(notifier != null, 'Unexpected');
    return notifier!;
  }
}
