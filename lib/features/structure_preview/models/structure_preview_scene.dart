enum StructurePrimitiveType { cuboid, cylinder }

class StructureVector3 {
  const StructureVector3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

class StructureRotation {
  const StructureRotation(this.x, this.y, this.z);

  const StructureRotation.zero() : this(0, 0, 0);

  final double x;
  final double y;
  final double z;
}

class StructureMaterialStyle {
  const StructureMaterialStyle({
    required this.color,
    this.metalness = 0.1,
    this.roughness = 0.85,
    this.opacity = 1,
  });

  final int color;
  final double metalness;
  final double roughness;
  final double opacity;
}

class StructureCameraConfig {
  const StructureCameraConfig({
    required this.position,
    this.target = const StructureVector3(0, 0, 0),
    this.fov = 42,
    this.minDistance = 4,
    this.maxDistance = 18,
    this.maxPolarAngle = 1.42,
    this.autoRotate = true,
    this.autoRotateSpeed = 0.8,
  });

  final StructureVector3 position;
  final StructureVector3 target;
  final double fov;
  final double minDistance;
  final double maxDistance;
  final double maxPolarAngle;
  final bool autoRotate;
  final double autoRotateSpeed;
}

class StructurePrimitive {
  const StructurePrimitive.cuboid({
    required this.id,
    required this.position,
    required this.size,
    required this.material,
    this.rotation = const StructureRotation.zero(),
  }) : type = StructurePrimitiveType.cuboid,
       radiusTop = null,
       radiusBottom = null,
       height = null,
       radialSegments = 0;

  const StructurePrimitive.cylinder({
    required this.id,
    required this.position,
    required this.radiusTop,
    required this.radiusBottom,
    required this.height,
    required this.material,
    this.rotation = const StructureRotation.zero(),
    this.radialSegments = 18,
  }) : type = StructurePrimitiveType.cylinder,
       size = null;

  final String id;
  final StructurePrimitiveType type;
  final StructureVector3 position;
  final StructureVector3? size;
  final double? radiusTop;
  final double? radiusBottom;
  final double? height;
  final int radialSegments;
  final StructureRotation rotation;
  final StructureMaterialStyle material;
}

class StructurePreviewSceneData {
  const StructurePreviewSceneData({
    required this.id,
    required this.camera,
    required this.primitives,
    this.backgroundColor = 0xFF2A3139,
    this.ambientLightColor = 0xFFF4E7CB,
    this.ambientLightIntensity = 1.8,
    this.keyLightColor = 0xFFFFF3DA,
    this.keyLightIntensity = 2.6,
    this.keyLightPosition = const StructureVector3(5.5, 8, 5),
    this.fillLightColor = 0xFF8AA8C4,
    this.fillLightIntensity = 1.4,
    this.fillLightPosition = const StructureVector3(-5.5, 4, -3.5),
  });

  final String id;
  final StructureCameraConfig camera;
  final List<StructurePrimitive> primitives;
  final int backgroundColor;
  final int ambientLightColor;
  final double ambientLightIntensity;
  final int keyLightColor;
  final double keyLightIntensity;
  final StructureVector3 keyLightPosition;
  final int fillLightColor;
  final double fillLightIntensity;
  final StructureVector3 fillLightPosition;
}
