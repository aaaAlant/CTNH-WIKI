import 'package:flutter/material.dart';

class HomeModuleSection {
  const HomeModuleSection({required this.title, required this.description});

  final String title;
  final String description;
}

class HomeModule {
  const HomeModule({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
    required this.sections,
  });

  final String label;
  final String title;
  final String description;
  final IconData icon;
  final Color tint;
  final List<HomeModuleSection> sections;
}

class HomeHeroData {
  const HomeHeroData({
    required this.badge,
    required this.title,
    required this.description,
    required this.primaryAction,
    required this.secondaryAction,
  });

  final String badge;
  final String title;
  final String description;
  final String primaryAction;
  final String secondaryAction;
}

class HomeStat {
  const HomeStat({required this.value, required this.label});

  final String value;
  final String label;
}
