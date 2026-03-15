import 'package:flutter/widgets.dart';
import 'package:three_js/three_js.dart' as three;

class StructureHitTestService {
  final three.Raycaster _raycaster = three.Raycaster();
  final three.Vector2 _pointer = three.Vector2.zero();
  final List<three.Intersection> _intersections = [];

  String? pickPartId({
    required dynamic event,
    required GlobalKey<three.PeripheralsState> listenableKey,
    required three.Camera camera,
    required List<three.Object3D> objects,
  }) {
    final renderObject = listenableKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || objects.isEmpty) {
      return null;
    }

    final size = renderObject.size;
    final local = renderObject.globalToLocal(const Offset(0, 0));

    _pointer.x = (event.clientX - local.dx) / size.width * 2 - 1;
    _pointer.y = -(event.clientY - local.dy) / size.height * 2 + 1;

    _intersections.clear();
    _raycaster.setFromCamera(_pointer, camera);
    _raycaster.intersectObjects(objects, true, _intersections);

    if (_intersections.isEmpty) {
      return null;
    }

    return _intersections.first.object?.userData['partId'] as String?;
  }
}
