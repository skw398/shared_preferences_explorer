import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'filter.dart';
import 'shared_preferences_explorer_screen.dart';

class SharedPreferencesExplorer extends StatefulWidget {
  /// Wrap your root widget with [SharedPreferencesExplorer].
  ///
  /// Then tap the button, set by default to the [Alignment.bottomLeft], to
  /// open.
  ///
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     SharedPreferencesExplorer(
  ///       // anchorAlignment: Alignment.bottomLeft,
  ///       // colorSchemeSeed: Colors.lightGreen,
  ///       child: YourApp(),
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// Or, directly displays if [child] is null.
  ///
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     const SharedPreferencesExplorer(),
  ///     // YourApp(),
  ///   );
  /// }
  /// ```
  const SharedPreferencesExplorer({
    super.key,
    this.anchorAlignment = Alignment.bottomLeft,
    this.colorSchemeSeed = Colors.lightGreen,
    this.child,
  });

  /// The position for the anchor button
  final Alignment anchorAlignment;

  /// The seed color
  final Color colorSchemeSeed;

  /// The root widget of your application
  final Widget? child;

  @override
  State<SharedPreferencesExplorer> createState() =>
      _SharedPreferencesExplorerState();
}

class _SharedPreferencesExplorerState extends State<SharedPreferencesExplorer> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _filter = Filter();

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      throw Exception(
        'SharedPreferencesExplorer has been detected in release mode',
      );
    }

    final themeData = _themeData(context, widget.colorSchemeSeed);

    if (widget.child == null) {
      return MaterialApp(
        theme: themeData,
        debugShowCheckedModeBanner: false,
        home: SharedPreferencesExplorerScreenStarter(filter: _filter),
      );
    }

    return Stack(
      alignment: widget.anchorAlignment,
      children: [
        widget.child!,
        _Anchor(
          colorScheme: themeData.colorScheme,
          navigatorKey: _navigatorKey,
          filter: _filter,
        ),
        _RouteContainer(
          themeData: themeData,
          navigatorKey: _navigatorKey,
        ),
      ],
    );
  }

  ThemeData _themeData(BuildContext context, Color colorSchemeSeed) {
    return ThemeData(
      colorSchemeSeed: colorSchemeSeed,
      brightness: MediaQuery.platformBrightnessOf(context),
    );
  }
}

class _Anchor extends StatefulWidget {
  const _Anchor({
    required this.colorScheme,
    required this.navigatorKey,
    required this.filter,
  });

  final ColorScheme colorScheme;
  final GlobalKey<NavigatorState> navigatorKey;
  final Filter filter;

  @override
  State<_Anchor> createState() => _AnchorState();
}

class _AnchorState extends State<_Anchor> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final basePadding = MediaQuery.paddingOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        basePadding.left + 16,
        basePadding.top + 16,
        basePadding.right + 16,
        basePadding.bottom + 16,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: FloatingActionButton(
          foregroundColor: widget.colorScheme.onPrimaryContainer,
          backgroundColor: widget.colorScheme.primaryContainer,
          splashColor: widget.colorScheme.onPrimaryContainer.withOpacity(0.12),
          focusColor: widget.colorScheme.onPrimaryContainer.withOpacity(0.12),
          hoverColor: widget.colorScheme.onPrimaryContainer.withOpacity(0.08),
          onPressed: _isNavigating
              ? null
              : () async {
                  setState(() => _isNavigating = true);
                  final context = widget.navigatorKey.currentContext;
                  assert(context != null, 'Unexpected');
                  await Navigator.of(context!).push(
                    MaterialPageRoute<void>(
                      builder: (context) {
                        return SharedPreferencesExplorerScreenStarter(
                          filter: widget.filter,
                        );
                      },
                      fullscreenDialog: true,
                    ),
                  );
                  setState(() => _isNavigating = false);
                },
          child: const Icon(Icons.source),
        ),
      ),
    );
  }
}

class _RouteContainer extends StatefulWidget {
  const _RouteContainer({
    required this.themeData,
    required this.navigatorKey,
  });

  final ThemeData themeData;
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
        theme: widget.themeData,
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
  GlobalKey<NavigatorState> navigatorKey;

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
