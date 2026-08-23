import 'package:ctnh_wiki/features/structure_preview/data/structure_texture_manifest.g.dart';
import 'package:ctnh_wiki/features/structure_preview/models/structure_preview_part.dart';
import 'package:flutter/material.dart';

class StructureCandidateOverlay extends StatelessWidget {
  const StructureCandidateOverlay({super.key, required this.candidates});

  final List<StructureBlockCandidate> candidates;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 14,
      top: 14,
      width: 290,
      child: Material(
        color: const Color(0xE610171C),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 15,
                    color: Color(0xFF9BE2D8),
                  ),
                  SizedBox(width: 7),
                  Text(
                    '可替换仓室',
                    style: TextStyle(
                      color: Color(0xFFF5F0E6),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 310),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      for (final candidate in candidates)
                        _CandidateTile(candidate: candidate),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({required this.candidate});

  final StructureBlockCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final iconPath =
        'assets/textures/modules/auto/icons/' +
        candidate.blockId.replaceAll(':', '_') +
        '.png';
    final hasIcon = structureTextureManifest.containsKey(candidate.blockId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 74,
          height: 72,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C343B),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF4B5A62)),
          ),
          child: hasIcon
              ? Image.asset(
                  iconPath,
                  width: 62,
                  height: 60,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.inventory_2_rounded,
                    size: 28,
                    color: Color(0xFF9AA8AF),
                  ),
                )
              : const Icon(
                  Icons.inventory_2_rounded,
                  size: 28,
                  color: Color(0xFFC88B69),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    candidate.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF7F1E8),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    candidate.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFAAB7BD),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
