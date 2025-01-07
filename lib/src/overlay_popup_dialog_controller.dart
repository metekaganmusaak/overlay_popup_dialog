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
  bool _isAttached = false;
  bool _isDisposed = false;

  void attach() {
    assert(!_isDisposed, 'Controller is disposed');
    _isAttached = true;
  }

  void detach() {
    if (_isDisposed) return;
    _isAttached = false;
    _showCallback = null;
    _hideCallback = null;
  }

  void bindCallbacks({
    required VoidCallback showCallback,
    required VoidCallback hideCallback,
  }) {
    assert(!_isDisposed, 'Controller is disposed');
    assert(_isAttached, 'Controller is not attached');

    _showCallback = showCallback;
    _hideCallback = hideCallback;
  }

  void show() {
    if (!_isAttached || _isDisposed) return;
    _showCallback?.call();
  }

  void hide() {
    if (!_isAttached || _isDisposed) return;
    _hideCallback?.call();
  }

  void dispose() {
    _isDisposed = true;
    detach();
  }

  bool get isAttached => _isAttached && !_isDisposed;
}
