import 'package:flutter/material.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';
import 'package:shared_preferences_explorer/src/filter.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_explorer_screen_base.dart';

class Anchor extends StatefulWidget {
  const Anchor({
    required this.colorScheme,
    required this.navigatorKey,
    required this.filter,
    required this.initialAnchorAlignment,
    super.key,
  });

  final ColorScheme colorScheme;
  final GlobalKey<NavigatorState> navigatorKey;
  final Filter filter;
  final AnchorAlignment initialAnchorAlignment;

  @override
  State<Anchor> createState() => _AnchorState();

  static const size = 56.0;
}

class _AnchorState extends State<Anchor> {
  bool _isNavigating = false;

  bool _isDragging = false;
  Offset _dragPosition = Offset.zero;
  late AnchorAlignment _currentAlignment;

  @override
  void initState() {
    super.initState();
    _currentAlignment = widget.initialAnchorAlignment;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          AnimatedPositioned(
            width: Anchor.size,
            height: Anchor.size,
            left: _isDragging
                ? _dragPosition.dx
                : _currentAlignment.position(context).dx,
            top: _isDragging
                ? _dragPosition.dy
                : _currentAlignment.position(context).dy,
            duration:
                _isDragging ? Duration.zero : const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                  _dragPosition = _currentAlignment.position(context);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _dragPosition = Offset(
                    _dragPosition.dx + details.delta.dx,
                    _dragPosition.dy + details.delta.dy,
                  );
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                  _currentAlignment = _findNearest(context, _dragPosition);
                });
              },
              child: FloatingActionButton(
                foregroundColor: widget.colorScheme.onPrimaryContainer,
                backgroundColor: widget.colorScheme.primaryContainer,
                splashColor:
                    widget.colorScheme.onPrimaryContainer.withOpacity(0.12),
                focusColor:
                    widget.colorScheme.onPrimaryContainer.withOpacity(0.12),
                hoverColor:
                    widget.colorScheme.onPrimaryContainer.withOpacity(0.08),
                onPressed: _isNavigating
                    ? null
                    : () async {
                        setState(() => _isNavigating = true);
                        final context = widget.navigatorKey.currentContext;
                        assert(context != null, 'Unexpected');
                        await Navigator.of(context!).push(
                          MaterialPageRoute<void>(
                            builder: (context) {
                              return SharedPreferencesExplorerScreenBaseStarter(
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
          ),
        ],
      ),
    );
  }

  AnchorAlignment _findNearest(BuildContext context, Offset current) {
    var minDistance = double.infinity;
    late AnchorAlignment nearest;
    for (final alignment in AnchorAlignment.values) {
      final distance = (alignment.position(context) - current).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = alignment;
      }
    }
    return nearest;
  }
}

extension on AnchorAlignment {
  Offset position(BuildContext context) {
    const basePadding = 16.0;

    final mediaQuerySize = MediaQuery.of(context).size;
    final mediaQueryPadding = MediaQuery.of(context).padding;

    final paddingTop = mediaQueryPadding.top + basePadding;
    final paddingLeft = mediaQueryPadding.left + basePadding;
    final areaSize = Size(
      mediaQuerySize.width - (mediaQueryPadding.horizontal + basePadding * 2),
      mediaQuerySize.height - (mediaQueryPadding.vertical + basePadding * 2),
    );

    return switch (this) {
      AnchorAlignment.topLeft => Offset(
          paddingLeft,
          paddingTop,
        ),
      AnchorAlignment.topCenter => Offset(
          paddingLeft + (areaSize.width - Anchor.size) / 2,
          paddingTop,
        ),
      AnchorAlignment.topRight => Offset(
          paddingLeft + areaSize.width - Anchor.size,
          paddingTop,
        ),
      AnchorAlignment.centerLeft => Offset(
          paddingLeft,
          paddingTop + (areaSize.height - Anchor.size) / 2,
        ),
      AnchorAlignment.centerRight => Offset(
          paddingLeft + areaSize.width - Anchor.size,
          paddingTop + (areaSize.height - Anchor.size) / 2,
        ),
      AnchorAlignment.bottomLeft => Offset(
          paddingLeft,
          paddingTop + areaSize.height - Anchor.size,
        ),
      AnchorAlignment.bottomCenter => Offset(
          paddingLeft + (areaSize.width - Anchor.size) / 2,
          paddingTop + areaSize.height - Anchor.size,
        ),
      AnchorAlignment.bottomRight => Offset(
          paddingLeft + areaSize.width - Anchor.size,
          paddingTop + areaSize.height - Anchor.size,
        )
    };
  }
}
