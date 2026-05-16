import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:ctnh_wiki/features/guides/data/guide_markdown_repository.dart';
import 'package:ctnh_wiki/features/guides/data/guides_tutorial_data.dart';
import 'package:ctnh_wiki/features/guides/models/guide_markdown_catalog.dart';
import 'package:ctnh_wiki/features/guides/models/guide_markdown_document.dart';
import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidesTutorialTab extends StatefulWidget {
  const GuidesTutorialTab({super.key});

  @override
  State<GuidesTutorialTab> createState() => _GuidesTutorialTabState();
}

class _GuidesTutorialTabState extends State<GuidesTutorialTab> {
  static const _repository = GuideMarkdownRepository();

  late final Future<GuideMarkdownCatalog> _catalogFuture;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedSlug;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _catalogFuture = _repository.loadCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectDocument(GuideMarkdownDocument document) {
    setState(() {
      _selectedSlug = document.slug;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return FutureBuilder<GuideMarkdownCatalog>(
      future: _catalogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ContentPanel(
            minHeight: 420,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return ContentPanel(
            minHeight: 320,
            child: _GuidesStateMessage(
              title: '文档加载失败',
              description: '${snapshot.error}',
            ),
          );
        }

        final catalog = snapshot.data;
        if (catalog == null || catalog.documents.isEmpty) {
          return const ContentPanel(
            minHeight: 320,
            child: _GuidesStateMessage(
              title: '还没有攻略教程',
              description:
                  '先把 Markdown 文件放进 assets/docs/guides/，再在 assets/docs/guides/index.json 里注册，页面就会自动显示。',
            ),
          );
        }

        final filteredDocuments = _filterDocuments(catalog.documents);
        final selected = filteredDocuments.isEmpty
            ? null
            : filteredDocuments.firstWhere(
                (doc) => doc.slug == _selectedSlug,
                orElse: () => filteredDocuments.first,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(eyebrow: 'Guides', title: guidesTutorialTitle),
            const SizedBox(height: 12),
            const Text(
              guidesTutorialDescription,
              style: TextStyle(
                fontSize: 16,
                color: WikiPalette.inkSoft,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            const _GuideFolderHint(),
            SizedBox(height: responsive.pageSectionGap),
            _GuideFilters(
              tags: catalog.allTags,
              selectedTag: _selectedTag,
              searchController: _searchController,
              onSearchChanged: (_) => setState(() {}),
              onTagChanged: (tag) {
                setState(() {
                  _selectedTag = tag;
                });
              },
            ),
            SizedBox(height: responsive.isCompact ? 16 : 20),
            if (filteredDocuments.isEmpty)
              const ContentPanel(
                child: _GuidesStateMessage(
                  title: '没有匹配的教程',
                  description: '试试清空搜索词，或者切换标签筛选条件。',
                ),
              )
            else ...[
              _GuideCandidateFlow(
                documents: filteredDocuments,
                selectedSlug: selected!.slug,
                onSelected: _selectDocument,
              ),
              SizedBox(height: responsive.isCompact ? 16 : 20),
              ContentPanel(child: _GuideMarkdownViewer(document: selected)),
            ],
          ],
        );
      },
    );
  }

  List<GuideMarkdownDocument> _filterDocuments(
    List<GuideMarkdownDocument> documents,
  ) {
    final query = _searchController.text.trim().toLowerCase();

    return documents.where((document) {
      final matchesTag =
          _selectedTag == null || document.tags.contains(_selectedTag);
      final matchesQuery =
          query.isEmpty || document.title.toLowerCase().contains(query);

      return matchesTag && matchesQuery;
    }).toList();
  }
}

class _GuideFolderHint extends StatelessWidget {
  const _GuideFolderHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: WikiDecorations.slot(
        color: WikiPalette.parchmentLight,
        radiusValue: 8,
      ),
      child: const Text(
        '注册表：assets/docs/guides/index.json  |  正文目录：assets/docs/guides/  |  只有在注册表中登记过的 .md 文档才会显示',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: WikiPalette.inkSoft,
        ),
      ),
    );
  }
}

class _GuideFilters extends StatelessWidget {
  const _GuideFilters({
    required this.tags,
    required this.selectedTag,
    required this.searchController,
    required this.onSearchChanged,
    required this.onTagChanged,
  });

  final List<String> tags;
  final String? selectedTag;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTagChanged;

