import 'package:flutter/material.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_explorer_screen_base.dart';
import 'package:shared_preferences_explorer/src/shared_preferences_instance_container.dart';

class FloatingButton extends StatefulWidget {
  const FloatingButton({
    required this.instanceContainer,
    required this.colorScheme,
    required this.navigatorKey,
    required this.initialAlignment,
    super.key,
  });

  final SharedPreferencesInstanceContainer instanceContainer;
  final ColorScheme colorScheme;
  final GlobalKey<NavigatorState> navigatorKey;
  final FloatingButtonAlignment initialAlignment;

  @override
  State<FloatingButton> createState() => _FloatingButtonState();

  static const size = 56.0;
}

class _FloatingButtonState extends State<FloatingButton> {
  bool _isNavigating = false;

  bool _isDragging = false;
  Offset _dragPosition = Offset.zero;
  late FloatingButtonAlignment _currentAlignment;

  @override
  void initState() {
    super.initState();
    _currentAlignment = widget.initialAlignment;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          AnimatedPositioned(
            width: FloatingButton.size,
            height: FloatingButton.size,
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
                                instanceContainer: widget.instanceContainer,
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

  FloatingButtonAlignment _findNearest(BuildContext context, Offset current) {
    var minDistance = double.infinity;
    late FloatingButtonAlignment nearest;
    for (final alignment in FloatingButtonAlignment.values) {
      final distance = (alignment.position(context) - current).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = alignment;
      }
    }
    return nearest;
  }
}

extension on FloatingButtonAlignment {
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
      FloatingButtonAlignment.topLeft => Offset(
          paddingLeft,
          paddingTop,
        ),
      FloatingButtonAlignment.topCenter => Offset(
          paddingLeft + (areaSize.width - FloatingButton.size) / 2,
          paddingTop,
        ),
      FloatingButtonAlignment.topRight => Offset(
          paddingLeft + areaSize.width - FloatingButton.size,
          paddingTop,
        ),
      FloatingButtonAlignment.centerLeft => Offset(
          paddingLeft,
          paddingTop + (areaSize.height - FloatingButton.size) / 2,
        ),
      FloatingButtonAlignment.centerRight => Offset(
          paddingLeft + areaSize.width - FloatingButton.size,
          paddingTop + (areaSize.height - FloatingButton.size) / 2,
        ),
      FloatingButtonAlignment.bottomLeft => Offset(
          paddingLeft,
          paddingTop + areaSize.height - FloatingButton.size,
        ),
      FloatingButtonAlignment.bottomCenter => Offset(
          paddingLeft + (areaSize.width - FloatingButton.size) / 2,
          paddingTop + areaSize.height - FloatingButton.size,
        ),
      FloatingButtonAlignment.bottomRight => Offset(
          paddingLeft + areaSize.width - FloatingButton.size,
          paddingTop + areaSize.height - FloatingButton.size,
        )
    };
  }
}
