import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/web_cursor.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:ctnh_wiki/features/home/data/home_page_data.dart';
import 'package:ctnh_wiki/features/home/models/home_module.dart';
import 'package:ctnh_wiki/features/home/view/modules/logistics_module_page.dart';
import 'package:ctnh_wiki/features/home/view/modules/magic_module_page.dart';
import 'package:ctnh_wiki/features/home/view/modules/tech_module_page.dart';
import 'package:ctnh_wiki/features/shared/widgets/brass_gear_overlay.dart';
import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:ctnh_wiki/features/shared/widgets/subsection_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _selectedModuleIndex = 0;

  @override
  void initState() {
    super.initState();
    WebCursorController.setTheme(homeModules.first.cursorTheme);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);
    final isCompact = responsive.isCompact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroSection(responsive: responsive),
        SizedBox(height: responsive.pageSectionGap),
        QuickStats(isCompact: isCompact),
        SizedBox(height: responsive.pageSectionGap),
        const SectionTitle(
          eyebrow: homeExploreEyebrow,
          title: homeExploreTitle,
        ),
        const SizedBox(height: 16),
        ModuleSwitcher(
          isCompact: responsive.width < 920,
          selectedIndex: _selectedModuleIndex,
          onSelected: (index) {
            setState(() {
              _selectedModuleIndex = index;
            });
            WebCursorController.setTheme(homeModules[index].cursorTheme);
          },
        ),
        SizedBox(height: responsive.pageSectionGap),
        SizedBox(height: responsive.pageSectionGap),
        const SectionTitle(eyebrow: aboutUsEyebrow, title: aboutUsTitle),
        const SizedBox(height: 16),
        AboutUsSection(isCompact: isCompact),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.responsive});

  final ResponsiveLayout responsive;

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  ButtonStyle _iconButtonStyle() {
    return IconButton.styleFrom(
      backgroundColor: WikiPalette.parchmentLight,
      side: const BorderSide(color: WikiPalette.purpleMuted, width: 2),
      fixedSize: const Size.square(56),
      minimumSize: const Size.square(56),
      maximumSize: const Size.square(56),
      padding: EdgeInsets.zero,
      iconSize: 28,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = responsive.isCompact;
    final heroFontSize = switch (responsive.tier) {
      ResponsiveTier.compact => 34.0,
      ResponsiveTier.medium => 48.0,
      ResponsiveTier.expanded => 60.0,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 20 : responsive.panelPadding),
      decoration: WikiDecorations.frame(
        color: WikiPalette.parchment,
        radiusValue: responsive.panelRadius,
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: BrassGearOverlay(opacity: 0.1)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                homeHero.title,
                style: TextStyle(
                  fontSize: heroFontSize,
                  fontWeight: FontWeight.w900,
                  height: isCompact ? 1.0 : 0.95,
                  letterSpacing: isCompact ? -0.9 : -1.8,
                  color: WikiPalette.ink,
                  shadows: const [
                    Shadow(offset: Offset(1, 1), color: Color(0x44FFF4D7)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                homeHero.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: WikiPalette.inkSoft,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const AccentButton(label: 'Bug鍙嶉', filled: true),
                  const AccentButton(label: '鍔犲叆鎴戜滑'),
                  IconButton(
                    onPressed: () =>
                        _openUrl('https://www.mcmod.cn/modpack/897.html'),
                    tooltip: 'MC 鐧剧',
                    style: _iconButtonStyle(),
                    icon: SizedBox.square(
                      dimension: 28,
                      child: Center(
                        child: Image.asset(
                          'assets/icons/home/mc-wiki-logo.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _openUrl('https://pd.qq.com/s/pel4yyss?b=5'),
                    tooltip: 'QQ 棰戦亾',
                    style: _iconButtonStyle(),
                    icon: SizedBox.square(
                      dimension: 28,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/home/tencent-qq-logo.svg',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openUrl(
                      'https://github.com/CTNH-Team/Create-New-Horizon',
                    ),
                    tooltip: 'GitHub',
                    style: _iconButtonStyle(),
                    icon: SizedBox.square(
                      dimension: 28,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/home/github-logo.svg',
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openUrl(
                      'https://www.curseforge.com/minecraft/modpacks/ctnh',
                    ),
                    tooltip: 'CurseForge',
                    style: _iconButtonStyle(),
                    icon: SizedBox.square(
                      dimension: 28,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/home/curseforge-logo.svg',
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _openUrl('https://discord.com/invite/jQpvUDsVX8'),
                    tooltip: 'Discord',
                    style: _iconButtonStyle(),
                    icon: SizedBox.square(
                      dimension: 28,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/home/discord-logo.svg',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccentButton extends StatelessWidget {
  const AccentButton({super.key, required this.label, this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        height: 56,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 120),
          child: DecoratedBox(
            decoration: filled
                ? WikiDecorations.darkFrame(radiusValue: 8)
                : WikiDecorations.slot(
                    color: WikiPalette.parchmentLight,
                    radiusValue: 8,
                  ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: filled ? WikiPalette.lineLight : WikiPalette.ink,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickStats extends StatelessWidget {
  const QuickStats({super.key, required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: homeStats
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StatCard(value: item.value, label: item.label),
              ),
            )
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: homeStats
                .map(
                  (item) => SizedBox(
                    width: (constraints.maxWidth - 14) / 2,
                    child: StatCard(value: item.value, label: item.label),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: homeStats
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: item == homeStats.last ? 0 : 14,
                    ),
                    child: StatCard(value: item.value, label: item.label),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: WikiDecorations.slot(
        color: WikiPalette.parchmentLight,
        radiusValue: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: WikiPalette.rustDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: WikiDecorations.slot(
              color: WikiPalette.slot,
              radiusValue: 6,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: WikiPalette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleSwitcher extends StatelessWidget {
  const ModuleSwitcher({
    super.key,
    required this.isCompact,
    required this.selectedIndex,
    required this.onSelected,
  });

  final bool isCompact;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  String? _backgroundAssetForIndex(int index) {
    return switch (index) {
      0 => 'assets/images/home/tech/module_background.png',
      1 => 'assets/images/home/magic/module_background.png',
      2 => 'assets/images/home/adventure/module_background.png',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final modulePage = switch (selectedIndex) {
      0 => const TechModulePage(),
      1 => const MagicModulePage(),
      _ => const LogisticsModulePage(),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 20 : 24),
      decoration: WikiDecorations.frame(
        color: WikiPalette.parchmentDark,
        radiusValue: isCompact ? 10 : 12,
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
                      child: ModulePreviewCard(
                        module: homeModules[index],
                        selected: index == selectedIndex,
                        backgroundAssetPath: _backgroundAssetForIndex(index),
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
                        child: ModulePreviewCard(
                          module: homeModules[index],
                          selected: index == selectedIndex,
                          backgroundAssetPath: _backgroundAssetForIndex(index),
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
            decoration: WikiDecorations.slot(
              color: WikiPalette.parchmentLight,
              radiusValue: 10,
            ),
            child: modulePage,
          ),
        ],
      ),
    );
  }
}

class ModulePreviewCard extends StatelessWidget {
  const ModulePreviewCard({
    super.key,
    required this.module,
    required this.selected,
    this.backgroundAssetPath,
    required this.onTap,
  });

  final HomeModule module;
  final bool selected;
  final String? backgroundAssetPath;
  final VoidCallback onTap;

  List<Color> get _overlayColors {
    if (backgroundAssetPath == null) {
      return const [];
    }

    if (backgroundAssetPath!.contains('/tech/')) {
      return const [Color(0xBF151922), Color(0xA6242A36), Color(0x73262D3A)];
    }

    return const [Color(0xE61A1E28), Color(0xCC252B38), Color(0x99262D3A)];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final minCardHeight = width < 920 ? 176.0 : 208.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: minCardHeight,
          child: Container(
            decoration: selected
                ? WikiDecorations.darkFrame(radiusValue: 10)
                : WikiDecorations.slot(
                    color: WikiPalette.parchmentLight,
                    radiusValue: 10,
                  ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (backgroundAssetPath != null)
                    Positioned.fill(
                      child: Image.asset(
                        backgroundAssetPath!,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  if (backgroundAssetPath != null)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: _overlayColors,
                            stops: const [0.0, 0.44, 1.0],
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.label,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: backgroundAssetPath != null
                                  ? WikiPalette.lineLight
                                  : (selected
                                        ? WikiPalette.lineLight
                                        : WikiPalette.ink),
                              shadows: backgroundAssetPath != null
                                  ? const [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 6,
                                        color: Color(0xAA000000),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            module.subTitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: backgroundAssetPath != null
                                  ? WikiPalette.lineLight.withValues(alpha: 0.9)
                                  : (selected
                                        ? WikiPalette.lineLight.withValues(
                                            alpha: 0.88,
                                          )
                                        : WikiPalette.inkSoft),
                              shadows: backgroundAssetPath != null
                                  ? const [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 6,
                                        color: Color(0x88000000),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AboutUsSection extends StatelessWidget {
  const AboutUsSection({super.key, required this.isCompact});

  final bool isCompact;

  Future<void> _openContact(String url) async {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return ContentPanel(
      padding: EdgeInsets.all(isCompact ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubsectionTitle(eyebrow: 'Team', title: '主要成员'),
          const SizedBox(height: 8),
          const Text(
            '按参与整合包制作的时间顺序展示。当前成员列表仍在持续补充中。',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: WikiPalette.inkSoft,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: homeCoreMembers
                .map(
                  (member) => TeamMemberCard(
                    member: member,
                    onOpenContact: () {
                      if (member.contactUrl.isNotEmpty) {
                        _openContact(member.contactUrl);
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          const SubsectionTitle(eyebrow: 'Thanks', title: '致谢'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: WikiDecorations.slot(
              color: WikiPalette.parchmentLight,
              radiusValue: 10,
            ),
            child: const Text(
              '致谢名单与特别贡献说明会继续拆分整理，后续可以直接在这里补充独立卡片或感谢列表。',
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: WikiPalette.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  const TeamMemberCard({
    super.key,
    required this.member,
    required this.onOpenContact,
  });

  final HomeTeamMember member;
  final VoidCallback onOpenContact;

  Future<void> _openAfd(String url) async {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = member.avatarPath.isNotEmpty;
    final hasContact = member.contactUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: WikiDecorations.slot(
        color: WikiPalette.parchmentLight,
        radiusValue: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: hasContact ? onOpenContact : null,
            borderRadius: BorderRadius.circular(999),
            child: Tooltip(
              message: member.tooltip.isEmpty ? member.name : member.tooltip,
              child: ClipOval(
                child: hasAvatar
                    ? Image.asset(
                        member.avatarPath,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        color: WikiPalette.slot,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: WikiPalette.inkSoft,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: WikiPalette.ink,
                    ),
                  ),
                  if (member.afdUrl != null && member.afdUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: TextButton(
                        onPressed: () => _openAfd(member.afdUrl!),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '支持一下',
                          style: TextStyle(color: WikiPalette.rustDark),
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                member.role,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: WikiPalette.inkSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
