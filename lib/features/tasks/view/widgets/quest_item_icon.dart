import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QuestItemIcon extends StatelessWidget {
  const QuestItemIcon({
    super.key,
    required this.size,
    this.assetPath,
    this.fallbackIcon = Icons.inventory_2_rounded,
    this.framed = true,
    this.backgroundColor = const Color(0xFFE9D8BC),
    this.iconColor = const Color(0xFF6B4F2D),
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(6),
  });

  final double size;
  final String? assetPath;
  final IconData fallbackIcon;
  final bool framed;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final content = assetPath != null && assetPath!.isNotEmpty
        ? Padding(
            padding: padding,
            child: _buildImage(),
          )
        : Icon(
            fallbackIcon,
            size: size * 0.52,
            color: iconColor,
          );

    if (!framed) {
      return SizedBox(width: size, height: size, child: Center(child: content));
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(child: content),
    );
  }

  Widget _buildImage() {
    final fallback = Icon(
      fallbackIcon,
      size: size * 0.52,
      color: iconColor,
    );

    if (kIsWeb) {
      return Image.network(
        assetPath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Image.asset(
      assetPath!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
