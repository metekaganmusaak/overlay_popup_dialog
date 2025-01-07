import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_popup_dialog/src/overlay_popup_dialog_controller.dart';

///
/// The enum class for adjusting the position of the OverlayPopupDialog relative to the clicked widget.
///
enum OverlayLocation {
  top,
  bottom,
  left,
  right,
  on,

  /// Auto position the overlay based on the child's position and size.
  auto;
}

///
/// Customize animation type for the OverlayPopupDialog widget.
///
enum AnimationType {
  fade,
  scale,
  slideWithFade,
  scaleWithFade,
  slideWithScale;
}

/// A highly customizable overlay dialog widget that appears relative to a child widget.
///
/// This widget creates a popup dialog that can be positioned in relation to its child widget.
/// It supports various animations, barrier effects, and positioning options.
///
/// Example usage:
/// ```dart
/// OverlayPopupDialog(
///   child: ElevatedButton(
///     onPressed: () {},
///     child: Text('Show Overlay'),
///   ),
///   dialogChild: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Overlay Content'),
///   ),
///   overlayLocation: OverlayLocation.bottom,
///   highlightChildOnBarrier: true,
/// )
/// ```
final class OverlayPopupDialog extends StatefulWidget {
  /// Creates an overlay popup dialog.
  ///
  /// The [child] is the widget that triggers the overlay.
  /// The [dialogChild] is the content to be shown in the overlay.
  ///
  /// Use [overlayLocation] to control where the overlay appears relative to the child.
  /// Set [highlightChildOnBarrier] to true to create a "spotlight" effect on the child.
  const OverlayPopupDialog({
    super.key,
    required this.child,
    required this.dialogChild,
    this.overlayLocation = OverlayLocation.auto,
    this.barrierDismissible = true,
    this.controller,
    this.highlightChildOnBarrier = false,
    this.highlightPadding = 0.0,
    this.highlightBorderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.barrierColor = Colors.black,
    this.curve = Curves.easeInOut,
    this.animationDuration = kThemeAnimationDuration,
    this.triggerWithLongPress = false,
    this.animationType = AnimationType.slideWithFade,
    this.scaleBegin = 0.8,
  }) : assert(highlightPadding >= 0, 'Highlight padding must be at least 0.');

  ///
  /// The widget that will be wrapped by the OverlayPopupDialog. It can be
  /// any widget. Preferably a non-interactive widget like a Container or a Text widget.
  /// Also you can use a widget that has an onTap property like buttons, chips etc.
  ///
  final Widget child;

  ///
  /// The widget that will be displayed in the overlay dialog. It can
  /// be ListView, Column, Row etc. Default height is child's height. Maximum
  /// height is the space between the child and the top, left, right or bottom of the screen.
  ///
  final Widget dialogChild;

  ///
  /// The position of the dialog relative to the child widget.
  /// The default value is [OverlayLocation.auto].
  ///
  final OverlayLocation overlayLocation;

  ///
  /// A boolean value that determines whether the dialog can be
  /// closed by tapping on the overlay. The default value is [true].
  ///
  final bool barrierDismissible;

  ///
  /// A controller that manages the visibility of the dialog. If you want
  /// to use a widget that has an onTap property, you need to assign [OverlayPopupDialogController]
  /// to the controller property to control the visibility of the dialog.
  ///
  final OverlayPopupDialogController? controller;

  ///
  /// This boolean value determines whether the child widget will be highlighted
  /// when the dialog is displayed. The default value is [false].
  ///
  final bool highlightChildOnBarrier;

  /// The padding around the highlighted child widget when [highlightChildOnBarrier] is true.
  /// Default value is 4.0.
  final double highlightPadding;

  /// The border radius of the highlighted area when [highlightChildOnBarrier] is true.
  /// Default value is [BorderRadius.zero].
  final BorderRadius highlightBorderRadius;

  /// The padding between the dialog and the child widget.
  /// Use this to control the spacing around the dialog.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.only(top: 8), // Adds space above the dialog
  /// padding: EdgeInsets.all(16), // Adds space around all sides
  /// ```
  final EdgeInsets padding;

  ///
  /// The color of the barrier that appears behind the dialog.
  /// The default value is [Colors.black.withOpacity(0.5)]
  ///
  final Color barrierColor;

