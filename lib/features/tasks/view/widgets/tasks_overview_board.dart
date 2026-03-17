import 'package:ctnh_wiki/features/tasks/data/quest_catalog_repository.dart';
import 'package:ctnh_wiki/features/tasks/models/quest_catalog.dart';
import 'package:ctnh_wiki/features/tasks/view/widgets/quest_chapter_groups_panel.dart';
import 'package:ctnh_wiki/features/tasks/view/widgets/quest_detail_panel.dart';
import 'package:ctnh_wiki/features/tasks/view/widgets/quest_graph_panel.dart';
import 'package:flutter/material.dart';

class TasksOverviewBoard extends StatefulWidget {
  const TasksOverviewBoard({
    super.key,
    this.showHeader = true,
    this.framed = true,
  });

  final bool showHeader;
  final bool framed;

  @override
  State<TasksOverviewBoard> createState() => _TasksOverviewBoardState();
}

class _TasksOverviewBoardState extends State<TasksOverviewBoard> {
  static const _repository = QuestCatalogRepository();
  static const _panelAnimationDuration = Duration(milliseconds: 300);

  late final Future<QuestCatalog> _catalogFuture;
  String? _selectedChapterId;
  String? _selectedQuestId;
  bool _detailCollapsed = false;
  final Set<String> _expandedGroupIds = <String>{};

  @override
  void initState() {
    super.initState();
    _catalogFuture = _repository.loadCatalog();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuestCatalog>(
      future: _catalogFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _BoardShell(
            framed: widget.framed,
            child: Center(child: Text('任务目录加载失败：${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return _BoardShell(
            framed: widget.framed,
            child: const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final catalog = snapshot.data!;
        final width = MediaQuery.sizeOf(context).width;
        final isCompact = width < 1180;
        final selectedChapter = _resolveSelectedChapter(catalog);
        final selectedQuest = _resolveSelectedQuest(selectedChapter);
        final expandedGroupIds = _effectiveExpandedGroupIds(
          catalog,
          selectedChapter,
        );

        return _BoardShell(
          framed: widget.framed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                const Text(
                  '任务概览',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF201A16),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '这一块直接读取 FTB Quests 静态转译后的任务目录。章节组放在上方，下方联动展示当前章节的任务图和任务详情。',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: Color(0xFF5F554D),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: '章节组', value: '${catalog.chapterGroups.length}'),
                  _StatChip(label: '章节', value: '${catalog.chapters.length}'),
                  _StatChip(
                    label: '当前章节任务',
                    value: '${selectedChapter.quests.length}',
                  ),
                  _StatChip(label: '版本', value: 'v${catalog.version}'),
                ],
              ),
              const SizedBox(height: 18),
              QuestChapterGroupsPanel(
                catalog: catalog,
                selectedChapter: selectedChapter,
                expandedGroupIds: expandedGroupIds,
                onGroupToggle: _toggleGroup,
                onChapterSelected: _handleChapterSelected,
              ),
              const SizedBox(height: 18),
              if (isCompact) ...[
                QuestGraphPanel(
                  chapter: selectedChapter,
                  selectedQuest: selectedQuest,
                  onQuestSelected: _handleQuestSelected,
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: _panelAnimationDuration,
                  curve: Curves.easeInOutCubic,
                  height: _detailCollapsed ? 172 : 760,
                  child: QuestDetailPanel(
                    chapter: selectedChapter,
                    quest: selectedQuest,
                    collapsed: _detailCollapsed,
                    onToggle: _toggleDetailPanel,
                    isCompact: true,
                  ),
                ),
              ] else
                SizedBox(
                  height: 760,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 13,
                        child: QuestGraphPanel(
                          chapter: selectedChapter,
                          selectedQuest: selectedQuest,
                          onQuestSelected: _handleQuestSelected,
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedContainer(
                        duration: _panelAnimationDuration,
                        curve: Curves.easeInOutCubic,
                        width: _detailCollapsed ? 84 : 332,
                        child: QuestDetailPanel(
                          chapter: selectedChapter,
                          quest: selectedQuest,
                          collapsed: _detailCollapsed,
                          onToggle: _toggleDetailPanel,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  QuestChapter _resolveSelectedChapter(QuestCatalog catalog) {
    return catalog.chapterById(_selectedChapterId) ?? catalog.chapters.first;
  }

  QuestDefinition? _resolveSelectedQuest(QuestChapter chapter) {
    if (chapter.quests.isEmpty) {
      return null;
    }
    return chapter.questById(_selectedQuestId) ?? chapter.quests.first;
  }

  Set<String> _effectiveExpandedGroupIds(
    QuestCatalog catalog,
    QuestChapter selectedChapter,
  ) {
    if (_expandedGroupIds.isNotEmpty) {
      return _expandedGroupIds;
    }

    final selectedGroupId = selectedChapter.groupId;
    if (selectedGroupId != null && selectedGroupId.isNotEmpty) {
      return {selectedGroupId};
    }

    if (catalog.chapterGroups.isNotEmpty) {
      return {catalog.chapterGroups.first.id};
    }

    return const <String>{};
  }

  void _toggleGroup(String groupId) {
    setState(() {
      if (_expandedGroupIds.contains(groupId)) {
        _expandedGroupIds.remove(groupId);
      } else {
        _expandedGroupIds.add(groupId);
      }
    });
  }

  void _toggleDetailPanel() {
    setState(() {
      _detailCollapsed = !_detailCollapsed;
    });
  }

  void _handleChapterSelected(QuestChapter chapter) {
    setState(() {
      _selectedChapterId = chapter.id;
      _selectedQuestId = chapter.quests.isEmpty ? null : chapter.quests.first.id;
      if (chapter.groupId != null) {
        _expandedGroupIds.add(chapter.groupId!);
      }
    });
  }

  void _handleQuestSelected(QuestDefinition quest) {
    setState(() {
      _selectedQuestId = quest.id;
      if (_detailCollapsed) {
        _detailCollapsed = false;
      }
    });
  }
}

class _BoardShell extends StatelessWidget {
  const _BoardShell({required this.child, required this.framed});

  final Widget child;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: framed ? const EdgeInsets.all(22) : EdgeInsets.zero,
      decoration: framed
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5D9C8)),
            )
          : null,
      child: child,
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2D7C6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A5F37),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
        ],
      ),
    );
  }
}
