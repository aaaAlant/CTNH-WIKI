import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:ctnh_wiki/features/guides/data/guide_markdown_repository.dart';
import 'package:ctnh_wiki/features/guides/data/guides_tutorial_data.dart';
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

  late final Future<List<GuideMarkdownDocument>> _documentsFuture;
  String? _selectedSlug;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _repository.loadDocuments();
  }

  void _selectDocument(GuideMarkdownDocument document) {
    setState(() {
      _selectedSlug = document.slug;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);
    final isCompact = responsive.width < 980;

    return FutureBuilder<List<GuideMarkdownDocument>>(
      future: _documentsFuture,
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

        final documents = snapshot.data ?? const <GuideMarkdownDocument>[];
        if (documents.isEmpty) {
          return const ContentPanel(
            minHeight: 320,
            child: _GuidesStateMessage(
              title: '还没有教程文档',
              description: '把 .md 文件放进 assets/docs/guides/ 后，这里会自动显示。',
            ),
          );
        }

        final selected = documents.firstWhere(
          (doc) => doc.slug == _selectedSlug,
          orElse: () => documents.first,
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
            ContentPanel(
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GuideDocumentList(
                          documents: documents,
                          selectedSlug: selected.slug,
                          onSelected: _selectDocument,
                          compact: true,
                        ),
                        const SizedBox(height: 18),
                        _GuideMarkdownViewer(document: selected),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 280,
                          child: _GuideDocumentList(
                            documents: documents,
                            selectedSlug: selected.slug,
                            onSelected: _selectDocument,
                            compact: false,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _GuideMarkdownViewer(document: selected),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
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
        '文档目录：assets/docs/guides/  |  运行时会自动发现该目录中的 .md 文件',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: WikiPalette.inkSoft,
        ),
      ),
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

class _GuideDocumentList extends StatelessWidget {
  const _GuideDocumentList({
    required this.documents,
    required this.selectedSlug,
    required this.onSelected,
    required this.compact,
  });

  final List<GuideMarkdownDocument> documents;
  final String selectedSlug;
  final ValueChanged<GuideMarkdownDocument> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
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

    return Container(
      decoration: WikiDecorations.slot(
        color: WikiPalette.parchmentLight,
        radiusValue: 10,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '文档目录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: WikiPalette.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '按文件名与 front matter 的 order 自动排序。',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: WikiPalette.inkSoft,
            ),
          ),
          const SizedBox(height: 14),
          ...documents.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GuideDocCard(
                document: document,
                selected: document.slug == selectedSlug,
                onTap: () => onSelected(document),
              ),
            ),
          ),
        ],
      ),
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

class _GuideDocCard extends StatelessWidget {
  const _GuideDocCard({
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: selected
            ? WikiDecorations.darkFrame(radiusValue: 8)
            : WikiDecorations.slot(
                color: WikiPalette.parchment,
                radiusValue: 8,
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: selected ? WikiPalette.lineLight : WikiPalette.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              document.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: selected
                    ? WikiPalette.lineLight.withValues(alpha: 0.88)
                    : WikiPalette.inkSoft,
              ),
            ),
          ],
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
            const SizedBox(height: 6),
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
