import 'package:flutter/material.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';

class BackgroundTexture extends StatelessWidget {
  const BackgroundTexture({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WikiPalette.pageTop,
            WikiPalette.parchment,
            WikiPalette.pageBottom,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            right: 40,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0x33755740), width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 210,
            child: Container(
              width: 220,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0x18FFFFFF),
                border: Border(
                  top: BorderSide(color: Color(0x33755740)),
                  bottom: BorderSide(color: Color(0x22755740)),
                ),
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: 120,
            child: Container(
              width: 260,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0x18FFFFFF),
                border: Border(
                  top: BorderSide(color: Color(0x33755740)),
                  bottom: BorderSide(color: Color(0x22755740)),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _BackgroundLinePainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x15755740)
      ..strokeWidth = 1;
    const spacing = 36.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
