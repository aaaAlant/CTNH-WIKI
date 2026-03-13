import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:ctnh_wiki/features/versions/data/version_list_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VersionListTab extends StatefulWidget {
  const VersionListTab({super.key});

  @override
  State<VersionListTab> createState() => _VersionListTabState();
}

class _VersionListTabState extends State<VersionListTab> {
  late final List<GlobalKey> _releaseKeys;

  @override
  void initState() {
    super.initState();
    _releaseKeys = List.generate(versionReleases.length, (_) => GlobalKey());
  }

  Future<void> _jumpToRelease(int index) async {
    final targetContext = _releaseKeys[index].currentContext;
    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(eyebrow: 'Tracking', title: '开发追踪'),
        const SizedBox(height: 20),
        WorkPlanPreview(isCompact: isCompact),
        const SizedBox(height: 24),
        ContentPanel(
          minHeight: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(eyebrow: 'Releases', title: '版本列表'),
              const SizedBox(height: 28),
              isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CompactReleaseJumpBar(onSelected: _jumpToRelease),
                        const SizedBox(height: 20),
                        ...List.generate(
                          versionReleases.length,
                          (index) => Padding(
                            key: _releaseKeys[index],
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ReleaseCard(release: versionReleases[index]),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 240,
                          child: ReleaseTimelineNav(onSelected: _jumpToRelease),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: List.generate(
                              versionReleases.length,
                              (index) => Padding(
                                key: _releaseKeys[index],
                                padding: const EdgeInsets.only(bottom: 20),
                                child: ReleaseCard(
                                  release: versionReleases[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class WorkPlanPreview extends StatelessWidget {
  const WorkPlanPreview({super.key, required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return ContentPanel(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 18 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '工作计划',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF201A16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '以甘特图预览当前已受理、正在编写中的工作项目进度。',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF5F554D),
              ),
            ),
            const SizedBox(height: 18),
            isCompact
                ? const _CompactWorkPlanList()
                : const _DesktopWorkPlanGantt(),
          ],
        ),
      ),
    );
  }
}

class _DesktopWorkPlanGantt extends StatelessWidget {
  const _DesktopWorkPlanGantt();

  static const double _leftColumnWidth = 280;
  static const double _rowHeight = 56;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final timelineWidth = constraints.maxWidth - _leftColumnWidth;
        final dayWidth = timelineWidth / workPlanDays.length;

        return Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: _leftColumnWidth,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      '已受理项目',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8D8175),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: workPlanDays
                        .map(
                          (day) => SizedBox(
                            width: dayWidth,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8D8175),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...workPlanItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: _rowHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: _leftColumnWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF201A16),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.owner} · ${item.status}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7A6F64),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Row(
                              children: List.generate(
                                workPlanDays.length,
                                (index) => Container(
                                  width: dayWidth,
                                  height: _rowHeight,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: index == 0
                                            ? const Color(0xFFE8DECF)
                                            : const Color(0xFFF1EADF),
                                      ),
                                      right: BorderSide(
                                        color: index == workPlanDays.length - 1
                                            ? const Color(0xFFE8DECF)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: item.startDay * dayWidth + 6,
                              top: 8,
                              child: _GanttBar(
                                item: item,
                                width: (item.duration * dayWidth) - 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompactWorkPlanList extends StatelessWidget {
  const _CompactWorkPlanList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: workPlanItems
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE6DDCF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF201A16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.owner} · ${item.status}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A6F64),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _GanttBar(item: item, width: double.infinity),
                    const SizedBox(height: 8),
                    Text(
                      '${workPlanDays[item.startDay]} - ${workPlanDays[item.startDay + item.duration - 1]}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8D8175),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _GanttBar extends StatelessWidget {
  const _GanttBar({required this.item, required this.width});

  final WorkPlanItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.35)),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: item.progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: item.progress > 0.45
                            ? Colors.white
                            : const Color(0xFF201A16),
                      ),
                    ),
                  ),
                  Text(
                    '${(item.progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: item.progress > 0.72
                          ? Colors.white
                          : const Color(0xFF201A16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReleaseTimelineNav extends StatelessWidget {
  const ReleaseTimelineNav({super.key, required this.onSelected});

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2D7C6)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 14,
            bottom: 14,
            left: 13,
            child: Container(width: 2, color: const Color(0xFFD8CCBA)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '快速跳转',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF201A16),
                ),
              ),
              const SizedBox(height: 18),
              ...List.generate(
                versionReleases.length,
                (index) => _TimelineNavItem(
                  release: versionReleases[index],
                  onTap: () => onSelected(index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineNavItem extends StatelessWidget {
  const _TimelineNavItem({required this.release, required this.onTap});

  final VersionRelease release;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                alignment: Alignment.topCenter,
                child: Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: release.isLatest
                        ? const Color(0xFF201A16)
                        : const Color(0xFFC6B9A6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFCF6),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          release.version,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF201A16),
                          ),
                        ),
                        if (release.isLatest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7F0DE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Latest',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E6A3B),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy/MM/dd').format(release.publishedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A6F64),
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactReleaseJumpBar extends StatelessWidget {
  const _CompactReleaseJumpBar({required this.onSelected});

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        versionReleases.length,
        (index) => ActionChip(
          label: Text(versionReleases[index].version),
          onPressed: () => onSelected(index),
          backgroundColor: versionReleases[index].isLatest
              ? const Color(0xFF201A16)
              : const Color(0xFFFFFCF6),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: versionReleases[index].isLatest
                ? Colors.white
                : const Color(0xFF201A16),
          ),
          side: const BorderSide(color: Color(0xFFE2D7C6)),
        ),
      ),
    );
  }
}

