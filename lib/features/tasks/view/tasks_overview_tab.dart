import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:ctnh_wiki/features/tasks/data/tasks_overview_data.dart';
import 'package:flutter/material.dart';

class TasksOverviewTab extends StatelessWidget {
  const TasksOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return ContentPanel(
      minHeight: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Quest Flow', title: tasksOverviewTitle),
          const SizedBox(height: 12),
          const Text(
            tasksOverviewDescription,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5F554D),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: tasksOverviewMetrics
                .map((metric) => _MetricCard(metric: metric))
                .toList(),
          ),
          const SizedBox(height: 24),
          isCompact
              ? Column(
                  children: tasksOverviewStages
                      .map(
                        (stage) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StageCard(stage: stage),
                        ),
                      )
                      .toList(),
                )
              : Row(
                  children: tasksOverviewStages
                      .map(
                        (stage) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: stage == tasksOverviewStages.last ? 0 : 14,
                            ),
                            child: _StageCard(stage: stage),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final TaskOverviewMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2D7C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF62574D),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage});

  final TaskOverviewStage stage;

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
          Icon(stage.icon, color: const Color(0xFF201A16)),
          const SizedBox(height: 14),
          Text(
            stage.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            stage.description,
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