  @override
  Widget build(BuildContext context) {
    return ContentPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: '搜索教程标题',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: WikiPalette.parchmentLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: WikiPalette.purpleMuted,
                  width: 1.6,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: WikiPalette.steel,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '标签筛选',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: WikiPalette.ink,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FilterChipButton(
                label: '全部标签',
                selected: selectedTag == null,
                onTap: () => onTagChanged(null),
              ),
              ...tags.map(
                (tag) => _FilterChipButton(
                  label: tag,
                  selected: selectedTag == tag,
                  onTap: () => onTagChanged(tag),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: selected
            ? WikiDecorations.darkFrame(radiusValue: 999)
            : WikiDecorations.slot(
                color: WikiPalette.parchmentLight,
                radiusValue: 999,
              ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? WikiPalette.lineLight : WikiPalette.ink,
          ),
        ),
      ),
    );
  }
}

class _GuideCandidateFlow extends StatelessWidget {
  const _GuideCandidateFlow({
    required this.documents,
    required this.selectedSlug,
    required this.onSelected,
  });

  final List<GuideMarkdownDocument> documents;
  final String selectedSlug;
  final ValueChanged<GuideMarkdownDocument> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: documents
          .map(
            (document) => _GuideDocChip(
              document: document,
              selected: document.slug == selectedSlug,
              onTap: () => onSelected(document),
            ),
          )
          .toList(),
    );
  }
}

class _GuidesStateMessage extends StatelessWidget {
  const _GuidesStateMessage({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: WikiPalette.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.7,
            color: WikiPalette.inkSoft,
          ),
        ),
      ],
    );
  }
}

class _GuideDocChip extends StatelessWidget {
  const _GuideDocChip({
    required this.document,
    required this.selected,
    required this.onTap,
  });

  final GuideMarkdownDocument document;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: selected
            ? WikiDecorations.darkFrame(radiusValue: 999)
            : WikiDecorations.slot(
                color: WikiPalette.parchmentLight,
                radiusValue: 999,
              ),
        child: Text(
          document.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? WikiPalette.lineLight : WikiPalette.ink,
          ),
        ),
      ),
    );
  }
}

class _GuideMarkdownViewer extends StatelessWidget {
  const _GuideMarkdownViewer({required this.document});

  final GuideMarkdownDocument document;

  Future<void> _openLink(String text, String? href, String title) async {
    if (href == null || href.isEmpty) {
      return;
    }
    await launchUrl(Uri.parse(href), webOnlyWindowName: '_blank');
  }

  Widget _buildImage(Uri uri, String? title, String? alt) {
    final source = uri.toString();
    final image = source.startsWith('http://') || source.startsWith('https://')
        ? Image.network(source, fit: BoxFit.contain)
        : Image.asset(source, fit: BoxFit.contain);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: const Color(0xFFF4E7D3),
          padding: const EdgeInsets.all(10),
          child: image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markdownTheme = MarkdownStyleSheet.fromTheme(Theme.of(context))
        .copyWith(
          p: const TextStyle(
            fontSize: 15,
            height: 1.8,
            color: WikiPalette.inkSoft,
          ),
          h1: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: WikiPalette.ink,
          ),
          h2: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: WikiPalette.ink,
          ),
          h3: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: WikiPalette.ink,
          ),
          blockquoteDecoration: WikiDecorations.slot(
            color: const Color(0xFFE8D8C0),
            radiusValue: 8,
          ),
          blockquotePadding: const EdgeInsets.all(14),
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: WikiPalette.mechanicalBlack,
          ),
          codeblockDecoration: WikiDecorations.slot(
            color: const Color(0xFFE6D7C3),
            radiusValue: 8,
          ),
          tableBorder: TableBorder.all(
            color: WikiPalette.purpleMuted,
            width: 1.5,
          ),
          tableHead: const TextStyle(
            fontWeight: FontWeight.w900,
            color: WikiPalette.ink,
          ),
          tableBody: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: WikiPalette.inkSoft,
          ),
          listBullet: const TextStyle(fontSize: 15, color: WikiPalette.ink),
          a: const TextStyle(
            color: Color(0xFF1E6BB8),
            decoration: TextDecoration.underline,
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: WikiPalette.purpleMuted.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
        );

    return Container(
      width: double.infinity,
      decoration: WikiDecorations.slot(
        color: WikiPalette.parchmentLight,
        radiusValue: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: WikiPalette.ink,
              ),
            ),
            if (document.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: document.tags
                    .map((tag) => _ViewerMetaChip(label: tag))
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              document.assetPath,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF887967),
              ),
            ),
            const SizedBox(height: 18),
            MarkdownBody(
              data: document.markdownBody,
              selectable: !kIsWeb,
              styleSheet: markdownTheme,
              imageBuilder: _buildImage,
              onTapLink: _openLink,
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerMetaChip extends StatelessWidget {
  const _ViewerMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: WikiDecorations.slot(
        color: WikiPalette.parchment,
        radiusValue: 999,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: WikiPalette.inkSoft,
        ),
      ),
    );
  }
}
