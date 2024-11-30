import 'dart:ui';

///
/// An exception thrown by the OverlayPopupDialogController class.
///
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

  void bindCallbacks({
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
