import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:ctnh_wiki/data/wiki_tabs_data.dart';
import 'package:ctnh_wiki/features/guides/view/guides_tutorial_tab.dart';
import 'package:ctnh_wiki/features/home/view/home_tab.dart';
import 'package:ctnh_wiki/features/shared/widgets/background_texture.dart';
import 'package:flutter/material.dart';

class WikiAppShell extends StatefulWidget {
  const WikiAppShell({super.key});

  @override
  State<WikiAppShell> createState() => _WikiAppShellState();
}

class _WikiAppShellState extends State<WikiAppShell> {
  int _selectedIndex = 0;

  static const _pages = [HomeTab(), GuidesTutorialTab()];

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundTexture()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.pageHorizontalPadding,
                vertical: responsive.pageVerticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        responsive: responsive,
                        items: wikiTabs,
                        selectedIndex: _selectedIndex,
                        onSelected: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                      SizedBox(height: responsive.pageSectionGap),
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
    required this.responsive,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final ResponsiveLayout responsive;
  final List<WikiTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final compactShowLabel = responsive.width >= 330;
    final chips = List.generate(
      items.length,
      (index) => _NavChip(
        label: items[index].label,
        icon: items[index].icon,
        showLabel: compactShowLabel || !responsive.isCompact,
        selected: index == selectedIndex,
        onTap: () => onSelected(index),
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isCompact ? 14 : 22,
        vertical: 14,
      ),
      decoration: WikiDecorations.frame(
        color: WikiPalette.parchmentDark,
        radiusValue: responsive.isCompact ? 12 : 14,
      ),
      child: responsive.isCompact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: _BrandLockup(isCompact: true)),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < chips.length; i++) ...[
                      chips[i],
                      if (i != chips.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                ),
              ],
            )
          : Row(
              children: [
                const _BrandLockup(isCompact: false),
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
  const _BrandLockup({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: WikiDecorations.slot(
            color: WikiPalette.parchmentLight,
            radiusValue: 8,
          ),
          child: Image.asset('assets/icons/app/logo-480x300.jpg', width: 42),
        ),
        const SizedBox(width: 12),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CTNH WIKI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                  color: WikiPalette.ink,
                ),
              ),
              Text(
                'Create : New Horizon',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: WikiPalette.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.label,
    required this.icon,
    required this.showLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool showLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final iconOnly = !showLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 12 : (width < 380 ? 10 : 14),
            vertical: 10,
          ),
          decoration: selected
              ? WikiDecorations.darkFrame(radiusValue: 8)
              : WikiDecorations.slot(
                  color: WikiPalette.parchmentLight,
                  radiusValue: 8,
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? WikiPalette.lineLight : WikiPalette.ink,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: selected ? WikiPalette.lineLight : WikiPalette.ink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
