import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  auto;
}

///
/// Customize animation direction for the OverlayPopupDialog widget.
///
enum AnimationDirection {
  LTR,
  RTL,
  TTB,
  BTT;
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

final class OverlayPopupDialog extends StatefulWidget {
  const OverlayPopupDialog({
    super.key,
    required this.child,
    required this.dialogChild,
    this.overlayLocation = OverlayLocation.bottom,
    this.animationDirection = AnimationDirection.TTB,
    this.barrierDismissible = true,
    this.controller,
    this.highlightChildOnBarrier = false,
    this.highlightPadding = 4.0,
    this.highlightBorderRadius = BorderRadius.zero,
    this.leftGap = 0,
    this.rightGap = 0,
    this.topGap = 0,
    this.bottomGap = 0,
    this.barrierColor = Colors.black,
    this.curve = Curves.easeInOut,
    this.animationDuration = kThemeAnimationDuration,
    this.triggerWithLongPress = false,
    this.animationType = AnimationType.slideWithFade,
    this.scaleBegin = 0.8,
  })  : assert(leftGap >= 0, 'Left gap must be at least 0.'),
        assert(rightGap >= 0, 'Right gap must be at least 0.'),
        assert(topGap >= 0, 'Top gap must be at least 0.'),
        assert(bottomGap >= 0, 'Bottom gap must be at least 0.'),
        assert(highlightPadding >= 0, 'Highlight padding must be at least 0.');

  ///
  /// The widget that will be wrapped by the OverlayPopupDialog. It can be
  /// any widget. Preferably a non-interactive widget like a Container or a Text widget.
  /// If you want to use a widget that has an onTap property, you need to assign
  /// [OverlayPopupDialogController] to the controller property to control the visibility
  /// of the dialog.
  ///
  final Widget child;

  ///
  /// The widget that will be displayed in the overlay dialog. It can
  /// be ListView, Column, Row etc.
  ///
  final Widget dialogChild;

  ///
  /// The position of the dialog relative to the child widget.
  /// The default value is [OverlayLocation.bottom].
  ///
  final OverlayLocation overlayLocation;

  ///
  /// The direction of the animation when the dialog is displayed.
  /// The default value is [AnimationDirection.TTB].
  ///
  final AnimationDirection animationDirection;

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

  ///
  /// The gap between the dialog and the left side of the tapped widget, child.
  /// Default value is [0.0].
  ///
  /// If you want to see changes, you need to set OverlayLocation property to
  /// [OverlayLocation.left].
  ///
  final double leftGap;

  ///
  /// The gap between the dialog and the right side of the tapped widget, child.
  /// Default value is [0.0].
  /// If you want to see changes, you need to set OverlayLocation property to
  /// [OverlayLocation.right].
  ///
  final double rightGap;

  ///
  /// The gap between the dialog and the top side of the tapped widget, child.
  /// Default value is [0.0].
  /// If you want to see changes, you need to set OverlayLocation property to
  /// [OverlayLocation.top].
  ///
  final double topGap;

  ///
  /// The gap between the dialog and the bottom side of the tapped widget, child.
  /// Default value is [0.0].
  /// If you want to see changes, you need to set OverlayLocation property to
  /// [OverlayLocation.bottom].
  ///
  final double bottomGap;

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
  /// with a long press. The default value is [false].
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
  bool _isLongPressing = false;

  // Yeni değişken ekleyelim
  final _childSizeNotifier = ChangeNotifier();

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
    _animationController.stop();
    _animationController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _longPressTimer?.cancel();
    widget.controller?.detach();
    _childSizeNotifier.dispose();
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

    _slideAnimation = _getSlideAnimation();
  }

