import 'package:flutter/material.dart';

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

/// Customize animation direction for the OverlayPopupDialog widget.
enum AnimationDirection {
  LTR,
  RTL,
  TTB,
  BTT;
}

class OverlayPopupDialogException implements Exception {
  final String message;
  OverlayPopupDialogException(this.message);

  @override
  String toString() => "OverlayPopupDialogException: $message";
}

///
/// A utility controller for managing the open and close actions of the OverlayPopupDialog widget.
/// A new OverlayPopupDialogController must be created for each OverlayPopupDialog instance.
///
/// ```dart
/// late final OverlayPopupDialogController _overlayController;
///
/// // You can initialize the controller in the initState method.
/// @override
/// void initState() {
///  super.initState();
/// _overlayController = OverlayPopupDialogController();
/// }
///
/// // Don't forget to dispose of the controller in your app lifecycle.
/// @override
/// void dispose() {
/// _overlayController.dispose();
/// super.dispose();
/// }
///
/// ```
///
class OverlayPopupDialogController {
  VoidCallback? _showCallback;
  VoidCallback? _hideCallback;
  bool _isBound = false;

  // Widget'a attach edildiğinde çağrılacak
  void attach() {
    if (_isBound) {
      throw OverlayPopupDialogException(
        'This OverlayPopupDialogController is already assigned to an OverlayPopupDialog widget. Please create a new instance for each OverlayPopupDialog widget.',
      );
    }
    _isBound = true;
  }

  void detach() {
    _isBound = false;
    _showCallback = null;
    _hideCallback = null;
  }

  bool show() {
    if (!_isBound) {
      throw OverlayPopupDialogException(
        'This OverlayPopupDialogController is not assigned to a OverlayPopupDialog widget.',
      );
    }

    if (_showCallback != null) {
      _showCallback!();
      return true;
    }

    throw OverlayPopupDialogException('No show callback is available.');
  }

  void close() {
    if (!_isBound) {
      throw OverlayPopupDialogException(
        'This OverlayPopupDialogController is not assigned to a OverlayPopupDialog widget.',
      );
    }

    if (_hideCallback != null) {
      _hideCallback!();
      return;
    }

    throw OverlayPopupDialogException(
      'No hide callback has been bound to this OverlayPopupDialogController.',
    );
  }

  void _bindCallbacks({
    required VoidCallback showCallback,
    required VoidCallback hideCallback,
  }) {
    _showCallback = showCallback;
    _hideCallback = hideCallback;
  }

  void dispose() {
    detach();
  }
}

class OverlayPopupDialog extends StatefulWidget {
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
  })  : assert(
            overlayLocation == OverlayLocation.top ||
                    overlayLocation == OverlayLocation.bottom ||
                    overlayLocation == OverlayLocation.on
                ? (animationDirection == AnimationDirection.TTB ||
                    animationDirection == AnimationDirection.BTT)
                : true,
            'For top/bottom overlay locations, animation direction must be TTB or BTT.'),
        assert(
            overlayLocation == OverlayLocation.left ||
                    overlayLocation == OverlayLocation.right
                ? (animationDirection == AnimationDirection.LTR ||
                    animationDirection == AnimationDirection.RTL)
                : true,
            'For left/right overlay locations, animation direction must be LTR or RTL.'),
        assert(leftGap >= 0, 'Left gap must be at least 0.'),
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

  @override
  State<OverlayPopupDialog> createState() => _OverlayPopupDialogState();
}

class _OverlayPopupDialogState extends State<OverlayPopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  OverlayEntry? _overlayEntry;

  final GlobalKey _childKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();

    _bindController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = _getSlideAnimation();
  }

  void _bindController() {
    widget.controller?.attach();
    widget.controller?._bindCallbacks(
      showCallback: () => _showOverlay(context),
      hideCallback: _removeOverlay,
    );
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
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    widget.controller?.detach();
    widget.controller?.dispose();
    super.dispose();
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
                    CompositedTransformFollower(
                      link: _layerLink,
                      followerAnchor: _getFollowerAnchor(),
                      targetAnchor: _getTargetAnchor(),
                      offset: _calculateOffset(),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: _getTranslationOffset(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenSize.width,
                              maxHeight: screenSize.height * 0.8,
                            ),
                            child: widget.dialogChild,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    _animationController.forward();
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

  Offset _getTranslationOffset() {
    final value = _slideAnimation.value;
    return switch (widget.animationDirection) {
      AnimationDirection.TTB => Offset(0, value),
      AnimationDirection.BTT => Offset(0, -value),
      AnimationDirection.LTR => Offset(value, 0),
      AnimationDirection.RTL => Offset(-value, 0),
    };
  }

  Widget _buildBarrier(context) {
    return SizedBox.expand(
      child: GestureDetector(
        onTap: widget.barrierDismissible ? _removeOverlay : null,
        child: ColoredBox(
          color: Theme.of(context)
              .scaffoldBackgroundColor
              .withOpacity(_fadeAnimation.value * 0.5),
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
          // Check if the controller is exists.
          if (widget.controller == null) {
            print('No controller attached. Call _showOverlay() method.');
            _showOverlay(context);
            return;
          }
        },
        child: widget.child,
      ),
    );
  }
}
