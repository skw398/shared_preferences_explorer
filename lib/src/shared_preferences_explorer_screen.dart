import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_explorer_screen_base.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_instance_container.dart';

class SharedPreferencesExplorerScreen extends _PreferencesExplorerScreenBase {
  /// Use this if you are using [SharedPreferences] in your app.
  ///
  /// You can optionally provide a [SharedPreferences] instance to the
  /// [instance] parameter. If not provided, `SharedPreferences.getInstance()`
  /// will be used.
  ///
  /// ```dart
  /// Navigator.of(context).push(
  ///   MaterialPageRoute<void>(
  ///     builder: (context) => SharedPreferencesExplorerScreen(),
  ///   ),
  /// );
  /// ```
  const SharedPreferencesExplorerScreen({
    super.key,
    this.instance,
  });

  /// Optional [SharedPreferences] instance to use.
  /// If not provided, `SharedPreferences.getInstance()` will be used.
  final SharedPreferences? instance;

  @override
  Future<SharedPreferencesInstanceContainer> getInstanceContainer() async {
    return SharedPreferencesInstanceContainer(
      sharedPreferences: instance ?? (await SharedPreferences.getInstance()),
    );
  }
}

class SharedPreferencesAsyncExplorerScreen
    extends _PreferencesExplorerScreenBase {
  /// Use this if you are using [SharedPreferencesAsync] or
  /// [SharedPreferencesWithCache] in your app.
  /// Note that the cache feature of [SharedPreferencesWithCache] is ignored,
  /// and the latest value is always retrieved.
  ///
  /// You can optionally provide a [SharedPreferencesAsync] instance to the
  /// [instance] parameter. If not provided, `SharedPreferencesAsync()` will be
  /// used.
  ///
  /// ```dart
  /// Navigator.of(context).push(
  ///   MaterialPageRoute<void>(
  ///     builder: (context) => SharedPreferencesAsyncExplorerScreen(),
  ///   ),
  /// );
  /// ```
  const SharedPreferencesAsyncExplorerScreen({
    super.key,
    this.instance,
  });

  /// Optional [SharedPreferencesAsync] instance to use.
  /// If not provided, `SharedPreferencesAsync()` will be used.
  final SharedPreferencesAsync? instance;

  @override
  Future<SharedPreferencesInstanceContainer> getInstanceContainer() async {
    return SharedPreferencesInstanceContainer(
      sharedPreferencesAsync: instance ?? SharedPreferencesAsync(),
    );
  }
}

abstract class _PreferencesExplorerScreenBase extends StatelessWidget {
  const _PreferencesExplorerScreenBase({super.key});

  Future<SharedPreferencesInstanceContainer> getInstanceContainer();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferencesInstanceContainer>(
      future: getInstanceContainer(),
      builder: (context, snapshot) {
        final instanceContainer = snapshot.data;
        if (instanceContainer == null) {
          return const Scaffold(
            body: Center(child: Text('Loading...')),
          );
        }

        return FilterContext(
          child: SharedPreferencesExplorerScreenBaseStarter(
            instanceContainer: instanceContainer,
          ),
        );
      },
    );
  }
}
