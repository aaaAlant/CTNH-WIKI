import 'package:ctnh_wiki/features/handbook/data/handbook_data.dart';
import 'package:ctnh_wiki/features/shared/widgets/content_panel.dart';
import 'package:ctnh_wiki/features/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';

class HandbookTab extends StatelessWidget {
  const HandbookTab({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return ContentPanel(
      minHeight: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Entries', title: handbookTitle),
          const SizedBox(height: 12),
          const Text(
            handbookDescription,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5F554D),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          isCompact
              ? Column(
                  children: handbookEntries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HandbookEntryCard(entry: entry),
                        ),
                      )
                      .toList(),
                )
              : Row(
                  children: handbookEntries
                      .map(
                        (entry) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: entry == handbookEntries.last ? 0 : 14,
                            ),
                            child: _HandbookEntryCard(entry: entry),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _HandbookEntryCard extends StatelessWidget {
  const _HandbookEntryCard({required this.entry});

  final HandbookEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(entry.icon, color: const Color(0xFF201A16)),
          const SizedBox(height: 14),
          Text(
            entry.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF201A16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entry.description,
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
