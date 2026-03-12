import 'package:ctnh_wiki/home_modules_data.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CtnhWikiApp());
}

class CtnhWikiApp extends StatelessWidget {
  const CtnhWikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CTNH Wiki',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F0E8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF425C45),
          secondary: Color(0xFFC88A3D),
          surface: Color(0xFFFFFBF4),
        ),
      ),
      home: const WikiHomePage(),
    );
  }
}

class WikiHomePage extends StatefulWidget {
  const WikiHomePage({super.key});

  @override
  State<WikiHomePage> createState() => _WikiHomePageState();
}

class _WikiHomePageState extends State<WikiHomePage> {
  static const _tabs = ['首页', '任务概览', '图鉴', '版本列表'];

  int _selectedIndex = 0;

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
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 32,
                vertical: isCompact ? 18 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        isCompact: isCompact,
                        items: _tabs,
                        selectedIndex: _selectedIndex,
                        onSelected: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                      SizedBox(height: isCompact ? 20 : 30),
                      IndexedStack(
                        index: _selectedIndex,
                        children: const [
                          _HomeTab(),
                          _EmptyTab(title: '任务概览'),
                          _EmptyTab(title: '图鉴'),
                          _EmptyTab(title: '版本列表'),
                        ],
                      ),
                    ],
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
  const _TopBar({
    required this.isCompact,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final bool isCompact;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = List.generate(
      items.length,
      (index) => _NavChip(
        label: items[index],
        selected: index == selectedIndex,
        onTap: () => onSelected(index),
      ),
    );

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
                Wrap(spacing: 10, runSpacing: 10, children: chips),
              ],
            )
          : Row(
              children: [
                const _BrandLockup(),
                const Spacer(),
                ...chips.map(
                  (chip) => Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: chip,
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
  const _NavChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF201A16) : const Color(0xFFF7F1E7),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFF201A16)
                  : const Color(0xFFE2D6C2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF2F2924),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _selectedModuleIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroSection(isCompact: isCompact),
        const SizedBox(height: 24),
        _QuickStats(isCompact: isCompact),
        const SizedBox(height: 24),
        const _SectionTitle(
          eyebrow: 'Explore',
          title: '从科技、魔法与冒险三条主轴切入首页内容',
        ),
        const SizedBox(height: 16),
        _ModuleSwitcher(
          isCompact: isCompact,
          selectedIndex: _selectedModuleIndex,
          onSelected: (index) {
            setState(() {
              _selectedModuleIndex = index;
            });
          },
        ),
      ],
    );
  }
}

class _ModuleSwitcher extends StatelessWidget {
  const _ModuleSwitcher({
    required this.isCompact,
    required this.selectedIndex,
    required this.onSelected,
  });

  final bool isCompact;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final module = homeModules[selectedIndex];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE4D9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isCompact
              ? Column(
                  children: List.generate(
                    homeModules.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index == homeModules.length - 1 ? 0 : 12,
                      ),
                      child: _ModulePreviewCard(
                        module: homeModules[index],
                        selected: index == selectedIndex,
                        onTap: () => onSelected(index),
                      ),
                    ),
                  ),
                )
              : Row(
                  children: List.generate(
                    homeModules.length,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == homeModules.length - 1 ? 0 : 16,
                        ),
                        child: _ModulePreviewCard(
                          module: homeModules[index],
                          selected: index == selectedIndex,
                          onTap: () => onSelected(index),
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? 20 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF6),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFE8DDCC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: module.tint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(module.icon, color: const Color(0xFF201A16)),
                ),
                const SizedBox(height: 18),
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF201A16),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  module.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Color(0xFF5F554D),
                  ),
                ),
                const SizedBox(height: 22),
                isCompact
                    ? Column(
                        children: module.sections
                            .map(
                              (section) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ModuleSectionCard(section: section),
                              ),
                            )
                            .toList(),
                      )
                    : Row(
                        children: module.sections
                            .map(
                              (section) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: section == module.sections.last ? 0 : 14,
                                  ),
                                  child: _ModuleSectionCard(section: section),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModulePreviewCard extends StatelessWidget {
  const _ModulePreviewCard({
    required this.module,
    required this.selected,
    required this.onTap,
  });

  final HomeModule module;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFFCF6)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? const Color(0xFF201A16)
                  : const Color(0xFFE4D9C8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: module.tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(module.icon, color: const Color(0xFF201A16)),
              ),
              const SizedBox(height: 18),
              Text(
                module.title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF201A16),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                module.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF5F554D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleSectionCard extends StatelessWidget {
  const _ModuleSectionCard({required this.section});

  final HomeModuleSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.description,
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

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 420),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE0D5C3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '该板块暂时为空页面。',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5F554D),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final heroCopy = Column(
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
        Text(
          '让玩家快速查到\n配方、机制与推进路线',
          style: TextStyle(
            fontSize: isCompact ? 42 : 60,
            fontWeight: FontWeight.w800,
            height: isCompact ? 1.0 : 0.95,
            letterSpacing: isCompact ? -1.1 : -1.8,
            color: const Color(0xFF201A16),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560),
          child: Text(
            '首页保留当前 main.dart 的主体展示内容，作为站点入口页。新增的科技、魔法、冒险模块会在首页内部切换展示。',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF4C433D),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AccentButton(label: '查看开荒指南', filled: true),
            _AccentButton(label: '浏览模块分类'),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
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
      child: heroCopy,
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF201A16),
          ),
        ),
      ],
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
