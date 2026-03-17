import 'dart:js_interop';

@JS('setCtrlWheelZoomSuppressed')
external void _setCtrlWheelZoomSuppressed(JSBoolean enabled);

void setCtrlWheelZoomSuppressed(bool enabled) {
  _setCtrlWheelZoomSuppressed(enabled.toJS);
}
