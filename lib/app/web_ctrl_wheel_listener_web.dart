import 'dart:async';
import 'dart:html' as html;

typedef WebCtrlWheelCallback = bool Function({
  required double deltaY,
  required double clientX,
  required double clientY,
  required bool ctrlKey,
});

Object addWebCtrlWheelListener(WebCtrlWheelCallback callback) {
  return html.window.onWheel.listen((event) {
    final shouldPreventDefault = callback(
      deltaY: event.deltaY.toDouble(),
      clientX: event.client.x.toDouble(),
      clientY: event.client.y.toDouble(),
      ctrlKey: event.ctrlKey,
    );

    if (shouldPreventDefault) {
      event.preventDefault();
    }
  });
}

void removeWebCtrlWheelListener(Object? listener) {
  if (listener case final StreamSubscription<html.WheelEvent> subscription) {
    subscription.cancel();
  }
}