class ReleaseCard extends StatelessWidget {
  const ReleaseCard({super.key, required this.release});

  final VersionRelease release;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 1100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2D7C6)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReleaseMetaPanel(release: release),
                const SizedBox(height: 20),
                ReleaseDetailsPanel(release: release),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 280, child: ReleaseMetaPanel(release: release)),
                const SizedBox(width: 24),
                Expanded(child: ReleaseDetailsPanel(release: release)),
              ],
            ),
    );
  }
}

class ReleaseMetaPanel extends StatelessWidget {
  const ReleaseMetaPanel({super.key, required this.release});

  final VersionRelease release;

  String buildRelativeTimeLabel(DateTime publishedAt) {
    final now = DateTime.now();
    final diff = now.difference(publishedAt);

    if (diff.inSeconds < 60) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 365) {
      return '${diff.inDays ~/ 30}个月前';
    } else {
      return '${diff.inDays ~/ 365}年前';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                release.version,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E6BB8),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF1E6BB8),
                ),
              ),
            ),
            if (release.isLatest)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF2E8B57)),
                ),
                child: const Text(
                  'Latest',
                  style: TextStyle(
                    color: Color(0xFF2E8B57),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _MetaLine(
          label: '发布时间',
          value:
              '${DateFormat('yyyy/MM/dd').format(release.publishedAt)} · ${buildRelativeTimeLabel(release.publishedAt)}',
        ),
        const SizedBox(height: 12),
        Text(
          release.summary,
          style: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Color(0xFF4E453E),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Highlights',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Color(0xFF8A6A37),
          ),
        ),
        const SizedBox(height: 10),
        ...release.highlights.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.circle, size: 7, color: Color(0xFFC88A3D)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF5F554D),
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8D8175),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF403833)),
          ),
        ),
      ],
    );
  }
}

class ReleaseDetailsPanel extends StatelessWidget {
  const ReleaseDetailsPanel({super.key, required this.release});

  final VersionRelease release;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '详细更新记录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF201A16),
          ),
        ),
        const SizedBox(height: 16),
        ...release.changes.map((change) => _ReleaseChangeTile(change: change)),
      ],
    );
  }
}

class _ReleaseChangeTile extends StatelessWidget {
  const _ReleaseChangeTile({required this.change});

  final ReleaseChangeEntry change;

  @override
  Widget build(BuildContext context) {
    final presentation = change.type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6DDCF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: presentation.backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                presentation.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: presentation.foregroundColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (change.scope != null) ...[
                    Text(
                      change.scope!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Color(0xFF8D8175),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    change.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF201A16),
                    ),
                  ),
                  if (change.details != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      change.details!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF5F554D),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