  Animation<double> _getSlideAnimation() {
    final double begin = switch (widget.animationDirection) {
      AnimationDirection.LTR => -50.0,
      AnimationDirection.RTL => 50.0,
      AnimationDirection.TTB => -50.0,
      AnimationDirection.BTT => 50.0,
    };

    return Tween<double>(
      begin: begin,
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
          // Her frame sonunda child'ın boyutunu kontrol et
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

      // Normal overlay insert'i kullanalım
      Overlay.of(context).insert(_overlayEntry!);
      _calculateOverlayHeight();
      _animationController.forward();
    } catch (e) {
      print('OverlayPopupDialog error: $e');
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _calculateOverlayHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayRenderBox =
          _overlayKey.currentContext?.findRenderObject() as RenderBox?;
      if (overlayRenderBox != null && _overlayEntry != null && mounted) {
        final newHeight = overlayRenderBox.size.height;
        final newWidth = overlayRenderBox.size.width;

        // Boyut değişmişse güncelle
        if (overlayHeight != newHeight || overlayWidth != newWidth) {
          // Önce yeni boyutları kaydet
          overlayHeight = newHeight;
          overlayWidth = newWidth;

          // Overlay'i yeniden build et
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
        // Dialog'un alt kısmı child'ın üst kısmına gelecek şekilde konumlandır
        return childPosition.dy - overlayHeight! - widget.topGap;

      case OverlayLocation.bottom:
        // Dialog'un üst kısmı child'ın alt kısmına gelecek şekilde konumlandır
        return childPosition.dy + childSize.height + widget.bottomGap;

      case OverlayLocation.on:
        // Dialog'un merkezi child'ın merkezine gelecek şekilde konumlandır
        return childPosition.dy + (childSize.height / 2) - (overlayHeight! / 2);

      case OverlayLocation.auto:
        final bestPosition = _calculateBestPosition(
          childPosition,
          childSize,
          MediaQuery.of(context).size,
        );
        return switch (bestPosition) {
          OverlayLocation.top =>
            childPosition.dy - overlayHeight! - widget.topGap,
          OverlayLocation.bottom =>
            childPosition.dy + childSize.height + widget.bottomGap,
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
        // Her layout değişikliğinde overlay boyutunu kontrol et
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
            OverlayLocation.left => childPosition.dx - widget.leftGap,
            OverlayLocation.right => screenSize.width -
                (childPosition.dx + childSize.width + widget.rightGap),
            _ => null,
          },
          constraints: BoxConstraints(
            maxWidth: switch (widget.overlayLocation) {
              OverlayLocation.left => childPosition.dx - widget.leftGap,
              OverlayLocation.right => screenSize.width -
                  (childPosition.dx + childSize.width + widget.rightGap),
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

  // Maksimum kullanılabilir alanı hesaplayan yardımcı metod
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
          // Top position için child ile AppBar arasındaki mesafeyi kullan
          childPosition.dy - topLimit - widget.topGap,
        );
      case OverlayLocation.bottom:
        return Size(
          screenSize.width,
          screenSize.height -
              (childPosition.dy + childSize.height + widget.bottomGap) -
              padding.bottom,
        );
      case OverlayLocation.left:
        return Size(
          childPosition.dx - widget.leftGap - padding.left,
          screenSize.height - topLimit - padding.bottom,
        );
      case OverlayLocation.right:
        return Size(
          screenSize.width -
              (childPosition.dx + childSize.width + widget.rightGap) -
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
      child: AnimatedBuilder(
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
      ),
    );
  }

  Offset _getTranslationOffset() {
    final value = _slideAnimation.value;

    return switch (widget.animationDirection) {
      AnimationDirection.TTB => Offset(0, value),
      AnimationDirection.BTT => Offset(0, -value),
      AnimationDirection.LTR => Offset(value, 0),
      AnimationDirection.RTL => Offset(-value, 0),
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

  Widget _buildBarrier(context, Offset childPosition, Size childSize) {
    if (!widget.highlightChildOnBarrier) {
      return SizedBox.expand(
        child: GestureDetector(
          onTap: widget.barrierDismissible ? _removeOverlay : null,
          child: ColoredBox(
            color: widget.barrierColor.withOpacity(_fadeAnimation.value * 0.5),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Tam ekran barrier
        ColoredBox(
          color: widget.barrierColor.withOpacity(_fadeAnimation.value * 0.5),
          child: const SizedBox.expand(),
        ),

        // Highlight alanı
        Positioned(
          top: childPosition.dy - widget.highlightPadding,
          left: childPosition.dx - widget.highlightPadding,
          width: childSize.width + (widget.highlightPadding * 2),
          height: childSize.height + (widget.highlightPadding * 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: widget.highlightBorderRadius,
            ),
          ),
        ),

        // Barrier için gesture detector
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
    );
  }

  Future<void> _removeOverlay() async {
    if (!mounted) return;

    try {
      await _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      print('Error removing overlay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Listener(
        key: widget.key,
        onPointerDown: (details) {
          if (widget.controller == null) {
            if (widget.triggerWithLongPress) {
              _isLongPressing = true;
              _longPressTimer = Timer(const Duration(milliseconds: 300), () {
                if (_isLongPressing) {
                  _showOverlay(context);
                }
              });
            } else {
              _showOverlay(context);
            }
          }
        },
        onPointerUp: (details) {
          if (widget.controller == null && widget.triggerWithLongPress) {
            _longPressTimer?.cancel();
            _isLongPressing = false;
          }
        },
        onPointerCancel: (details) {
          if (widget.controller == null && widget.triggerWithLongPress) {
            _longPressTimer?.cancel();
            _isLongPressing = false;
          }
        },
        child: Focus(
          key: _childKey,
          child: widget.child,
        ),
      ),
    );
  }

  OverlayLocation _calculateBestPosition(
    Offset childPosition,
    Size childSize,
    Size screenSize,
  ) {
    // Get SafeArea padding and AppBar height
    final EdgeInsets padding = MediaQuery.viewPaddingOf(context);
    final double appBarHeight = AppBar().preferredSize.height;
    final double topLimit = padding.top + appBarHeight;

    // Minimum required space (minimum height for dialog)
    const minRequiredSpace = 100.0;

    // Calculate available space for each direction considering SafeArea and AppBar
    final spaces = {
      OverlayLocation.bottom: screenSize.height -
          (childPosition.dy + childSize.height + widget.bottomGap) -
          padding.bottom,
      OverlayLocation.top: childPosition.dy - topLimit - widget.topGap,
      OverlayLocation.right: screenSize.width -
          (childPosition.dx + childSize.width + widget.rightGap) -
          padding.right,
      OverlayLocation.left: childPosition.dx - widget.leftGap - padding.left,
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
}
