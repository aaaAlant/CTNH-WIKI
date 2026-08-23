import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_hit_result.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:flutter/widgets.dart';
import 'package:three_js/three_js.dart' as three;

class StructureHitTestService {
  final three.Raycaster _raycaster = three.Raycaster();
  final three.Vector2 _pointer = three.Vector2.zero();
  final List<three.Intersection> _intersections = [];

  StructurePreviewHitResult? pickHit({
    required dynamic event,
    required GlobalKey<three.PeripheralsState> listenableKey,
    required three.Camera camera,
    required List<three.Object3D> objects,
  }) {
    return _pickAt(
      (event.clientX as num).toDouble(),
      (event.clientY as num).toDouble(),
      listenableKey: listenableKey,
      camera: camera,
      objects: objects,
    );
  }

  StructurePreviewHitResult? pickHitAt({
    required Offset localPosition,
    required GlobalKey<three.PeripheralsState> listenableKey,
    required three.Camera camera,
    required List<three.Object3D> objects,
  }) {
    return _pickAt(
      localPosition.dx,
      localPosition.dy,
      listenableKey: listenableKey,
      camera: camera,
      objects: objects,
    );
  }

  StructurePreviewHitResult? _pickAt(
    double localX,
    double localY, {
    required GlobalKey<three.PeripheralsState> listenableKey,
    required three.Camera camera,
    required List<three.Object3D> objects,
  }) {
    final renderObject = listenableKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || objects.isEmpty) {
      return null;
    }

    final size = renderObject.size;
    if (size.width <= 0 || size.height <= 0) {
      return null;
    }

    _pointer.x = localX / size.width * 2 - 1;
    _pointer.y = -localY / size.height * 2 + 1;

    _intersections.clear();
    _raycaster.setFromCamera(_pointer, camera);
    _raycaster.intersectObjects(objects, true, _intersections);

    if (_intersections.isEmpty) {
      return null;
    }

    _intersections.sort((left, right) {
      final leftPriority =
          (left.object?.userData['selectionPriority'] as num?)?.toInt() ?? 0;
      final rightPriority =
          (right.object?.userData['selectionPriority'] as num?)?.toInt() ?? 0;
      if (leftPriority != rightPriority) {
        return rightPriority.compareTo(leftPriority);
      }
      return left.distance.compareTo(right.distance);
    });

    final object = _intersections.first.object;
    if (object == null) {
      return null;
    }
    final partId = object.userData['partId'] as String?;
    if (partId == null || partId.isEmpty) {
      return null;
    }

    return StructurePreviewHitResult(
      partId: partId,
      primitiveId: object.name,
      layerId: object.userData['layerId'] as String?,
      gridPosition: object.userData['gridPosition'] is StructureVector3
          ? object.userData['gridPosition'] as StructureVector3
          : null,
    );
  }

  String? pickPartId({
    required dynamic event,
    required GlobalKey<three.PeripheralsState> listenableKey,
    required three.Camera camera,
    required List<three.Object3D> objects,
  }) {
    return pickHit(
      event: event,
      listenableKey: listenableKey,
      camera: camera,
      objects: objects,
    )?.partId;
  }
}
