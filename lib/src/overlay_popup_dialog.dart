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
  on;
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
    this.leftGap = 0,
    this.rightGap = 0,
    this.topGap = 0,
    this.bottomGap = 0,
    this.barrierColor = Colors.black,
    this.curve = Curves.easeInOut,
    this.animationDuration = kThemeAnimationDuration,
  })  : assert(leftGap >= 0, 'Left gap must be at least 0.'),
        assert(rightGap >= 0, 'Right gap must be at least 0.'),
        assert(topGap >= 0, 'Top gap must be at least 0.'),
        assert(bottomGap >= 0, 'Bottom gap must be at least 0.');

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
  /// For vertical overlay locations (top/bottom), the animation direction must be TTB or BTT.
  /// For horizontal overlay locations (left/right), the animation direction must be LTR or RTL.
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
  /// The curve of the animation. The default value is [Curves.easeInOut].
  ///
  final Curve curve;

  ///
  /// The duration of the animation. The default value is [kThemeAnimationDuration].
  ///
  final Duration animationDuration;

  @override
  State<OverlayPopupDialog> createState() => _OverlayPopupDialogState();
}

class _OverlayPopupDialogState extends State<OverlayPopupDialog>
    with SingleTickerProviderStateMixin {
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Overlays
  OverlayEntry? _overlayEntry;
  final GlobalKey _overlayKey = GlobalKey();
  double? overlayHeight;

  // Keys
  final GlobalKey _childKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    widget.controller?.detach();
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _bindController();
    _initializeAnimations();
  }

  void _bindController() {
    widget.controller?.attach();
    widget.controller?.bindCallbacks(
      showCallback: () => _showOverlay(context),
      hideCallback: _removeOverlay,
    );
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    _slideAnimation = _getSlideAnimation();
  }

  Animation<double> _getSlideAnimation() {
    final double begin = switch (widget.animationDirection) {
      AnimationDirection.LTR => -100.0,
      AnimationDirection.RTL => 100.0,
      AnimationDirection.TTB => -100.0,
      AnimationDirection.BTT => 100.0,
    };

    return Tween<double>(
      begin: begin,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry?.remove();

    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    final childPosition = renderBox.localToGlobal(Offset.zero);
    final childSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, animation) {
              return Stack(
                children: [
                  _buildBarrier(context),
                  _buildHighlightedChild(childPosition, childSize),
                  if ([OverlayLocation.left, OverlayLocation.right]
                      .contains(widget.overlayLocation))
                    CompositedTransformFollower(
                      link: _layerLink,
                      followerAnchor: _getFollowerAnchor(),
                      targetAnchor: _getTargetAnchor(),
                      offset: _calculateOffset(),
                      child: _buildOverlayContent(screenSize, childSize),
                    )
                  else
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _calculateOverlayPosition(childPosition, childSize),
                      child: Container(
                        key: _overlayKey,
                        child: _buildOverlayContent(screenSize, childSize),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    _calculateOverlayHeight();

    _animationController.forward();
  }

  void _calculateOverlayHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayRenderBox =
          _overlayKey.currentContext?.findRenderObject() as RenderBox?;
      if (overlayRenderBox != null && _overlayEntry != null) {
        overlayHeight = overlayRenderBox.size.height;
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  double _calculateOverlayPosition(Offset childPosition, Size childSize) {
    overlayHeight ??= 0;

    switch (widget.overlayLocation) {
      case OverlayLocation.top:
        return childPosition.dy - overlayHeight! - widget.topGap;
      case OverlayLocation.bottom:
        return childPosition.dy + childSize.height + widget.bottomGap;
      case OverlayLocation.on:
        return childPosition.dy + childSize.height - (overlayHeight! / 2);
      default:
        return 0;
    }
  }

  Widget _buildOverlayContent(Size screenSize, Size childSize) {
    Widget content = Container(
      width: [OverlayLocation.top, OverlayLocation.bottom, OverlayLocation.on]
              .contains(widget.overlayLocation)
          ? screenSize.width
          : widget.overlayLocation == OverlayLocation.left
              ? ((screenSize.width - childSize.width) / 2) - widget.leftGap
              : ((screenSize.width - childSize.width) / 2) - widget.rightGap,
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.8,
      ),
      child: widget.dialogChild,
    );

    if (widget.overlayLocation == OverlayLocation.on) {
      content = Transform.translate(
        offset: Offset(0, -childSize.height / 2),
        child: content,
      );
    }

    return Opacity(
      opacity: _fadeAnimation.value,
      child: Transform.translate(
        offset: _getTranslationOffset(),
        child: content,
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
      OverlayLocation.top => Alignment.bottomCenter,
      OverlayLocation.bottom => Alignment.topCenter,
      OverlayLocation.left => Alignment.centerRight,
      OverlayLocation.right => Alignment.centerLeft,
      OverlayLocation.on => Alignment.center,
    };
  }

  Alignment _getTargetAnchor() {
    return switch (widget.overlayLocation) {
      OverlayLocation.top => Alignment.topCenter,
      OverlayLocation.bottom => Alignment.bottomCenter,
      OverlayLocation.left => Alignment.centerLeft,
      OverlayLocation.right => Alignment.centerRight,
      OverlayLocation.on => Alignment.center,
    };
  }

  Offset _calculateOffset() {
    final gap = switch (widget.overlayLocation) {
      OverlayLocation.top => Offset(0, -widget.topGap),
      OverlayLocation.bottom => Offset(0, widget.bottomGap),
      OverlayLocation.left => Offset(-widget.leftGap, 0),
      OverlayLocation.right => Offset(widget.rightGap, 0),
      OverlayLocation.on => Offset.zero,
    };
    return gap;
  }

  Widget _buildBarrier(context) {
    return SizedBox.expand(
      child: GestureDetector(
        onTap: widget.barrierDismissible ? _removeOverlay : null,
        child: ColoredBox(
          color: widget.barrierColor.withOpacity(_fadeAnimation.value * 0.5),
        ),
      ),
    );
  }

  Widget _buildHighlightedChild(Offset childPosition, Size childSize) {
    if (!widget.highlightChildOnBarrier) return const SizedBox.shrink();

    return Positioned(
      top: childPosition.dy,
      left: childPosition.dx,
      child: GestureDetector(
        onTap: widget.barrierDismissible ? _removeOverlay : null,
        // AbsorbPointer is necessary to prevent the child widget from
        // receiving touch events when the barrier is tapped.
        child: AbsorbPointer(
          child: SizedBox(
            width: childSize.width,
            height: childSize.height,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  _removeOverlay() {
    _animationController.reverse().then((value) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Listener(
        key: _childKey,
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: (_) {
          if (widget.controller == null) {
            _showOverlay(context);
            return;
          }
        },
        child: widget.child,
      ),
    );
  }
}
