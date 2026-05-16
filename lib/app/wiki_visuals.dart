import 'package:flutter/material.dart';

class WikiPalette {
  const WikiPalette._();

  static const pageTop = Color(0xFFE1C39A);
  static const pageBottom = Color(0xFFD2A677);
  static const parchment = Color(0xFFDBBF9B);
  static const parchmentLight = Color(0xFFDCC7AB);
  static const parchmentDark = Color(0xFFD0AB80);
  static const slot = Color(0xFFC89A6A);
  static const slotDark = Color(0xFFB18259);
  static const rust = Color(0xFF935B4E);
  static const rustDark = Color(0xFF674342);
  static const purple = Color(0xFF523F55);
  static const purpleMuted = Color(0xFF4C4351);
  static const gold = Color(0xFFC9A15E);
  static const steel = Color(0xFF485365);
  static const mechanicalBlack = Color(0xFF0F1219);
  static const ink = Color(0xFF292822);
  static const inkSoft = Color(0xFF4C433C);
  static const lineLight = Color(0xFFF1DFC4);
  static const lineDark = Color(0xFF755740);
}

class WikiDecorations {
  const WikiDecorations._();

  static BorderRadius radius(double value) => BorderRadius.circular(value);

  static List<BoxShadow> get raisedShadow => const [
    BoxShadow(color: Color(0x553E2E22), offset: Offset(4, 4), blurRadius: 0),
    BoxShadow(color: Color(0x33FFF0D5), offset: Offset(-1, -1), blurRadius: 0),
  ];

  static BoxDecoration frame({
    Color color = WikiPalette.parchment,
    double radiusValue = 12,
    Color borderColor = WikiPalette.purple,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withValues(alpha: 0.12), color),
          color,
          Color.alphaBlend(WikiPalette.rustDark.withValues(alpha: 0.12), color),
        ],
      ),
      borderRadius: radius(radiusValue),
      border: Border.all(color: borderColor, width: 2),
      boxShadow: raisedShadow,
    );
  }

  static BoxDecoration slot({
    Color color = WikiPalette.parchmentLight,
    double radiusValue = 10,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withValues(alpha: 0.10), color),
          color,
          Color.alphaBlend(WikiPalette.slotDark.withValues(alpha: 0.14), color),
        ],
      ),
      borderRadius: radius(radiusValue),
      border: Border.all(color: WikiPalette.purpleMuted, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x443E2E22),
          offset: Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration darkFrame({double radiusValue = 12}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF59606D), WikiPalette.steel, Color(0xFF343846)],
      ),
      borderRadius: radius(radiusValue),
      border: Border.all(color: WikiPalette.mechanicalBlack, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55202020),
          offset: Offset(4, 4),
          blurRadius: 0,
        ),
      ],
    );
  }
}
