import 'package:ctnh_wiki/app/responsive.dart';
import 'package:ctnh_wiki/app/wiki_visuals.dart';
import 'package:ctnh_wiki/features/shared/widgets/brass_gear_overlay.dart';
import 'package:flutter/material.dart';

class ContentPanel extends StatelessWidget {
  const ContentPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.minHeight,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveLayout.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      decoration: WikiDecorations.frame(radiusValue: responsive.panelRadius),
      child: Stack(
        children: [
          const Positioned.fill(child: BrassGearOverlay(opacity: 0.12)),
          Padding(
            padding: padding == const EdgeInsets.all(28)
                ? EdgeInsets.all(responsive.panelPadding)
                : padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
