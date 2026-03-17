import 'package:ctnh_wiki/features/tasks/models/quest_catalog.dart';
import 'package:flutter/material.dart';

class QuestChapterSidebar extends StatelessWidget {
  const QuestChapterSidebar({
    super.key,
    required this.catalog,
    required this.selectedChapter,
    required this.expandedGroupIds,
    required this.onGroupToggle,
    required this.onChapterSelected,
  });

  final QuestCatalog catalog;
  final QuestChapter selectedChapter;
  final Set<String> expandedGroupIds;
  final ValueChanged<String> onGroupToggle;
  final ValueChanged<QuestChapter> onChapterSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 760,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E160B),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFB88A46), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            catalog.sourceTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF3DDB2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'v${catalog.version} · ${catalog.progressionMode}',
            style: const TextStyle(fontSize: 12, color: Color(0xFFE4C791)),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF7A5226), height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: catalog.chapterGroups.map((group) {
                  final chapters = group.chapterIds
                      .map(catalog.chapterById)
                      .whereType<QuestChapter>()
                      .toList(growable: false);
                  final expanded = expandedGroupIds.contains(group.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _QuestGroupSection(
                      group: group,
                      chapters: chapters,
                      expanded: expanded,
                      selectedChapterId: selectedChapter.id,
                      onGroupToggle: () => onGroupToggle(group.id),
                      onChapterSelected: onChapterSelected,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestGroupSection extends StatelessWidget {
  const _QuestGroupSection({
    required this.group,
    required this.chapters,
    required this.expanded,
    required this.selectedChapterId,
    required this.onGroupToggle,
    required this.onChapterSelected,
  });

  final QuestChapterGroup group;
  final List<QuestChapter> chapters;
  final bool expanded;
  final String selectedChapterId;
  final VoidCallback onGroupToggle;
  final ValueChanged<QuestChapter> onChapterSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B1F10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7A5226)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onGroupToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: const Color(0xFFEFD3A2),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      group.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF6E1B5),
                      ),
                    ),
                  ),
                  Text(
                    '${chapters.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD6B37B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: chapters.map((chapter) {
                  final selected = chapter.id == selectedChapterId;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () => onChapterSelected(chapter),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF6E4320)
                              : const Color(0xFF442514),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFF0D39E)
                                : const Color(0xFF704A27),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFF0D39E)
                                    : const Color(0xFFAF8556),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                chapter.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '${chapter.questCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFE4C791),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
