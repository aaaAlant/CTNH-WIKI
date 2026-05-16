import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: WikiDecorations.slot(
            color: WikiPalette.slot,
            radiusValue: 8,
          ),
          child: Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: WikiPalette.ink,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.sectionTitleSize,
            fontWeight: FontWeight.w900,
            color: WikiPalette.ink,
            height: 1.1,
            shadows: const [
              Shadow(offset: Offset(1, 1), color: Color(0x44FFF4D7)),
            ],
          ),
        ),
      ],
    );
  }
}
