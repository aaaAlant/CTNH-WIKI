import 'package:flutter/material.dart';

void main() {
  runApp(const CtnhWikiApp());
}

class CtnhWikiApp extends StatelessWidget {
  const CtnhWikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF4F0E8);
    const surface = Color(0xFFFFFBF4);
    const ink = Color(0xFF201A16);
    const brass = Color(0xFFC88A3D);
    const moss = Color(0xFF425C45);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CTNH Wiki',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: moss,
          secondary: brass,
          surface: surface,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w800,
            height: 0.95,
            color: ink,
            letterSpacing: -1.8,
          ),
          displayMedium: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            height: 1,
            color: ink,
            letterSpacing: -1.1,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF4C433D),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF5F554D),
          ),
        ),
      ),
      home: const WikiHomePage(),
    );
  }
}

class WikiHomePage extends StatelessWidget {
  const WikiHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _BackgroundTexture()),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 20 : 32,
                      vertical: isCompact ? 18 : 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(isCompact: isCompact),
                        SizedBox(height: isCompact ? 20 : 30),
                        _HeroSection(isCompact: isCompact),
                        const SizedBox(height: 24),
                        _QuickStats(isCompact: isCompact),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          eyebrow: 'Explore',
                          title: '从核心系统切入，而不是从杂乱词条开始',
                        ),
                        const SizedBox(height: 16),
                        _CategoryGrid(isCompact: isCompact),
                        const SizedBox(height: 24),
                        if (isCompact) ...[
                          _StarterPath(isCompact: true),
                          const SizedBox(height: 24),
                          _UpdatePanel(isCompact: true),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Expanded(flex: 3, child: _StarterPath()),
                              SizedBox(width: 24),
                              Expanded(flex: 2, child: _UpdatePanel()),
                            ],
                          ),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          eyebrow: 'Featured',
                          title: '当前首页应优先承载的重点内容',
                        ),
                        const SizedBox(height: 16),
                        _FeaturedCards(isCompact: isCompact),
                        const SizedBox(height: 24),
                        _Footer(isCompact: isCompact),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final items = ['首页', '整合包概览', '任务线', '模组词条', '版本更新'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 22,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9CCB9)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandLockup(),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: items.map(_NavChip.new).toList(),
                ),
              ],
            )
          : Row(
              children: [
                const _BrandLockup(),
                const Spacer(),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _NavChip(item),
                  ),
                ),
              ],
            ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF201A16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.menu_book_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CTNH WIKI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: Color(0xFF201A16),
              ),
            ),
            Text(
              'Community Tech & Magic Handbook',
              style: TextStyle(fontSize: 11, color: Color(0xFF6E6359)),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2D6C2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2F2924),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          colors: [Color(0xFFF6E6C8), Color(0xFFEAE1D0), Color(0xFFD9E3D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(isCompact: true),
                const SizedBox(height: 20),
                const _SearchPanel(),
              ],
            )
          : const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _HeroCopy()),
                SizedBox(width: 24),
                Expanded(flex: 2, child: _SearchPanel()),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final displayStyle = isCompact
        ? Theme.of(context).textTheme.displayMedium
        : Theme.of(context).textTheme.displayLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x33201A16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Minecraft Modpack Encyclopedia',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF201A16),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('让玩家快速查到\n配方、机制与推进路线', style: displayStyle),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: const Text(
            '首页应像一本整合包操作手册：先告诉玩家该从哪条线开始，再让他们继续深入到机器、魔法、任务和资源体系。',
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _AccentButton(label: '查看开荒指南', filled: true),
            _AccentButton(label: '浏览模组分类'),
          ],
        ),
      ],
    );
  }
}

