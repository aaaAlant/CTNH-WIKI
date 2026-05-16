import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:ctnh_wiki/features/guides/data/wiki_content_data.dart';
import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';

class FormalWikiSections extends StatelessWidget {
  const FormalWikiSections({
    super.key,
    this.includePageTitle = true,
    this.showModulePanelsAsContentPanels = true,
  });

  final bool includePageTitle;
  final bool showModulePanelsAsContentPanels;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (includePageTitle) ...[
          const SectionTitle(eyebrow: 'Guides', title: wikiGuidesTitle),
          const SizedBox(height: 12),
          const Text(
            wikiGuidesDescription,
            style: TextStyle(
              fontSize: 16,
              color: WikiPalette.inkSoft,
              height: 1.7,
            ),
          ),
          SizedBox(height: responsive.pageSectionGap),
        ],
        ...wikiModuleSections.map(
          (module) => Padding(
            padding: EdgeInsets.only(bottom: responsive.pageSectionGap),
            child: FormalWikiModulePanel(
              module: module,
              responsive: responsive,
              wrapWithContentPanel: showModulePanelsAsContentPanels,
            ),
          ),
        ),
      ],
    );
  }
}

class FormalWikiModulePanel extends StatelessWidget {
  const FormalWikiModulePanel({
    super.key,
    required this.module,
    required this.responsive,
    required this.wrapWithContentPanel,
  });

  final WikiModuleSectionData module;
  final ResponsiveLayout responsive;
  final bool wrapWithContentPanel;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.isCompact ? 18 : 22),
          decoration: WikiDecorations.slot(
            color: Color.alphaBlend(
              module.accent.withValues(alpha: 0.10),
              WikiPalette.parchmentLight,
            ),
            radiusValue: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                module.title,
                style: TextStyle(
                  fontSize: responsive.isCompact ? 24 : 28,
                  fontWeight: FontWeight.w900,
                  color: WikiPalette.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                module.summary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: WikiPalette.inkSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...module.topics.map(
          (topic) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _WikiTopicCard(topic: topic, accent: module.accent),
          ),
        ),
      ],
    );

    if (wrapWithContentPanel) {
      return ContentPanel(child: body);
    }

    return body;
  }
}

class _WikiTopicCard extends StatelessWidget {
  const _WikiTopicCard({required this.topic, required this.accent});

  final WikiTopicSectionData topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: WikiDecorations.slot(
        color: WikiPalette.parchmentLight,
        radiusValue: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: WikiPalette.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topic.paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  color: WikiPalette.inkSoft,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...topic.groups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _WikiFigureGroup(group: group),
            ),
          ),
        ],
      ),
    );
  }
}

class _WikiFigureGroup extends StatelessWidget {
  const _WikiFigureGroup({required this.group});

  final WikiFigureGroupData group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: WikiPalette.ink,
          ),
        ),
        if (group.description case final description?) ...[
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: WikiPalette.inkSoft,
            ),
          ),
        ],
        const SizedBox(height: 14),
        _AdaptiveFigureWrap(figures: group.figures),
      ],
    );
  }
}

class _AdaptiveFigureWrap extends StatelessWidget {
  const _AdaptiveFigureWrap({required this.figures});

  final List<WikiFigureData> figures;

  double _itemWidth(double maxWidth) {
    final count = figures.length;
    if (maxWidth < 640 || count == 1) {
      return maxWidth;
    }
    if (maxWidth < 980) {
      return (maxWidth - 14) / 2;
    }
    if (count >= 5) {
      return (maxWidth - 28) / 3;
    }
    if (count == 4) {
      return (maxWidth - 14) / 2;
    }
    return (maxWidth - 28) / 3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final itemWidth = _itemWidth(maxWidth);

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: figures
              .map(
                (figure) => SizedBox(
                  width: itemWidth,
                  child: _FigureCard(figure: figure),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _FigureCard extends StatelessWidget {
  const _FigureCard({required this.figure});

  final WikiFigureData figure;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: WikiDecorations.frame(
        color: WikiPalette.parchment,
        radiusValue: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: const Color(0xFFF2E4D0),
                child: Image.asset(
                  figure.assetPath,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              figure.caption,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: WikiPalette.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
