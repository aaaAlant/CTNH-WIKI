import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:ctnh_wiki/features/versions/data/version_list_data.dart';
import 'package:flutter/material.dart';

class VersionListTab extends StatelessWidget {
  const VersionListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentPanel(
      minHeight: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Roadmap', title: versionListTitle),
          const SizedBox(height: 12),
          const Text(
            versionListDescription,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5F554D),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          ...versionTimeline.map((entry) => _VersionEntry(entry: entry)),
        ],
      ),
    );
  }
}

class _VersionEntry extends StatelessWidget {
  const _VersionEntry({required this.entry});

  final VersionTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2D7C6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF201A16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                entry.version,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                entry.summary,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Color(0xFF5F554D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
