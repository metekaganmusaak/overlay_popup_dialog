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

  // Prevents the controller from being assigned to multiple OverlayPopupDialog widgets.
  bool _isBound = false;

  void _bind() {
    if (_isBound) {
      throw Exception(
        'This OverlayPopupDialogController is already assigned to a OverlayPopupDialog widget. Please create a new instance for each OverlayPopupDialog widget.',
      );
    }
    _isBound = true;
  }

  void _unbind() {
    _isBound = false;
  }

  ///
  /// Shows the OverlayPopupDialog widget.
  ///
  void show() {
    if (_showCallback != null) {
      _showCallback!();
    }
  }

  ///
  /// Closes the OverlayPopupDialog widget.
  ///
  void close() {
    if (_hideCallback != null) {
      _hideCallback!();
    }
  }

  void _bindCallbacks({
    required VoidCallback showCallback,
    required VoidCallback hideCallback,
  }) {
    _bind();
    _showCallback = showCallback;
    _hideCallback = hideCallback;
  }

  void dispose() {
    _showCallback = null;
    _hideCallback = null;
    _unbind();
  }
}

class OverlayPopupDialog extends StatefulWidget {
  ///
  /// A widget that displays an overlay dialog when the child widget is clicked.
  ///

  factory OverlayPopupDialog({
    Key? key,
    required Widget child,
    required Widget dialogChild,
    OverlayLocation overlayLocation = OverlayLocation.bottom,
    AnimationDirection animationDirection = AnimationDirection.TTB,
    bool barrierDismissible = true,
    PopupDialogTheme? popupDialogTheme,
    OverlayPopupDialogController? controller,
    Duration animationDuration = kThemeAnimationDuration,
    bool highlightChildOnBarrier = false,
    BoxConstraints? constraints,
  }) {
    // Vertical overlay locations (top/bottom)
    if (overlayLocation == OverlayLocation.top ||
        overlayLocation == OverlayLocation.bottom ||
        overlayLocation == OverlayLocation.on) {
      if (animationDirection != AnimationDirection.TTB &&
          animationDirection != AnimationDirection.BTT) {
        throw ArgumentError(
            'For top/bottom overlay locations, animation direction must be TTB or BTT. '
            'Current values: overlayLocation: $overlayLocation, animationDirection: $animationDirection');
      }
    }

    // Horizontal overlay locations (left/right)
    if (overlayLocation == OverlayLocation.left ||
        overlayLocation == OverlayLocation.right) {
      if (animationDirection != AnimationDirection.LTR &&
          animationDirection != AnimationDirection.RTL) {
        throw ArgumentError(
            'For left/right overlay locations, animation direction must be LTR or RTL. '
            'Current values: overlayLocation: $overlayLocation, animationDirection: $animationDirection');
      }
    }

    return OverlayPopupDialog._internal(
      key: key,
      dialogChild: dialogChild,
      overlayLocation: overlayLocation,
      animationDirection: animationDirection,
      barrierDismissible: barrierDismissible,
      popupDialogTheme: popupDialogTheme,
      controller: controller,
      animationDuration: animationDuration,
      highlightChildOnBarrier: highlightChildOnBarrier,
      constraints: constraints,
      child: child,
    );
  }

  const OverlayPopupDialog._internal({
    super.key,
    required this.child,
    required this.dialogChild,
    required this.overlayLocation,
    required this.animationDirection,
    required this.barrierDismissible,
    this.popupDialogTheme,
    this.controller,
    required this.animationDuration,
    required this.highlightChildOnBarrier,
    this.constraints,
  });

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
  /// A boolean value that determines whether the dialog can be
  /// closed by tapping on the overlay. The default value is [true].
  ///
  final bool barrierDismissible;

  ///
  /// The theme of the dialog. You can customize the padding,
  /// decoration, height, leftMargin, and rightMargin properties. The default value is
  /// **[PopupDialogTheme.of(context)]**.
  final PopupDialogTheme? popupDialogTheme;

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

  final Duration animationDuration;
  final AnimationDirection animationDirection;
  final BoxConstraints? constraints;

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
  final GlobalKey _dialogKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animasyon yönüne göre başlangıç ve bitiş değerlerini ayarlayalım
    _slideAnimation = _getSlideAnimation();

