import 'package:flutter/material.dart';

enum ResponsiveTier { compact, medium, expanded }

class ResponsiveLayout {
  const ResponsiveLayout._({required this.width, required this.tier});

  factory ResponsiveLayout.fromWidth(double width) {
    if (width < 640) {
      return ResponsiveLayout._(width: width, tier: ResponsiveTier.compact);
    }
    if (width < 1100) {
      return ResponsiveLayout._(width: width, tier: ResponsiveTier.medium);
    }
    return ResponsiveLayout._(width: width, tier: ResponsiveTier.expanded);
  }

  static ResponsiveLayout of(BuildContext context) {
    return ResponsiveLayout.fromWidth(MediaQuery.sizeOf(context).width);
  }

  final double width;
  final ResponsiveTier tier;

  bool get isCompact => tier == ResponsiveTier.compact;
  bool get isMedium => tier == ResponsiveTier.medium;
  bool get isExpanded => tier == ResponsiveTier.expanded;

  double get pageHorizontalPadding => switch (tier) {
    ResponsiveTier.compact => 14,
    ResponsiveTier.medium => 22,
    ResponsiveTier.expanded => 32,
  };

  double get pageVerticalPadding => switch (tier) {
    ResponsiveTier.compact => 14,
    ResponsiveTier.medium => 22,
    ResponsiveTier.expanded => 28,
  };

  double get pageSectionGap => switch (tier) {
    ResponsiveTier.compact => 18,
    ResponsiveTier.medium => 22,
    ResponsiveTier.expanded => 24,
  };

  double get panelPadding => switch (tier) {
    ResponsiveTier.compact => 16,
    ResponsiveTier.medium => 22,
    ResponsiveTier.expanded => 28,
  };

  double get panelRadius => switch (tier) {
    ResponsiveTier.compact => 10,
    ResponsiveTier.medium => 12,
    ResponsiveTier.expanded => 14,
  };

  double get maxContentWidth => switch (tier) {
    ResponsiveTier.compact => 720,
    ResponsiveTier.medium => 1040,
    ResponsiveTier.expanded => 1280,
  };

  double get sectionTitleSize => switch (tier) {
    ResponsiveTier.compact => 24,
    ResponsiveTier.medium => 26,
    ResponsiveTier.expanded => 28,
  };

  double get subsectionTitleSize => switch (tier) {
    ResponsiveTier.compact => 22,
    ResponsiveTier.medium => 24,
    ResponsiveTier.expanded => 26,
  };
}
