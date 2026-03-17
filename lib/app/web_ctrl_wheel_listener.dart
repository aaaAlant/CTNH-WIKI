import 'package:ctnh_wiki/app/web_ctrl_wheel_listener_stub.dart'
    if (dart.library.html) 'package:ctnh_wiki/app/web_ctrl_wheel_listener_web.dart';

class WebCtrlWheelListener {
  const WebCtrlWheelListener._();

  static Object? add(WebCtrlWheelCallback callback) {
    return addWebCtrlWheelListener(callback);
  }

  static void remove(Object? listener) {
    removeWebCtrlWheelListener(listener);
  }
}
