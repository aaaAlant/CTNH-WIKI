import 'package:flutter/material.dart';

class TaskOverviewMetric {
  const TaskOverviewMetric({required this.value, required this.label});

  final String value;
  final String label;
}

class TaskOverviewStage {
  const TaskOverviewStage({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const tasksOverviewTitle = '任务概览';
const tasksOverviewDescription = '按推进阶段整理任务书的重点目标，方便快速判断当前该补哪些基础、该读哪些章节。';

const tasksOverviewMetrics = [
  TaskOverviewMetric(value: '4', label: '推进阶段'),
  TaskOverviewMetric(value: '12', label: '关键节点'),
  TaskOverviewMetric(value: '1', label: '主阅读路径'),
];

const tasksOverviewStages = [
  TaskOverviewStage(
    title: '开荒阶段',
    description: '先解决食物、矿物、基础工具与首套稳定电力，建立能持续推进的底座。',
    icon: Icons.forest_rounded,
  ),
  TaskOverviewStage(
    title: '工业阶段',
    description: '围绕矿物处理、物流和机器链扩张，把手工作业压缩到最少。',
    icon: Icons.factory_rounded,
  ),
  TaskOverviewStage(
    title: '联动阶段',
    description: '开始处理科技与魔法的交叉依赖，建立跨模组材料和资源闭环。',
    icon: Icons.hub_rounded,
  ),
  TaskOverviewStage(
    title: '终盘阶段',
    description: '聚焦高阶机器、多维度资源与复杂配方，逐步清理长期瓶颈。',
    icon: Icons.rocket_launch_rounded,
  ),
];
