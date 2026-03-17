import 'package:ctnh_wiki/features/tasks/models/quest_catalog.dart';
import 'package:flutter/material.dart';

class QuestChapterGroupsPanel extends StatelessWidget {
  const QuestChapterGroupsPanel({
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
    final groups = _resolveGroups(catalog);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5D9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '章节组',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '先在这里切换章节组和章节，下面的任务图与详情会同步更新。',
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Color(0xFF5F554D),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1320 ? 3 : width >= 840 ? 2 : 1;
              final spacing = 12.0;
              final cardWidth = columns == 1
                  ? width
                  : (width - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: groups
                    .map(
                      (group) => SizedBox(
                        width: cardWidth,
                        child: _QuestGroupCard(
                          group: group.group,
                          chapters: group.chapters,
                          expanded: expandedGroupIds.contains(group.group.id),
                          selectedChapterId: selectedChapter.id,
                          onGroupToggle: () => onGroupToggle(group.group.id),
                          onChapterSelected: onChapterSelected,
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  List<_ResolvedQuestGroup> _resolveGroups(QuestCatalog catalog) {
    final groups = catalog.chapterGroups.map((group) {
      final chapters = group.chapterIds
          .map(catalog.chapterById)
          .whereType<QuestChapter>()
          .toList(growable: false);
      return _ResolvedQuestGroup(group: group, chapters: chapters);
    }).toList(growable: true);

    final groupedChapterIds = catalog.chapterGroups
        .expand((group) => group.chapterIds)
        .toSet();
    final ungroupedChapters = catalog.chapters
        .where((chapter) => !groupedChapterIds.contains(chapter.id))
        .toList(growable: false);

    if (ungroupedChapters.isNotEmpty) {
      groups.add(
        _ResolvedQuestGroup(
          group: QuestChapterGroup(
            id: 'ungrouped',
            title: '未分组章节',
            chapterIds: ungroupedChapters.map((chapter) => chapter.id).toList(),
          ),
          chapters: ungroupedChapters,
        ),
      );
    }

    return groups;
  }
}

class _ResolvedQuestGroup {
  const _ResolvedQuestGroup({required this.group, required this.chapters});

  final QuestChapterGroup group;
  final List<QuestChapter> chapters;
}

class _QuestGroupCard extends StatelessWidget {
  const _QuestGroupCard({
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: expanded ? const Color(0xFFF8F1E5) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: expanded
              ? const Color(0xFFD9B98B)
              : const Color(0xFFE7DCCB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onGroupToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: const Color(0xFF7A5A34),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      group.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF201A16),
                      ),
                    ),
                  ),
                  Text(
                    '${chapters.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A6A37),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chapters
                  .map(
                    (chapter) => _ChapterChip(
                      chapter: chapter,
                      selected: chapter.id == selectedChapterId,
                      onTap: () => onChapterSelected(chapter),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChapterChip extends StatelessWidget {
  const _ChapterChip({
    required this.chapter,
    required this.selected,
    required this.onTap,
  });

  final QuestChapter chapter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6E4320) : const Color(0xFFF4EBDD),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFF0D39E)
                : const Color(0xFFE2D6C3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chapter.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF5F554D),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${chapter.questCount}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFFFFE5B9)
                    : const Color(0xFF8A6A37),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
