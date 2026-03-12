import 'package:flutter/material.dart';

class BackgroundTexture extends StatelessWidget {
  const BackgroundTexture({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F0E8), Color(0xFFEDE6D8), Color(0xFFE3E9DD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -30,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33C88A3D),
              ),
            ),
          ),
          Positioned(
            left: -60,
            top: 260,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22425C45),
              ),
            ),
          ),
          Positioned(
            right: 120,
            bottom: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22FFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
