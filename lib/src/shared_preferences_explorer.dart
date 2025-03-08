import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/src/anchor.dart';
import 'package:shared_preferences_explorer/src/anchor_alignment.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_instance_container.dart';

export 'anchor_alignment.dart';

class SharedPreferencesExplorer extends _SharedPreferencesExplorerBase {
  /// Use this if you are using [SharedPreferences] in your app.
  ///
  /// Wrap your app's root widget. and tap the anchor button to open.
  ///
  /// You can optionally provide a [SharedPreferences] instance to the
  /// [instance] parameter. If not provided, `SharedPreferences.getInstance()`
  /// will be used.
  ///
  /// The anchor button is draggable, and the initial position can be set using
  /// [initialAnchorAlignment].
  ///
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     SharedPreferencesExplorer(
  ///       child: YourApp(),
  ///     ),
  ///   );
  /// }
  /// ```
  const SharedPreferencesExplorer({
    super.key,
    this.instance,
    this.initialAnchorAlignment = AnchorAlignment.bottomLeft,
    required this.child,
  });

  /// Optional [SharedPreferences] instance to use.
  /// If not provided, `SharedPreferences.getInstance()` will be used.
  final SharedPreferences? instance;

  /// The initial position for the draggable anchor button
  final AnchorAlignment? initialAnchorAlignment;

  /// The root widget of your application
  final Widget child;

  @override
  AnchorAlignment get _initialAnchorAlignment => initialAnchorAlignment!;

  @override
  Widget get _child => child;

  @override
  State<SharedPreferencesExplorer> createState() =>
      _SharedPreferencesExplorerState();
}

class _SharedPreferencesExplorerState
    extends _SharedPreferencesExplorerBaseState<SharedPreferencesExplorer> {
  @override
  Future<SharedPreferencesInstanceContainer> getInstanceContainer() async {
    return SharedPreferencesInstanceContainer(
      sharedPreferences:
          widget.instance ?? (await SharedPreferences.getInstance()),
    );
  }
}

class SharedPreferencesAsyncExplorer extends _SharedPreferencesExplorerBase {
  /// Use this if you are using [SharedPreferencesAsync] or
  /// [SharedPreferencesWithCache].
  /// Note that the cache feature of [SharedPreferencesWithCache] is ignored,
  /// and the latest value is always retrieved.
  ///
  /// Wrap your app's root widget. and tap the anchor button to open.
  ///
  /// You can optionally provide a [SharedPreferencesAsync] instance to the
  /// [instance] parameter. If not provided, `SharedPreferencesAsync()` will be
  /// used.
  ///
  /// The anchor button is draggable, and the initial position can be set using
  /// [initialAnchorAlignment].
  ///
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     SharedPreferencesAsyncExplorer(
  ///       child: YourApp(),
  ///     ),
  ///   );
  /// }
  /// ```
  const SharedPreferencesAsyncExplorer({
    super.key,
    this.instance,
    this.initialAnchorAlignment = AnchorAlignment.bottomLeft,
    required this.child,
  });

  /// Optional [SharedPreferencesAsync] instance to use.
  /// If not provided, `SharedPreferencesAsync()` will be used.
  final SharedPreferencesAsync? instance;

  /// The initial position for the draggable anchor button
  final AnchorAlignment? initialAnchorAlignment;

  /// The root widget of your application
  final Widget child;

  @override
  AnchorAlignment get _initialAnchorAlignment => initialAnchorAlignment!;

  @override
  Widget get _child => child;

  @override
  State<SharedPreferencesAsyncExplorer> createState() =>
      _SharedPreferencesAsyncExplorerState();
}

class _SharedPreferencesAsyncExplorerState
    extends _SharedPreferencesExplorerBaseState<
        SharedPreferencesAsyncExplorer> {
  @override
  Future<SharedPreferencesInstanceContainer> getInstanceContainer() async {
    return SharedPreferencesInstanceContainer(
      sharedPreferencesAsync: widget.instance ?? SharedPreferencesAsync(),
    );
  }
}

abstract class _SharedPreferencesExplorerBase extends StatefulWidget {
  const _SharedPreferencesExplorerBase({super.key});

  AnchorAlignment get _initialAnchorAlignment;

  Widget get _child;
}

abstract class _SharedPreferencesExplorerBaseState<
    T extends _SharedPreferencesExplorerBase> extends State<T> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final colorSchemeSeed = Colors.blue;

  Future<SharedPreferencesInstanceContainer> getInstanceContainer();

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      throw Exception(
        'shared_preferences_explorer has been detected in release mode',
      );
    }

    return FilterContext(
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget._child,
          FutureBuilder<SharedPreferencesInstanceContainer>(
            future: getInstanceContainer(),
            builder: (context, snapshot) {
              final instanceContainer = snapshot.data;
              if (instanceContainer == null) {
                return const SizedBox.shrink();
              }

              return Anchor(
                instanceContainer: instanceContainer,
                colorScheme: ThemeData(
                  colorSchemeSeed: colorSchemeSeed,
                  brightness: MediaQuery.platformBrightnessOf(context),
                ).colorScheme,
                navigatorKey: _navigatorKey,
                initialAnchorAlignment: widget._initialAnchorAlignment,
              );
            },
          ),
          _RouteContainer(navigatorKey: _navigatorKey),
        ],
      ),
    );
  }
}

class _RouteContainer extends StatefulWidget {
  const _RouteContainer({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_RouteContainer> createState() => _RouteContainerState();
}

class _RouteContainerState extends State<_RouteContainer> {
  late _NavigatorObserver _navigatorObserver;
  bool _isPageOpen = false;

  @override
  void initState() {
    super.initState();
    _navigatorObserver = _NavigatorObserver(
      navigatorKey: widget.navigatorKey,
      onStateChange: ({required isPageOpen}) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _isPageOpen = isPageOpen);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_isPageOpen,
      child: MaterialApp(
        navigatorObservers: [_navigatorObserver],
        navigatorKey: widget.navigatorKey,
        debugShowCheckedModeBanner: false,
        home: Container(),
      ),
    );
  }
}

class _NavigatorObserver extends RouteObserver {
  _NavigatorObserver({
    required this.onStateChange,
    required this.navigatorKey,
  });

  final void Function({required bool isPageOpen}) onStateChange;
  final GlobalKey<NavigatorState> navigatorKey;

  bool _isPageOpen = false;

  @override
  void didPush(Route<void> route, Route<void>? previousRoute) =>
      _handleNavigation();

  @override
  void didPop(Route<void> route, Route<void>? previousRoute) =>
      _handleNavigation();

  void _handleNavigation() {
    final state = navigatorKey.currentState;
    assert(state != null, 'Unexpected');
    final current = state!.canPop();
    final previous = _isPageOpen;

    if (previous != current) {
      _isPageOpen = current;
      onStateChange(isPageOpen: _isPageOpen);
    }
  }
}
