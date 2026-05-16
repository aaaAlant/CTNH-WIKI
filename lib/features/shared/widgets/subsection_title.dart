import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:flutter/material.dart';

class SubsectionTitle extends StatelessWidget {
  const SubsectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
  });

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: WikiDecorations.slot(
            color: WikiPalette.parchmentDark,
            radiusValue: 8,
          ),
          child: Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: WikiPalette.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.subsectionTitleSize,
            fontWeight: FontWeight.w900,
            color: WikiPalette.ink,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
