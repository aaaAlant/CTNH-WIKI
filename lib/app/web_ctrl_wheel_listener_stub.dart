typedef WebCtrlWheelCallback = bool Function({
  required double deltaY,
  required double clientX,
  required double clientY,
  required bool ctrlKey,
});

Object? addWebCtrlWheelListener(WebCtrlWheelCallback callback) {
  return null;
}

void removeWebCtrlWheelListener(Object? listener) {}
