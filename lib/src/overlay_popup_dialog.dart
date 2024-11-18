import 'package:flutter/material.dart';

/// Enum for the location of the overlay popup dialog.
enum OverlayLocation {
  top,
  bottom,
  on;
}

/// Overlay popup dialog that shows a dialog on top of the screen.
class OverlayPopupDialog extends StatefulWidget {
  const OverlayPopupDialog({
    super.key,
    required this.child,
    required this.dialogChild,
    this.overlayLocation = OverlayLocation.bottom,
    this.barrierDismissible = true,
    this.popupDialogTheme = const PopupDialogTheme(),
    this.showCloseIcon = true,
  });

  /// This widget is tappable widget that will trigger the overlay
  /// popup dialog.
  final Widget child;

  /// This widget will be shown on the overlay popup dialog. It can be
  /// ListView with horizontal scroll or Row with multiple children.
  final Widget dialogChild;

  /// Location of the overlay popup dialog. Default is [OverlayLocation.bottom].
  final OverlayLocation overlayLocation;

  /// If true, overlay popup dialog will be closed when user taps outside.
  final bool barrierDismissible;

  /// Theme for the overlay popup dialog.
  final PopupDialogTheme? popupDialogTheme;

  /// If true, close icon will be shown on the right side of the dialog.
  final bool showCloseIcon;

  @override
  State<OverlayPopupDialog> createState() => _OverlayPopupDialogState();
}

class _OverlayPopupDialogState extends State<OverlayPopupDialog>
    with SingleTickerProviderStateMixin {
  // Animation and controller instances.
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Overlay entry to show an popup dialog.
  OverlayEntry? _overlayEntry;

  // This global key is used to get the position of the 'tapped' child widget.
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();

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

    _slideAnimation = Tween<double>(
      begin: -20.0,
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
    _fadeAnimation.isAnimating ? _animationController.stop() : null;
    _slideAnimation.isAnimating ? _animationController.stop() : null;
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    // Remove the previous overlay entry if it exists.
    _overlayEntry?.remove();

    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    final childPosition = renderBox.localToGlobal(Offset.zero);
    final childSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, animation) {
              print('childPosition.dy: ${childPosition.dy}');

              return Stack(
                children: [
                  // Background that closes overlay when tapped.
                  // Same logic with barrier dismissible property in BottomSheets, Dialogs etc.
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.barrierDismissible) {
                          _removeOverlay();
                        }
                      },
                      child: ColoredBox(
                        color: Colors.black
                            .withOpacity(_fadeAnimation.value * 0.5),
                      ),
                    ),
                  ),

                  // Dialog widget
                  Positioned(
                    // Position of the dialog widget.
                    top: switch (widget.overlayLocation) {
                      OverlayLocation.top => childPosition.dy -
                          childSize.height -
                          _slideAnimation.value,
                      OverlayLocation.on => childPosition.dy +
                          (childSize.height / 2) -
                          (kToolbarHeight / 2) +
                          _slideAnimation.value,
                      OverlayLocation.bottom => childPosition.dy +
                          childSize.height +
                          _slideAnimation.value,
                    },
                    left: 0, // From left edge of the screen
                    right: 0, // To right edge of the screen
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          Container(
                            height: widget.popupDialogTheme?.height,
                            padding: widget.popupDialogTheme?.padding,
                            width: double.infinity,
                            decoration: widget.popupDialogTheme?.decoration ??
                                BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(child: widget.dialogChild),
                                  if (widget.showCloseIcon) ...[
                                    const VerticalDivider(),
                                    IconButton(
                                      onPressed: () {
                                        _removeOverlay();
                                      },
                                      icon: Icon(
                                        widget.popupDialogTheme?.closeIcon ??
                                            Icons.close,
                                        color: widget.popupDialogTheme
                                                ?.closeIconColor ??
                                            Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
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
  final IconData? closeIcon;
  final Color? closeIconColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final double? height;

  const PopupDialogTheme({
    this.closeIcon,
    this.closeIconColor,
    this.padding,
    this.margin,
    this.decoration,
    this.height,
  });

  PopupDialogTheme copyWith({
    IconData? closeIcon,
    Color? closeIconColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
    double? height,
  }) {
    return PopupDialogTheme(
      closeIcon: closeIcon ?? this.closeIcon,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
      height: height ?? this.height,
    );
  }

  static PopupDialogTheme of(BuildContext context) {
    return PopupDialogTheme(
      closeIcon: Icons.close,
      height: kToolbarHeight,
      closeIconColor: Theme.of(context).iconTheme.color,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
