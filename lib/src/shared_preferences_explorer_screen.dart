import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_explorer_screen_base.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_instance_container.dart';

class const SharedPreferencesExplorerScreen({
  super.key,

  /// Optional [SharedPreferences] instance to use.
  /// If not provided, `SharedPreferences.getInstance()` will be used.
  final SharedPreferences? instance,
}) extends _PreferencesExplorerScreenBase {
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
  @override
  Future<SharedPreferencesInstanceContainer> getInstanceContainer() async {
    return SharedPreferencesInstanceContainer(
      sharedPreferences: instance ?? (await SharedPreferences.getInstance()),
    );
  }
}

class const SharedPreferencesAsyncExplorerScreen({
  super.key,

  /// Optional [SharedPreferencesAsync] instance to use.
  /// If not provided, `SharedPreferencesAsync()` will be used.
  final SharedPreferencesAsync? instance,
}) extends _PreferencesExplorerScreenBase {
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
  @override
  Future<SharedPreferencesInstanceContainer> getInstanceContainer() async {
    return SharedPreferencesInstanceContainer(
      sharedPreferencesAsync: instance ?? SharedPreferencesAsync(),
    );
  }
}

abstract class _PreferencesExplorerScreenBase extends StatelessWidget {
  const new({super.key});

  Future<SharedPreferencesInstanceContainer> getInstanceContainer();

  @override
  Widget build(BuildContext context) {
    if (Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) ==
        null) {
      throw FlutterError(
        'shared_preferences_explorer: the screen widgets require an app that '
        'uses package:material_ui.\n'
        'The screen widgets are built with material_ui, which needs '
        'MaterialLocalizations from material_ui, but the host app provides the '
        "SDK's MaterialLocalizations instead.\n"
        'Use SharedPreferencesExplorer or SharedPreferencesAsyncExplorer (the '
        'floating button widgets), which work in any app, or stay on '
        'shared_preferences_explorer 0.4.0.\n'
        'To migrate the app, run: '
        'dart fix --apply --code=migrate_design_widgets',
      );
    }

    return FutureBuilder<SharedPreferencesInstanceContainer>(
      future: getInstanceContainer(),
      builder: (context, snapshot) {
        final instanceContainer = snapshot.data;
        if (instanceContainer == null) {
          return const Scaffold(body: Center(child: Text('Loading...')));
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
