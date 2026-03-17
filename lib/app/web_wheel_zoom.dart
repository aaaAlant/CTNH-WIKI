import 'package:ctnh_wiki/app/web_wheel_zoom_bridge_stub.dart'
    if (dart.library.js_interop) 'package:ctnh_wiki/app/web_wheel_zoom_bridge_web.dart'
    as web_wheel_zoom_bridge;

class WebWheelZoomController {
  const WebWheelZoomController._();

  static void setSuppressed(bool suppressed) {
    web_wheel_zoom_bridge.setCtrlWheelZoomSuppressed(suppressed);
  }
}
