/// A horizontal slice of a multiblock preview, ordered from bottom to top.
class StructurePreviewLayer {
  const StructurePreviewLayer({
    required this.id,
    required this.index,
    required this.label,
    required this.y,
    required this.partIds,
    required this.requiredPartCount,
    required this.optionalPartCount,
  });

  final String id;
  final int index;
  final String label;
  final double y;
  final List<String> partIds;
  final int requiredPartCount;
  final int optionalPartCount;

  int get partCount => partIds.length;

  bool containsPart(String partId) => partIds.contains(partId);
}
