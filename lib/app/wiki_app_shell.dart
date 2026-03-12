import 'package:ctnh_wiki/data/wiki_tabs_data.dart';
import 'package:ctnh_wiki/features/guides/view/guides_tutorial_tab.dart';
import 'package:ctnh_wiki/features/handbook/view/handbook_tab.dart';
import 'package:ctnh_wiki/features/home/view/home_tab.dart';
import 'package:ctnh_wiki/features/shared/widgets/background_texture.dart';
import 'package:ctnh_wiki/features/tasks/view/tasks_overview_tab.dart';
import 'package:ctnh_wiki/features/versions/view/version_list_tab.dart';
import 'package:flutter/material.dart';

class WikiAppShell extends StatefulWidget {
  const WikiAppShell({super.key});

  @override
  State<WikiAppShell> createState() => _WikiAppShellState();
}

class _WikiAppShellState extends State<WikiAppShell> {
  int _selectedIndex = 0;

  static const _pages = [
    HomeTab(),
    TasksOverviewTab(),
    HandbookTab(),
    GuidesTutorialTab(),
    VersionListTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundTexture()),
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
                        items: wikiTabs,
                        selectedIndex: _selectedIndex,
                        onSelected: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                      SizedBox(height: isCompact ? 20 : 30),
                      IndexedStack(index: _selectedIndex, children: _pages),
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
  final List<WikiTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = List.generate(
      items.length,
      (index) => _NavChip(
        label: items[index].label,
        icon: items[index].icon,
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Image.asset('assets/icons/app/logo-480x300.jpg', width: 42),
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
              'Create : New Horizon',
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
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : const Color(0xFF2F2924),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF2F2924),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
