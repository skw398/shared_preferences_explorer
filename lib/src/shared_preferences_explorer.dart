import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences_explorer/src/anchor.dart';
import 'package:shared_preferences_explorer/src/anchor_alignment.dart';
import 'package:shared_preferences_explorer/src/filter.dart';

export 'anchor_alignment.dart';

class SharedPreferencesExplorer extends StatefulWidget {
  /// Wrap your app's root widget. and tap the anchor button to open.
  ///
  /// The anchor button is draggable, and the initial position can be set using
  /// [initialAnchorAlignment].
  ///
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     SharedPreferencesExplorer(
  ///       // initialAnchorAlignment: AnchorAlignment.bottomLeft,
  ///       child: YourApp(),
  ///     ),
  ///   );
  /// }
  /// ```
  const SharedPreferencesExplorer({
    required this.child,
    super.key,
    this.initialAnchorAlignment = AnchorAlignment.bottomLeft,
  });

  /// The initial position for the draggable anchor button
  final AnchorAlignment initialAnchorAlignment;

  /// The root widget of your application
  final Widget child;

  @override
  State<SharedPreferencesExplorer> createState() =>
      _SharedPreferencesExplorerState();
}

class _SharedPreferencesExplorerState extends State<SharedPreferencesExplorer> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _filter = Filter();

  final colorSchemeSeed = Colors.blue;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      throw Exception(
        'SharedPreferencesExplorer has been detected in release mode',
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        Anchor(
          colorScheme: ThemeData(
            colorSchemeSeed: colorSchemeSeed,
            brightness: MediaQuery.platformBrightnessOf(context),
          ).colorScheme,
          navigatorKey: _navigatorKey,
          filter: _filter,
          initialAnchorAlignment: widget.initialAnchorAlignment,
        ),
        _RouteContainer(navigatorKey: _navigatorKey),
      ],
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
