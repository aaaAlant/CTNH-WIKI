import 'package:ctnh_wiki/features/guides/data/guides_tutorial_data.dart';
import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';

class GuidesTutorialTab extends StatelessWidget {
  const GuidesTutorialTab({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return ContentPanel(
      minHeight: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Guides', title: guidesTutorialTitle),
          const SizedBox(height: 12),
          const Text(
            guidesTutorialDescription,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5F554D),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          isCompact
              ? Column(
                  children: guidesTutorialSections
                      .map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GuidePlaceholderCard(
                            title: section.$1,
                            description: section.$2,
                          ),
                        ),
                      )
                      .toList(),
                )
              : Row(
                  children: guidesTutorialSections
                      .map(
                        (section) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: section == guidesTutorialSections.last
                                  ? 0
                                  : 14,
                            ),
                            child: _GuidePlaceholderCard(
                              title: section.$1,
                              description: section.$2,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _GuidePlaceholderCard extends StatelessWidget {
  const _GuidePlaceholderCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xFF201A16)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF5F554D),
            ),
          ),
        ],
      ),
    );
  }
}
