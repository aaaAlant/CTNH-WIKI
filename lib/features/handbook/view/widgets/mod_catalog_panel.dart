import 'package:ctnh_wiki/features/handbook/data/mod_catalog_repository.dart';
import 'package:ctnh_wiki/features/handbook/models/mod_catalog_entry.dart';
import 'package:flutter/material.dart';

class ModCatalogPanel extends StatefulWidget {
  const ModCatalogPanel({super.key, this.framed = true});

  final bool framed;

  @override
  State<ModCatalogPanel> createState() => _ModCatalogPanelState();
}

class _ModCatalogPanelState extends State<ModCatalogPanel> {
  static const _repository = ModCatalogRepository();

  late final Future<ModCatalogDocument> _catalogFuture;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _catalogFuture = _repository.loadCatalog();
    _searchController.addListener(_handleQueryChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _handleQueryChanged() {
    final nextQuery = _searchController.text;
    if (_query == nextQuery) {
      return;
    }

    setState(() {
      _query = nextQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return Container(
      width: double.infinity,
      padding: widget.framed ? const EdgeInsets.all(22) : EdgeInsets.zero,
      decoration: widget.framed
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5D9C8)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ModCatalogHeader(),
                    const SizedBox(height: 18),
                    _SearchField(controller: _searchController),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _ModCatalogHeader()),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 320,
                      child: _SearchField(controller: _searchController),
                    ),
                  ],
                ),
          const SizedBox(height: 18),
          FutureBuilder<ModCatalogDocument>(
            future: _catalogFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 420,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(message: snapshot.error.toString());
              }

              final catalog = snapshot.data;
              if (catalog == null) {
                return const _ErrorState(message: '没有读取到 Mod 数据。');
              }

              final filteredEntries = catalog.mods
                  .where((entry) => entry.matches(_query))
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatChip(label: '总数 ${catalog.mods.length}'),
                      _StatChip(label: '当前显示 ${filteredEntries.length}'),
                      _StatChip(
                        label: '分类 ${catalog.summaryCounts.length}',
                        tone: const Color(0xFFE8F0E3),
                        textColor: const Color(0xFF476038),
                      ),
                      _StatChip(
                        label: '来源 ${catalog.source}',
                        tone: const Color(0xFFE9F0F6),
                        textColor: const Color(0xFF3F5871),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '这里展示当前整合包已收录的 Mod 及基础说明。页面会直接读取 JSON 数据中的分类、标签、描述和文件名等字段。',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.65,
                      color: Color(0xFF6A6058),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _buildSummaryChips(catalog.summaryCounts),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: isCompact ? 520 : 620,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE7DCCB)),
                    ),
                    child: filteredEntries.isEmpty
                        ? const _EmptyState()
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredEntries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _ModEntryCard(
                                  entry: filteredEntries[index],
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSummaryChips(Map<String, int> summaryCounts) {
    final sortedEntries = summaryCounts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));

    return sortedEntries.take(6).map((entry) {
      return _StatChip(
        label: '${entry.key} ${entry.value}',
        tone: const Color(0xFFF3E8D8),
      );
    }).toList();
  }
}

class _ModCatalogHeader extends StatelessWidget {
  const _ModCatalogHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOD 列表',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF201A16),
          ),
        ),
        SizedBox(height: 10),
        Text(
          '这里集中展示整合包中的 Mod、基础分类、标签以及补充说明，方便后续继续扩展成更完整的图鉴入口。',
          style: TextStyle(
            fontSize: 14,
            height: 1.65,
            color: Color(0xFF5F554D),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: '搜索名称、分类、标签、加载器或文件名',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2D6C3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2D6C3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF9A6F37)),
        ),
      ),
    );
  }
}

class _ModEntryCard extends StatelessWidget {
  const _ModEntryCard({required this.entry});

  final ModCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF201A16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.primaryCategory,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8A6A37),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _LoaderBadge(loader: entry.loader),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(label: entry.modId),
              if (entry.gameVersion != null)
                _MetaChip(label: 'MC ${entry.gameVersion}'),
              if (entry.modVersion != null)
                _MetaChip(label: '版本 ${entry.modVersion}'),
              ...entry.subcategories
                  .take(3)
                  .map((subcategory) => _MetaChip(label: subcategory)),
            ],
          ),
          if (entry.description != null) ...[
            const SizedBox(height: 12),
            Text(
              entry.description!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF4E443D),
              ),
            ),
          ],
          if (entry.note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '备注：${entry.note}',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF6C5948),
                ),
              ),
            ),
          ],
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.tags
                  .take(8)
                  .map((tag) => _TagChip(label: tag))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            entry.fileName,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF6F655D),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoaderBadge extends StatelessWidget {
  const _LoaderBadge({required this.loader});

  final String loader;

  @override
  Widget build(BuildContext context) {
    final color = switch (loader) {
      'NeoForge' => const Color(0xFFDFF0E8),
      'Forge' => const Color(0xFFF4E5D3),
      'Fabric' => const Color(0xFFE1EDF9),
      'Quilt' => const Color(0xFFEDE7FB),
      'Universal' => const Color(0xFFE7F1DF),
      _ => const Color(0xFFEFE7DC),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        loader,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4B433C),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBDD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B4F2D),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF525A61),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    this.tone = const Color(0xFFF1E7D8),
    this.textColor = const Color(0xFF6A5030),
  });

  final String label;
  final Color tone;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '没有匹配结果，可以换个关键词再试。',
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF6F655D)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2D3C6)),
      ),
      child: Text(
        'MOD 列表加载失败：$message',
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFF8B4D3E),
        ),
      ),
    );
  }
}
