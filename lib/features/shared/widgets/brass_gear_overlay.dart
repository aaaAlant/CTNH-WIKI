import 'dart:math' as math;

import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:flutter/material.dart';

class BrassGearOverlay extends StatelessWidget {
  const BrassGearOverlay({
    super.key,
    this.topRight = true,
    this.bottomLeft = true,
    this.opacity = 0.16,
  });

  final bool topRight;
  final bool bottomLeft;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _BrassGearPainter(
            topRight: topRight,
            bottomLeft: bottomLeft,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BrassGearPainter extends CustomPainter {
  const _BrassGearPainter({required this.topRight, required this.bottomLeft});

  final bool topRight;
  final bool bottomLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final gearPaint = Paint()
      ..color = WikiPalette.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final linePaint = Paint()
      ..color = WikiPalette.gold.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    if (topRight) {
      _drawCornerAccent(
        canvas,
        size,
        anchor: Offset(size.width - 34, 34),
        mainRadius: 18,
        secondaryRadius: 11,
        horizontal: -56,
        vertical: 48,
        gearPaint: gearPaint,
        linePaint: linePaint,
      );
    }

    if (bottomLeft) {
      _drawCornerAccent(
        canvas,
        size,
        anchor: Offset(40, size.height - 38),
        mainRadius: 20,
        secondaryRadius: 12,
        horizontal: 54,
        vertical: -42,
        gearPaint: gearPaint,
        linePaint: linePaint,
      );
    }
  }

  void _drawCornerAccent(
    Canvas canvas,
    Size size, {
    required Offset anchor,
    required double mainRadius,
    required double secondaryRadius,
    required double horizontal,
    required double vertical,
    required Paint gearPaint,
    required Paint linePaint,
  }) {
    _drawGear(canvas, anchor, mainRadius, gearPaint);
    _drawGear(
      canvas,
      anchor.translate(horizontal * 0.55, vertical * 0.35),
      secondaryRadius,
      gearPaint,
    );

    canvas.drawLine(
      anchor.translate(horizontal.sign * (mainRadius + 10), 0),
      anchor.translate(horizontal, 0),
      linePaint,
    );
    canvas.drawLine(
      anchor.translate(0, vertical.sign * (mainRadius + 10)),
      anchor.translate(0, vertical),
      linePaint,
    );
  }

  void _drawGear(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const teeth = 8;
    final notchRadius = radius * 0.78;

    for (int i = 0; i < teeth * 2; i++) {
      final angle = (math.pi / teeth) * i;
      final currentRadius = i.isEven ? radius : notchRadius;
      final point = Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(center, radius * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