    // Bind to callbacks to access the show and hide methods of the controller.
    widget.controller?._bindCallbacks(
      showCallback: () => _showOverlay(context),
      hideCallback: _removeOverlay,
    );
  }

  Animation<double> _getSlideAnimation() {
    final direction = switch (widget.overlayLocation) {
      OverlayLocation.top => AnimationDirection.TTB,
      OverlayLocation.bottom => AnimationDirection.TTB,
      OverlayLocation.left => AnimationDirection.RTL,
      OverlayLocation.right => AnimationDirection.LTR,
      OverlayLocation.on => AnimationDirection.TTB,
    };

    final double begin = switch (direction) {
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
    widget.controller?.dispose();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry?.remove();

    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    final childPosition = renderBox.localToGlobal(Offset.zero);
    final childSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final popupDialogHeight = _getDialogSize()?.height ??
        widget.popupDialogTheme?.height ??
        kToolbarHeight;

    print('Child position: ${childPosition.dy}');
    print('Child size: ${childSize.height}');
    print('Popup dialog height: $popupDialogHeight');

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, animation) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.barrierDismissible) {
                          _removeOverlay();
                        }
                      },
                      child: ColoredBox(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(
                              _fadeAnimation.value * 0.5,
                            ),
                      ),
                    ),
                  ),
                  if (widget.highlightChildOnBarrier)
                    Positioned(
                      top: childPosition.dy,
                      left: childPosition.dx,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.barrierDismissible) {
                            _removeOverlay();
                          }
                        },
                        child: SizedBox(
                          width: childSize.width,
                          height: childSize.height,
                          child: widget.child,
                        ),
                      ),
                    ),
                  Positioned(
                    top: switch (widget.overlayLocation) {
                      OverlayLocation.top => childPosition.dy -
                          popupDialogHeight +
                          (_slideAnimation.value *
                              (widget.animationDirection ==
                                      AnimationDirection.BTT
                                  ? -1
                                  : 1)),
                      OverlayLocation.bottom => childPosition.dy +
                          childSize.height +
                          (_slideAnimation.value *
                              (widget.animationDirection ==
                                      AnimationDirection.BTT
                                  ? -1
                                  : 1)),
                      OverlayLocation.left ||
                      OverlayLocation.right =>
                        childPosition.dy,
                      OverlayLocation.on =>
                        ((childPosition.dy + childSize.height) / 2) +
                            _slideAnimation.value *
                                (widget.animationDirection ==
                                        AnimationDirection.BTT
                                    ? -1
                                    : 1),
                    },
                    left: switch (widget.overlayLocation) {
                      OverlayLocation.left => childPosition.dx -
                          (_getDialogSize()?.width ?? 0) +
                          (_slideAnimation.value *
                              (widget.animationDirection ==
                                      AnimationDirection.LTR
                                  ? -1
                                  : 1)) -
                          (widget.popupDialogTheme?.leftMargin ?? 0),
                      OverlayLocation.right => childPosition.dx +
                          childSize.width +
                          _slideAnimation.value +
                          (widget.popupDialogTheme?.rightMargin ?? 0),
                      _ => widget.popupDialogTheme?.leftMargin ?? 0,
                    },
                    right: switch (widget.overlayLocation) {
                      OverlayLocation.left || OverlayLocation.right => null,
                      _ => widget.popupDialogTheme?.rightMargin ?? 0,
                    },
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: ConstrainedBox(
                        constraints: widget.constraints ??
                            BoxConstraints(
                              maxWidth: screenSize.width,
                              minWidth: 100,
                            ),
                        child: Container(
                          key: _dialogKey,
                          height: _getDialogSize()?.height ??
                              widget.popupDialogTheme?.height ??
                              kToolbarHeight,
                          decoration: widget.popupDialogTheme?.decoration ??
                              BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                          child: Padding(
                            padding: widget.popupDialogTheme?.padding ??
                                EdgeInsets.zero,
                            child: widget.dialogChild,
                          ),
                        ),
                      ),
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
    _animationController.forward();
  }

  Size? _getDialogSize() {
    if (_dialogKey.currentContext != null) {
      final RenderBox renderBox =
          _dialogKey.currentContext!.findRenderObject() as RenderBox;

      return renderBox.size;
    }
    return null;
  }

  void _removeOverlay() {
    _animationController.reverse().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _childKey,
      onTap: () {
        _showOverlay(context);
      },
      child: widget.child,
    );
  }
}

class PopupDialogTheme {
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final double? height;
  final double? leftMargin;
  final double? rightMargin;

  const PopupDialogTheme({
    this.padding = EdgeInsets.zero,
    this.decoration = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.zero,
    ),
    this.height,
    this.leftMargin = 0,
    this.rightMargin = 0,
  })  : assert(padding != null, 'Padding must not be null.'),
        assert(decoration != null, 'Decoration must not be null.'),
        assert(
          leftMargin != null && leftMargin >= 0,
          'Left start point must be at least 0.',
        ),
        assert(
          rightMargin != null && rightMargin >= 0,
          'Right start point must be at least 0.',
        );

  PopupDialogTheme copyWith({
    EdgeInsets? padding,
    BoxDecoration? decoration,
    double? height,
  }) {
    return PopupDialogTheme(
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      height: height ?? this.height,
    );
  }

  static PopupDialogTheme of(BuildContext context) {
    return PopupDialogTheme(
      height: kToolbarHeight,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
