import 'package:ctnh_wiki/features/home/models/home_module.dart';
import 'package:flutter/material.dart';

const homeHero = HomeHeroData(
  title: '欢迎来到《机械动力：新视野》整合包',
  description:
      '这是一款集科技、魔法、冒险、农业于一体的大型整合包。CTNH 以 Create 与 GregTech 为核心，并通过自研模组和大规模脚本改动，构建出一套更长线、更有层次的推进体验。',
);

const homeExploreEyebrow = 'Explore';
const homeExploreTitle = '科技、魔法与冒险三条主线';

const homeStats = [
  HomeStat(value: '100,000+', label: '魔改配方'),
  HomeStat(value: '120+', label: '新增多方块机器'),
  HomeStat(value: '200+', label: '全流程耗时'),
  HomeStat(value: 'v1.4.1b - 260312', label: '最新版本'),
];

const aboutUsEyebrow = 'About';
const aboutUsTitle = '关于我们';
const aboutUsDescription = '团队介绍';

const homeCoreMembers = [
  HomeTeamMember(
    name: 'TonyCrane',
    role: '整合包维护、版本发布与核心改动统筹',
    contactUrl: 'https://github.com/TonyCrane',
    avatarLabel: 'TC',
    avatarColor: Color(0xFFCAD9C4),
  ),
  HomeTeamMember(
    name: 'Wiki Editor',
    role: 'Wiki 结构规划、资料整理与版本记录维护',
    contactUrl: 'https://github.com/',
    avatarLabel: 'WE',
    avatarColor: Color(0xFFD6CCE9),
  ),
  HomeTeamMember(
    name: 'Community Ops',
    role: '社区反馈收集、问题归档与教程需求整理',
    contactUrl: 'https://qm.qq.com/',
    avatarLabel: 'CO',
    avatarColor: Color(0xFFE6D0A8),
  ),
];
