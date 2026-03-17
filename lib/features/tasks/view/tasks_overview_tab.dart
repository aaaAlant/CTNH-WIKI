import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:ctnh_wiki/features/tasks/view/widgets/tasks_overview_board.dart';
import 'package:flutter/material.dart';

class TasksOverviewTab extends StatelessWidget {
  const TasksOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentPanel(
      minHeight: 760,
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(eyebrow: 'Quest Board', title: '任务概览'),
          SizedBox(height: 10),
          Text(
            '这里保留完整的任务预览页面。现在章节组放在顶部，下面联动展示当前章节的任务图和任务详情。',
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF5F554D),
            ),
          ),
          SizedBox(height: 18),
          TasksOverviewBoard(showHeader: false),
        ],
      ),
    );
  }
}