  ///
  /// The curve of the animation. Default value is [Curves.easeInOut].
  ///
  final Curve curve;

  ///
  /// The duration of the animation. Default value is [kThemeAnimationDuration].
  ///
  final Duration animationDuration;

  ///
  /// A boolean value that determines whether the dialog will be triggered
  /// with a long press. The default value is [false]. If controller attached
  /// to the dialog, this property will be ignored. But you can create your
  /// custom onLongPress callback to trigger the dialog.
  ///
  final bool triggerWithLongPress;

  ///
  /// The type of animation to use when showing/hiding the dialog.
  /// Default is [AnimationType.slideWithFade].
  ///
  final AnimationType animationType;

  ///
  /// The initial scale value for scale animations.
  /// Only used when animationType is [AnimationType.scale] or [AnimationType.scaleWithFade].
  /// Default is 0.8.
  ///
  final double scaleBegin;

  @override
  State<OverlayPopupDialog> createState() => _OverlayPopupDialogState();
}

class _OverlayPopupDialogState extends State<OverlayPopupDialog>
    with SingleTickerProviderStateMixin {
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Overlays
  OverlayEntry? _overlayEntry;
  final GlobalKey _overlayKey = GlobalKey();
  double? overlayHeight;
  double? overlayWidth;

  // Keys
  final GlobalKey _childKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  // Variables
  Timer? _longPressTimer;

  Offset? _touchStartPosition;

  // Add ValueNotifier for overlay dimensions
  late final ValueNotifier<Size?> _overlaySizeNotifier = ValueNotifier(null);

  // Cache calculated positions
  late final ValueNotifier<Offset?> _lastCalculatedPosition =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _bindController();
  }

  @override
  void didUpdateWidget(OverlayPopupDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _bindController();
    }
  }

  @override
  void dispose() {
    _overlaySizeNotifier.dispose();
    _lastCalculatedPosition.dispose();
    _animationController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _longPressTimer?.cancel();
    widget.controller?.detach();
    super.dispose();
  }

  void _bindController() {
    if (!mounted) return;

    widget.controller?.attach();
    widget.controller?.bindCallbacks(
      showCallback: () {
        if (mounted) _showOverlay(context);
      },
      hideCallback: () {
        if (mounted) _removeOverlay();
      },
    );
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      debugLabel: 'OverlayPopupDialogAnimation',
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.5, curve: widget.curve),
    );

    _scaleAnimation = Tween<double>(
      begin: widget.scaleBegin,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.1, 0.8, curve: widget.curve),
    ));

    // Update slide animation based on overlay location
    _slideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: widget.curve),
    ));
  }

  void _showOverlay(BuildContext context) {
    if (!mounted) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    try {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          // Remove child controllers
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_overlayEntry != null && mounted) {
              _overlayEntry!.markNeedsBuild();
            }
          });

          return LayoutBuilder(
            builder: (context, constraints) {
              final renderBox =
                  _childKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox == null || !mounted) {
                return const SizedBox.shrink();
              }

              final childPosition = renderBox.localToGlobal(Offset.zero);
              final childSize = renderBox.size;
              final screenSize = MediaQuery.of(context).size;

              final effectiveLocation = widget.overlayLocation ==
                      OverlayLocation.auto
                  ? _calculateBestPosition(childPosition, childSize, screenSize)
                  : widget.overlayLocation;

              return Material(
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, animation) {
                    return Stack(
                      children: [
                        _buildBarrier(context, childPosition, childSize),
                        if ([OverlayLocation.left, OverlayLocation.right]
                            .contains(effectiveLocation))
                          CompositedTransformFollower(
                            link: _layerLink,
                            followerAnchor: _getFollowerAnchor(),
                            targetAnchor: _getTargetAnchor(),
                            child: _buildOverlayContent(
                                screenSize, childSize, childPosition),
                          )
                        else
                          Positioned(
                            left: widget.overlayLocation == OverlayLocation.on
                                ? childPosition.dx + (childSize.width / 2)
                                : 0,
                            right: widget.overlayLocation == OverlayLocation.on
                                ? null
                                : 0,
                            top: _calculateOverlayPosition(
                                childPosition, childSize),
                            child: Container(
                              key: _overlayKey,
                              transform: widget.overlayLocation ==
                                          OverlayLocation.on &&
                                      overlayWidth != null
                                  ? Matrix4.translationValues(
                                      -overlayWidth! / 2, 0, 0)
                                  : null,
                              child: _buildOverlayContent(
                                  screenSize, childSize, childPosition),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      );

      Overlay.of(context).insert(_overlayEntry!);
      _calculateOverlayHeight();
      _animationController.forward();
    } catch (e) {
      debugPrint('Error showing overlay: $e');
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _calculateOverlayHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayRenderBox =
          _overlayKey.currentContext?.findRenderObject() as RenderBox?;
      if (overlayRenderBox != null && _overlayEntry != null && mounted) {
        final newSize = overlayRenderBox.size;

        // Only update if size actually changed
        if (_overlaySizeNotifier.value?.height != newSize.height ||
            _overlaySizeNotifier.value?.width != newSize.width) {
          _overlaySizeNotifier.value = newSize;

          if (mounted) {
            _overlayEntry!.markNeedsBuild();
          }
        }
      }
    });
  }

  double _calculateOverlayPosition(Offset childPosition, Size childSize) {
    if (overlayHeight == null) return 0;

    switch (widget.overlayLocation) {
      case OverlayLocation.top:
        return childPosition.dy - overlayHeight! - widget.padding.top;

      case OverlayLocation.bottom:
        return childPosition.dy + childSize.height + widget.padding.bottom;

      case OverlayLocation.on:
        return childPosition.dy + (childSize.height / 2) - (overlayHeight! / 2);

      case OverlayLocation.auto:
        final bestPosition = _calculateBestPosition(
          childPosition,
          childSize,
          MediaQuery.of(context).size,
        );
        return switch (bestPosition) {
          OverlayLocation.top =>
            childPosition.dy - overlayHeight! - widget.padding.top,
          OverlayLocation.bottom =>
            childPosition.dy + childSize.height + widget.padding.bottom,
          OverlayLocation.on =>
            childPosition.dy + (childSize.height / 2) - (overlayHeight! / 2),
          _ => 0,
        };
      default:
        return 0;
    }
  }

  Widget _buildOverlayContent(
      Size screenSize, Size childSize, Offset childPosition) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check overlay size on every layout change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final overlayRenderBox =
              _overlayKey.currentContext?.findRenderObject() as RenderBox?;
          if (overlayRenderBox != null && mounted) {
            final newHeight = overlayRenderBox.size.height;
            final newWidth = overlayRenderBox.size.width;

            if (overlayHeight != newHeight || overlayWidth != newWidth) {
              overlayHeight = newHeight;
              overlayWidth = newWidth;
              if (_overlayEntry != null) {
                _overlayEntry!.markNeedsBuild();
              }
            }
          }
        });

        final wrappedDialog = Material(
          color: Colors.transparent,
          child: widget.dialogChild,
        );

        Widget content = Container(
          width: switch (widget.overlayLocation) {
            OverlayLocation.left => childPosition.dx - widget.padding.left,
            OverlayLocation.right => screenSize.width -
                (childPosition.dx + childSize.width + widget.padding.right),
            _ => null,
          },
          constraints: BoxConstraints(
            maxWidth: switch (widget.overlayLocation) {
              OverlayLocation.left => childPosition.dx - widget.padding.left,
              OverlayLocation.right => screenSize.width -
                  (childPosition.dx + childSize.width + widget.padding.right),
              _ => screenSize.width * 0.9,
            },
            maxHeight: _calculateMaxAvailableSpace(
                    screenSize, childSize, childPosition)
                .height,
          ),
          child: wrappedDialog,
        );

        return _buildAnimatedContent(content);
      },
    );
  }

  // Calculate maximum available space
  Size _calculateMaxAvailableSpace(
    Size screenSize,
    Size childSize,
    Offset childPosition,
  ) {
    // Get SafeArea padding and AppBar height
    final EdgeInsets padding = MediaQuery.viewPaddingOf(context);
    final double appBarHeight = AppBar().preferredSize.height;
    final double topLimit = padding.top + appBarHeight;

    switch (widget.overlayLocation) {
      case OverlayLocation.top:
        return Size(
          screenSize.width,
          // Use the distance between child and AppBar for top position
          childPosition.dy - topLimit - widget.padding.top,
        );
      case OverlayLocation.bottom:
        return Size(
          screenSize.width,
          screenSize.height -
              (childPosition.dy + childSize.height + widget.padding.bottom) -
              padding.bottom,
        );
      case OverlayLocation.left:
        return Size(
          childPosition.dx - widget.padding.left - padding.left,
          screenSize.height - topLimit - padding.bottom,
        );
      case OverlayLocation.right:
        return Size(
          screenSize.width -
              (childPosition.dx + childSize.width + widget.padding.right) -
              padding.right,
          screenSize.height - topLimit - padding.bottom,
        );
      case OverlayLocation.on:
      case OverlayLocation.auto:
        return Size(
          screenSize.width - padding.left - padding.right,
          screenSize.height - topLimit - padding.bottom,
        );
    }
  }

  Widget _buildAnimatedContent(Widget child) {
    return RepaintBoundary(
      child: ValueListenableBuilder<Size?>(
        valueListenable: _overlaySizeNotifier,
        builder: (context, size, _) {
          if (size == null) return child;

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              Widget content = child;

              switch (widget.animationType) {
                case AnimationType.fade:
                  content = FadeTransition(
                    opacity: _fadeAnimation,
                    child: child,
                  );
                  break;

                case AnimationType.scale:
                  content = ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: _getAnimationAlignment(),
                    child: child,
                  );
                  break;

                case AnimationType.slideWithFade:
                  content = FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: _getTranslationOffset(),
                      child: child,
                    ),
                  );
                  break;

                case AnimationType.scaleWithFade:
                  content = FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      alignment: _getAnimationAlignment(),
                      child: child,
                    ),
                  );
                  break;

                case AnimationType.slideWithScale:
                  content = ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: _getAnimationAlignment(),
                    child: Transform.translate(
                      offset: _getTranslationOffset(),
                      child: child,
                    ),
                  );
                  break;
              }

              return content;
            },
          );
        },
      ),
    );
  }

  Offset _getTranslationOffset() {
    final value = _slideAnimation.value;

    return switch (widget.overlayLocation) {
      OverlayLocation.top => Offset(0, value),
      OverlayLocation.bottom => Offset(0, -value),
      OverlayLocation.left => Offset(value, 0),
      OverlayLocation.right => Offset(-value, 0),
      _ => Offset(0, -value), // Default for 'on' and 'auto'
    };
  }

  Alignment _getFollowerAnchor() {
    return switch (widget.overlayLocation) {
      OverlayLocation.left => Alignment.centerRight,
      OverlayLocation.right => Alignment.centerLeft,
      _ => Alignment.center,
    };
  }

  Alignment _getTargetAnchor() {
    return switch (widget.overlayLocation) {
      OverlayLocation.left => Alignment.centerLeft,
      OverlayLocation.right => Alignment.centerRight,
      _ => Alignment.center,
    };
  }

  /// Builds the barrier with highlight effect if enabled
  /// [childPosition] represents the global position of the child widget
  /// [childSize] represents the size of the child widget
  Widget _buildBarrier(context, Offset childPosition, Size childSize) {
    // Cache the barrier color with opacity
    final barrierColorWithOpacity = widget.barrierColor.withValues(
      alpha: _fadeAnimation.value * 0.5,
    );

    if (!widget.highlightChildOnBarrier) {
      return SizedBox.expand(
        child: GestureDetector(
          onTap: widget.barrierDismissible ? _removeOverlay : null,
          child: ColoredBox(
            color: barrierColorWithOpacity,
          ),
        ),
      );
    }

    // Cache section calculations
    final topHeight = childPosition.dy - widget.highlightPadding;
    final sectionHeight = childSize.height + (widget.highlightPadding * 2);
    final leftWidth = childPosition.dx - widget.highlightPadding;

    return RepaintBoundary(
      child: Stack(
        children: [
          // Barrier sections
          Stack(
            children: [
              // Top section
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topHeight,
                child: _buildBarrierSection(),
              ),
              // Left section
              Positioned(
                top: topHeight,
                left: 0,
                width: leftWidth,
                height: sectionHeight,
                child: _buildBarrierSection(),
              ),
              // Right section
              Positioned(
                top: topHeight,
                left: childPosition.dx +
                    childSize.width +
                    widget.highlightPadding,
                right: 0,
                height: sectionHeight,
                child: _buildBarrierSection(),
              ),
              // Bottom section
              Positioned(
                top: topHeight + sectionHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBarrierSection(),
              ),
            ],
          ),

          // Gesture detector for barrier
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.barrierDismissible ? _removeOverlay : null,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarrierSection() {
    return ColoredBox(
      color: widget.barrierColor.withValues(
        alpha: _fadeAnimation.value * 0.5,
      ),
    );
  }

  Future<void> _removeOverlay() async {
    if (!mounted) return;

    try {
      await _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      debugPrint('Error removing overlay: $e');
    }
  }

  /// Calculates the best position for the overlay based on available space
  /// Takes into account screen edges, safe area, and app bar height
  OverlayLocation _calculateBestPosition(
    Offset childPosition,
    Size childSize,
    Size screenSize,
  ) {
    // Calculate safe area and app bar constraints
    final EdgeInsets padding = MediaQuery.viewPaddingOf(context);
    final double appBarHeight = AppBar().preferredSize.height;
    final double topLimit = padding.top + appBarHeight;

    // Minimum required space (minimum height for dialog)
    const minRequiredSpace = 100.0;

    // Calculate available space for each direction considering SafeArea and AppBar
    final spaces = {
      OverlayLocation.bottom: screenSize.height -
          (childPosition.dy + childSize.height + widget.padding.bottom) -
          padding.bottom,
      OverlayLocation.top: childPosition.dy - topLimit - widget.padding.top,
      OverlayLocation.right: screenSize.width -
          (childPosition.dx + childSize.width + widget.padding.right) -
          padding.right,
      OverlayLocation.left:
          childPosition.dx - widget.padding.left - padding.left,
    };

    // Filter directions with sufficient space
    final availableSpaces = spaces.entries
        .where((entry) => entry.value >= minRequiredSpace)
        .toList();

    // If no sufficient space, select direction with maximum available space
    if (availableSpaces.isEmpty) {
      return spaces.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    // Select based on priority order among directions with sufficient space
    final preferredOrder = [
      OverlayLocation.bottom,
      OverlayLocation.top,
      OverlayLocation.right,
      OverlayLocation.left,
    ];

    for (final location in preferredOrder) {
      if (availableSpaces.any((entry) => entry.key == location)) {
        return location;
      }
    }

    return availableSpaces.first.key;
  }

  Alignment _getAnimationAlignment() {
    return switch (widget.overlayLocation) {
      OverlayLocation.top => Alignment.bottomCenter,
      OverlayLocation.bottom => Alignment.topCenter,
      OverlayLocation.left => Alignment.centerRight,
      OverlayLocation.right => Alignment.centerLeft,
      OverlayLocation.on => Alignment.center,
      OverlayLocation.auto => Alignment.center,
    };
  }

  /// Handles scroll detection and prevents overlay from showing during scroll
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Listener(
        key: widget.key,
        behavior: HitTestBehavior.opaque,
        onPointerDown: (details) {
          // Store initial touch position for scroll detection
          _touchStartPosition = details.position;
          if (widget.controller == null && widget.triggerWithLongPress) {
            _longPressTimer = Timer(const Duration(milliseconds: 300), () {
              if (_touchStartPosition != null) {
                _showOverlay(context);
              }
            });
          }
        },
        onPointerMove: (details) {
          // If movement is greater than threshold, consider it a scroll
          if (_touchStartPosition != null) {
            final distance = (details.position - _touchStartPosition!).distance;
            if (distance > 10) {
              // 10px threshold for scroll detection
              _touchStartPosition = null;
              _longPressTimer?.cancel();
            }
          }
        },
        onPointerUp: (details) {
          if (_touchStartPosition != null) {
            final distance = (details.position - _touchStartPosition!).distance;
            if (distance < 10) {
              if (widget.controller == null && !widget.triggerWithLongPress) {
                _showOverlay(context);
              }
            }
          }
          _touchStartPosition = null;
          _longPressTimer?.cancel();
        },
        onPointerCancel: (_) {
          _touchStartPosition = null;
          _longPressTimer?.cancel();
        },
        child: Focus(
          key: _childKey,
          child: widget.child,
        ),
      ),
    );
  }
}
