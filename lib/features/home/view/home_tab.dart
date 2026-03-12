import 'package:ctnh_wiki/features/home/data/home_modules_data.dart';
import 'package:ctnh_wiki/features/home/data/home_page_data.dart';
import 'package:ctnh_wiki/features/home/models/home_module.dart';
import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
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
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroSection(isCompact: isCompact),
        const SizedBox(height: 24),
        QuickStats(isCompact: isCompact),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: homeExploreEyebrow,
          title: homeExploreTitle,
        ),
        const SizedBox(height: 16),
        ModuleSwitcher(
          isCompact: isCompact,
          selectedIndex: _selectedModuleIndex,
          onSelected: (index) {
            setState(() {
              _selectedModuleIndex = index;
            });
          },
        ),
        const SizedBox(height: 24),
        AboutUsSection(isCompact: isCompact),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.isCompact});

  final bool isCompact;

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final heroCopy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          homeHero.title,
          style: TextStyle(
            fontSize: isCompact ? 42 : 60,
            fontWeight: FontWeight.w800,
            height: isCompact ? 1.0 : 0.95,
            letterSpacing: isCompact ? -1.1 : -1.8,
            color: const Color(0xFF201A16),
          ),
        ),
        const SizedBox(height: 24),
        Text(
            homeHero.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Color(0xFF4C433D),
            ),
          ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            const AccentButton(label: '交流渠道', filled: true),
            const AccentButton(label: 'Bug反馈'),
            const AccentButton(label: '加入我们'),
            IconButton(
              onPressed: () =>
                  _openUrl('https://www.mcmod.cn/modpack/897.html'),
              tooltip: 'MC百科',
              icon: Image.asset(
                'assets/icons/home/mc-wiki-logo.png',
                width: 30,
              ),
            ),
            IconButton(
              onPressed: () => _openUrl('https://pd.qq.com/s/pel4yyss?b=5'),
              tooltip: 'QQ频道',
              icon: SvgPicture.asset(
                'assets/icons/home/tencent-qq-logo.svg',
                width: 25,
              ),
            ),
            IconButton(
              onPressed: () => _openUrl('https://github.com/CTNH-Team/Create-New-Horizon'),
              tooltip: 'GitHub',
              icon: SvgPicture.asset(
                'assets/icons/home/github-logo.svg',
                width: 30,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _openUrl('https://www.curseforge.com/minecraft/modpacks/ctnh'),
              tooltip: 'CurseForge',
              icon: SvgPicture.asset(
                'assets/icons/home/curseforge-logo.svg',
                width: 30,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _openUrl('https://discord.com/invite/jQpvUDsVX8'),
              tooltip: 'Discord',
              icon: SvgPicture.asset(
                'assets/icons/home/discord-logo.svg',
                width: 30,
              ),
            ),
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

class AccentButton extends StatelessWidget {
  const AccentButton({super.key, required this.label, this.filled = false});

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

  @override
  Widget build(BuildContext context) {
    final module = homeModules[selectedIndex];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 20 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6EBD7), Color(0xFFF2E6D8), Color(0xFFEAE6D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFDCCCB4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
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
              ],
            ),
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
                module.label,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF201A16),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                module.subTitle,
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
          const SectionTitle(eyebrow: aboutUsEyebrow, title: aboutUsTitle),
          const SizedBox(height: 12),
          const Text(
            aboutUsDescription,
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Color(0xFF5F554D),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '主要成员',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: homeCoreMembers
                    .map(
                      (member) => TeamMemberCard(
                        member: member,
                        onOpenContact: () => {
                          member.contactUrl.isNotEmpty ?_openContact(member.contactUrl):null
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '致谢',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 14),
          // LayoutBuilder(
          //   builder: (context, constraints) {
          //     return Wrap(
          //       spacing: 14,
          //       runSpacing: 14,
          //       children: homeCoreMembers
          //           .map(
          //             (member) => TeamMemberCard(
          //               member: member,
          //               onOpenContact: () {
          //                 if (member.contactUrl.isNotEmpty) {
          //                   _openContact(member.contactUrl);
          //                 }
          //               },
          //             ),
          //           )
          //           .toList(),
          //     );
          //   },
          // ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D7C6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: member.contactUrl.isNotEmpty ? onOpenContact : null,
            borderRadius: BorderRadius.circular(999),
            child: Tooltip(
              message: member.tooltip,
              child: ClipOval(
                child: member.avatarPath.isNotEmpty?Image.asset(
                  member.avatarPath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ):Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF201A16),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                member.role,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: Color(0xFF5F554D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
