import 'dart:math' as math;

import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_scene.dart';
import 'package:three_js/three_js.dart' as three;

class StructurePreviewRenderer {
  StructurePreviewRenderer(this.threeJs);

  final three.ThreeJS threeJs;
  three.OrbitControls? _controls;

  Future<void> initialize(StructurePreviewSceneData sceneData) async {
    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(sceneData.backgroundColor);

    threeJs.camera = three.PerspectiveCamera(
      sceneData.camera.fov,
      threeJs.width / threeJs.height,
      0.1,
      100,
    );
    threeJs.camera.position.setValues(
      sceneData.camera.position.x,
      sceneData.camera.position.y,
      sceneData.camera.position.z,
    );
    threeJs.camera.lookAt(_toThreeVector(sceneData.camera.target));

    _controls = three.OrbitControls(threeJs.camera, threeJs.globalKey)
      ..target.setValues(
        sceneData.camera.target.x,
        sceneData.camera.target.y,
        sceneData.camera.target.z,
      )
      ..enableDamping = true
      ..dampingFactor = 0.08
      ..screenSpacePanning = false
      ..minDistance = sceneData.camera.minDistance
      ..maxDistance = sceneData.camera.maxDistance
      ..maxPolarAngle = sceneData.camera.maxPolarAngle
      ..autoRotate = sceneData.camera.autoRotate
      ..autoRotateSpeed = sceneData.camera.autoRotateSpeed
      ..update();

    final ambientLight = three.AmbientLight(
      sceneData.ambientLightColor,
      sceneData.ambientLightIntensity,
    );
    threeJs.scene.add(ambientLight);

    final keyLight = three.DirectionalLight(
      sceneData.keyLightColor,
      sceneData.keyLightIntensity,
    );
    keyLight.position.setValues(
      sceneData.keyLightPosition.x,
      sceneData.keyLightPosition.y,
      sceneData.keyLightPosition.z,
    );
    threeJs.scene.add(keyLight);

    final fillLight = three.DirectionalLight(
      sceneData.fillLightColor,
      sceneData.fillLightIntensity,
    );
    fillLight.position.setValues(
      sceneData.fillLightPosition.x,
      sceneData.fillLightPosition.y,
      sceneData.fillLightPosition.z,
    );
    threeJs.scene.add(fillLight);

    final root = three.Group();
    for (final primitive in sceneData.primitives) {
      root.add(_buildPrimitive(primitive));
    }
    threeJs.scene.add(root);

    threeJs.addAnimationEvent((_) {
      _controls?.update();
    });
  }

  void dispose() {
    _controls?.dispose();
    _controls = null;
    three.loading.clear();
  }

  three.Object3D _buildPrimitive(StructurePrimitive primitive) {
    final geometry = switch (primitive.type) {
      StructurePrimitiveType.cuboid => three.BoxGeometry(
        primitive.size!.x,
        primitive.size!.y,
        primitive.size!.z,
      ),
      StructurePrimitiveType.cylinder => three.CylinderGeometry(
        primitive.radiusTop!,
        primitive.radiusBottom!,
        primitive.height!,
        primitive.radialSegments,
      ),
    };

    final material = three.MeshStandardMaterial.fromMap({
      'color': primitive.material.color,
      'metalness': primitive.material.metalness,
      'roughness': primitive.material.roughness,
      'transparent': primitive.material.opacity < 1,
      'opacity': primitive.material.opacity,
    });

    final mesh = three.Mesh(geometry, material);
    mesh.position.setValues(
      primitive.position.x,
      primitive.position.y,
      primitive.position.z,
    );
    mesh.rotation.x = _degreesToRadians(primitive.rotation.x);
    mesh.rotation.y = _degreesToRadians(primitive.rotation.y);
    mesh.rotation.z = _degreesToRadians(primitive.rotation.z);
    return mesh;
  }

  three.Vector3 _toThreeVector(StructureVector3 value) {
    return three.Vector3(value.x, value.y, value.z);
  }

  double _degreesToRadians(double value) {
    return value * (math.pi / 180);
  }
}
