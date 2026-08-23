import 'package:ctnh_wiki/features/structure_preview/models/structure_block_candidate.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_definition.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';

/// Groups structure positions by block id for candidate browsing and counts.
class StructureBlockCandidateResolver {
  const StructureBlockCandidateResolver();

  List<StructureBlockCandidate> resolveCandidates(
    StructurePreviewDefinition definition, {
    Iterable<String>? partIds,
  }) {
    final allowedPartIds = partIds?.toSet();
    final grouped = <String, List<StructurePreviewPart>>{};

    for (final part in definition.parts) {
      if (allowedPartIds != null && !allowedPartIds.contains(part.id)) {
        continue;
      }
      grouped.putIfAbsent(part.blockId, () => <StructurePreviewPart>[]).add(part);
    }

    return List.unmodifiable(
      grouped.entries.map((entry) {
        final parts = entry.value;
        final first = parts.first;
        return StructureBlockCandidate(
          id: entry.key,
          blockId: entry.key,
          displayName: first.displayName,
          description: first.description,
          category: first.category,
          state: _mergeState(parts),
          partIds: List.unmodifiable(parts.map((part) => part.id)),
          tags: _mergeTags(parts),
        );
      }),
    );
  }

  /// Groups candidates by an explicit group/pattern tag, falling back to the
  /// part category when no slot metadata is available.
  List<StructureBlockCandidateGroup> resolveGroups(
    StructurePreviewDefinition definition, {
    Iterable<String>? partIds,
  }) {
    final groups = <String, List<StructureBlockCandidate>>{};
    for (final candidate in resolveCandidates(definition, partIds: partIds)) {
      final groupId = _groupId(candidate);
      groups.putIfAbsent(groupId, () => <StructureBlockCandidate>[]).add(
        candidate,
      );
    }

    return List.unmodifiable(
      groups.entries.map(
        (entry) => StructureBlockCandidateGroup(
          id: entry.key,
          label: _groupLabel(entry.key),
          candidates: List.unmodifiable(entry.value),
        ),
      ),
    );
  }

  String _groupId(StructureBlockCandidate candidate) {
    for (final tag in candidate.tags) {
      const groupPrefix = 'group:';
      if (tag.startsWith(groupPrefix) && tag.length > groupPrefix.length) {
        return tag.substring(groupPrefix.length);
      }
      const patternPrefix = 'pattern:';
      if (tag.startsWith(patternPrefix) && tag.length > patternPrefix.length) {
        return tag.substring(patternPrefix.length);
      }
    }
    return 'category-' + candidate.category.index.toString();
  }

  String _groupLabel(String groupId) {
    if (groupId.startsWith('category-')) {
      return groupId;
    }
    return groupId;
  }

  StructurePartState _mergeState(Iterable<StructurePreviewPart> parts) {
    var hasOptional = false;
    for (final part in parts) {
      if (part.state == StructurePartState.previewOnly) {
        return StructurePartState.previewOnly;
      }
      if (part.state == StructurePartState.optional) {
        hasOptional = true;
      }
    }
    return hasOptional
        ? StructurePartState.optional
        : StructurePartState.required;
  }

  List<String> _mergeTags(Iterable<StructurePreviewPart> parts) {
    final tags = <String>{};
    for (final part in parts) {
      tags.addAll(part.tags);
    }
    return List.unmodifiable(tags);
  }
}
