import 'package:ctnh_wiki/features/tasks/models/quest_catalog.dart';
import 'package:ctnh_wiki/features/tasks/view/widgets/quest_item_icon.dart';
import 'package:flutter/material.dart';

class QuestDetailPanel extends StatelessWidget {
  const QuestDetailPanel({
    super.key,
    required this.chapter,
    required this.quest,
    required this.collapsed,
    required this.onToggle,
    this.isCompact = false,
  });

  final QuestChapter chapter;
  final QuestDefinition? quest;
  final bool collapsed;
  final VoidCallback onToggle;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.all(collapsed && !isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2D7C6)),
      ),
      child: collapsed && !isCompact
          ? _CollapsedDesktopPanel(quest: quest, onToggle: onToggle)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '任务详情',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF201A16),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            quest == null
                                ? '当前章节没有可展示的任务。'
                                : '点击左侧节点后，这里会展示任务说明、目标、奖励和前置关系。',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Color(0xFF6A5E53),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ToggleButton(collapsed: collapsed, onPressed: onToggle),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: collapsed
                        ? _CollapsedInlinePanel(
                            key: const ValueKey('collapsed-inline'),
                            quest: quest,
                            isCompact: isCompact,
                          )
                        : _ExpandedQuestDetail(
                            key: ValueKey("expanded-${quest?.id ?? 'empty'}"),
                            chapter: chapter,
                            quest: quest,
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ExpandedQuestDetail extends StatelessWidget {
  const _ExpandedQuestDetail({
    super.key,
    required this.chapter,
    required this.quest,
  });

  final QuestChapter chapter;
  final QuestDefinition? quest;

  @override
  Widget build(BuildContext context) {
    if (quest == null) {
      return const Center(
        child: Text(
          '当前章节没有可展示的任务。',
          style: TextStyle(fontSize: 15, color: Color(0xFF6A5E53)),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quest!.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quest!.subtitle ?? '所属章节：${chapter.title}',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6A5E53),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DetailChip(label: '形状', value: quest!.shape),
              _DetailChip(label: '坐标', value: '${quest!.x}, ${quest!.y}'),
              _DetailChip(label: '前置', value: '${quest!.dependencies.length}'),
              _DetailChip(label: '目标', value: '${quest!.tasks.length}'),
              _DetailChip(label: '奖励', value: '${quest!.rewards.length}'),
            ],
          ),
          if (quest!.hasUnresolvedText) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3DA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5C47C)),
              ),
              child: const Text(
                '当前任务仍有部分文案没有完全解析，这里会优先使用任务语言表，其次回退到提取出的物品名称。',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF6C4A20),
                ),
              ),
            ),
          ],
          if (quest!.description.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _PanelLabel('任务说明'),
            const SizedBox(height: 10),
            ...quest!.description.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  line,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: Color(0xFF4E443D),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const _PanelLabel('任务目标'),
          const SizedBox(height: 10),
          Column(
            children: quest!.tasks
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TaskCard(task: task),
                  ),
                )
                .toList(),
          ),
          if (quest!.rewards.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _PanelLabel('奖励内容'),
            const SizedBox(height: 10),
            Column(
              children: quest!.rewards
                  .map(
                    (reward) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RewardCard(reward: reward),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (quest!.dependencies.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _PanelLabel('前置任务'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quest!.dependencies
                  .map((dependency) => _DependencyPill(label: dependency))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CollapsedDesktopPanel extends StatelessWidget {
  const _CollapsedDesktopPanel({required this.quest, required this.onToggle});

  final QuestDefinition? quest;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _ToggleButton(collapsed: true, onPressed: onToggle),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EBDC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF7A5A34),
                  ),
                ),
                const SizedBox(height: 18),
                const RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    '任务详情',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF201A16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    quest?.title ?? '点击节点查看',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6A5E53),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CollapsedInlinePanel extends StatelessWidget {
  const _CollapsedInlinePanel({
    super.key,
    required this.quest,
    required this.isCompact,
  });

  final QuestDefinition? quest;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 14 : 18,
          vertical: isCompact ? 18 : 24,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F2E8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5D8C8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: Color(0xFF8A6A37),
            ),
            const SizedBox(height: 10),
            Text(
              quest?.title ?? '任务详情',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF201A16),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '详情已收起，点击右上角按钮展开。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF6A5E53),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.collapsed, required this.onPressed});

  final bool collapsed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? '展开详情' : '收起详情',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBDC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D7C6)),
          ),
          child: Icon(
            collapsed
                ? Icons.keyboard_double_arrow_left_rounded
                : Icons.keyboard_double_arrow_right_rounded,
            color: const Color(0xFF7A5A34),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final QuestTask task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5D8C8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestItemIcon(
            size: 34,
            assetPath: task.primaryItemIconAssetPath,
            fallbackIcon: _taskIcon(task.type),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF201A16),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.target ??
                      (task.primaryItemLabel == null
                          ? task.type
                          : task.primaryItemLabel!),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF6C6056),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _taskIcon(String type) {
    return switch (type) {
      'item' || 'loot' => Icons.inventory_2_rounded,
      'kill' => Icons.gps_fixed_rounded,
      'dimension' || 'structure' || 'biome' => Icons.map_rounded,
      'checkmark' => Icons.task_alt_rounded,
      'xp' || 'xp_levels' => Icons.bolt_rounded,
      _ => Icons.extension_rounded,
    };
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.reward});

  final QuestReward reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5D8C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              QuestItemIcon(
                size: 36,
                assetPath: reward.primaryItemIconAssetPath,
                fallbackIcon: reward.type == 'random'
                    ? Icons.casino_rounded
                    : Icons.card_giftcard_rounded,
                backgroundColor: const Color(0xFFF4E6C9),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4E6C9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  reward.type == 'random' ? '随机奖励' : '固定奖励',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF835925),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reward.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF201A16),
                  ),
                ),
              ),
            ],
          ),
          if (reward.tableEntries.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reward.tableEntries
                  .take(8)
                  .map((entry) => _DependencyPill(label: entry.label))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBDC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Color(0xFF5C5148)),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _DependencyPill extends StatelessWidget {
  const _DependencyPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5D0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B4F2D),
        ),
      ),
    );
  }
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Color(0xFF8A6A37),
      ),
    );
  }
}