class _AccentButton extends StatelessWidget {
  const _AccentButton({required this.label, this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: filled
            ? const Color(0xFF201A16)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filled ? const Color(0xFF201A16) : const Color(0xFFD4C8B7),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : const Color(0xFF201A16),
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0D5C3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速检索',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5DCCF)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Color(0xFF6B6157)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '搜索词条、合成表、任务章节、模组名',
                    style: TextStyle(color: Color(0xFF81766B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '推荐入口',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(label: '早期发电'),
              _MiniPill(label: '矿物处理'),
              _MiniPill(label: '任务总览'),
              _MiniPill(label: '常见卡点'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5D8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A413A),
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('08', '推荐起步章节'),
      ('24', '关键系统词条'),
      ('120+', '待扩展页面位'),
      ('v0.1', '当前框架版本'),
    ];

    if (isCompact) {
      return Column(
        children: stats
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StatCard(value: item.$1, label: item.$2),
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: stats
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: item == stats.last ? 0 : 14),
                child: _StatCard(value: item.$1, label: item.$2),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D7C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: Color(0xFF8A6A37),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        '开荒与生存',
        '前 3 小时要做什么、初期资源怎么拿、第一套工具如何过渡',
        Icons.terrain_rounded,
        Color(0xFFE6D0A8),
      ),
      (
        '科技主线',
        '发电、机器、多方块结构、物流与自动化推进',
        Icons.precision_manufacturing_rounded,
        Color(0xFFCAD9C4),
      ),
      (
        '魔法与仪式',
        '法术体系、祭坛结构、材料获取与跨模组联动',
        Icons.auto_fix_high_rounded,
        Color(0xFFD6CCE9),
      ),
      (
        '任务与章节',
        '按照任务书阅读整合包设计者安排的推进节奏',
        Icons.task_alt_rounded,
        Color(0xFFF0D9C7),
      ),
      ('资源与作物', '矿脉、农场、养蜂、自动化采集与材料闭环', Icons.grass_rounded, Color(0xFFD6E4C5)),
      (
        '疑难排错',
        '常见卡关点、配方替换、结构搭建错误与版本差异',
        Icons.build_circle_rounded,
        Color(0xFFE9CFCA),
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items
          .map(
            (item) => SizedBox(
              width: isCompact ? double.infinity : 390,
              child: _CategoryCard(
                title: item.$1,
                description: item.$2,
                icon: item.$3,
                tint: item.$4,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4D9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF201A16)),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          Text(description),
        ],
      ),
    );
  }
}

class _StarterPath extends StatelessWidget {
  const _StarterPath({this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('01', '建立基础资源循环', '解决食物、木材、煤炭和基础矿石来源。'),
      ('02', '完成首个电力节点', '明确最早期发电方式和第一批机器优先级。'),
      ('03', '解锁任务关键分叉', '把科技线与魔法线的前置门槛拆开说明。'),
      ('04', '搭建自动化骨架', '让仓储、物流和材料回收开始闭环。'),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2620),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '建议首页挂载一条清晰的入门路径',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '这部分参考大型游戏百科的“Getting Started”分区，优先解决新玩家不知道先看哪里的痛点。',
            style: TextStyle(color: Color(0xFFD5DED0), height: 1.6),
          ),
          const SizedBox(height: 18),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PathStep(
                index: step.$1,
                title: step.$2,
                description: step.$3,
              ),
            ),
          ),
          if (isCompact) const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _PathStep extends StatelessWidget {
  const _PathStep({
    required this.index,
    required this.title,
    required this.description,
  });

  final String index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A322B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFC88A3D),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              index,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF201A16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Color(0xFFD7E0D2), height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdatePanel extends StatelessWidget {
  const _UpdatePanel({this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    const updates = [
      ('首页框架', '确定 Hero、分类、入门路径、精选词条四层结构。'),
      ('词条模板', '后续可扩展为模组页、物品页、任务页三类模板。'),
      ('搜索系统', '预留搜索入口与热门查询，未来可接本地索引。'),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE4D8C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近更新',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          ...updates.map(
            (update) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EEE4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF201A16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(update.$2),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '适合后续接入 changelog、更新日志或编辑记录。',
            style: TextStyle(color: Color(0xFF72675D)),
          ),
          if (isCompact) const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _FeaturedCards extends StatelessWidget {
  const _FeaturedCards({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('任务书导览', '把任务章节按“生存 / 科技 / 魔法 / 终局”重组，适合新玩家快速理解整合包结构。'),
      ('配方改动总表', '集中收纳魔改配方、替代工艺和核心门槛，降低查资料成本。'),
      ('模组联动关系图', '把能源、物流、材料和魔法的互锁关系可视化，适合做首页亮点内容。'),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items
          .map(
            (item) => SizedBox(
              width: isCompact ? double.infinity : 390,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFE0D5C5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FEATURE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: Color(0xFF8A6A37),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF201A16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(item.$2),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF201A16),
        borderRadius: BorderRadius.circular(28),
      ),
      child: isCompact
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CTNH WIKI',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '下一步建议：拆分成独立页面路由，并接入真实词条数据。',
                  style: TextStyle(color: Color(0xFFD5CDC5), height: 1.6),
                ),
              ],
            )
          : const Row(
              children: [
                Expanded(
                  child: Text(
                    'CTNH WIKI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '下一步建议：补齐路由、词条模板、搜索索引和更新日志，逐步从首页框架扩展成完整百科站。',
                    style: TextStyle(color: Color(0xFFD5CDC5), height: 1.6),
                  ),
                ),
              ],
            ),
    );
  }
}

class _BackgroundTexture extends StatelessWidget {
  const _BackgroundTexture();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F0E8), Color(0xFFEDE6D8), Color(0xFFE3E9DD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -30,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33C88A3D),
              ),
            ),
          ),
          Positioned(
            left: -60,
            top: 260,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22425C45),
              ),
            ),
          ),
          Positioned(
            right: 120,
            bottom: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22FFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
