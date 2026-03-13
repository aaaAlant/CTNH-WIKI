import 'package:flutter/material.dart';

enum HomeCursorTheme {
  tech,
  magic,
  adventure,
}

class HomeModuleSection {
  const HomeModuleSection({required this.title, required this.description});

  final String title;
  final String description;
}

class HomeModule {
  const HomeModule({
    required this.label,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.cursorTheme,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String title;
  final String subTitle;
  final String description;
  final HomeCursorTheme cursorTheme;
  final IconData icon;
  final Color tint;
}

class HomeHeroData {
  const HomeHeroData({required this.title, required this.description});

  final String title;
  final String description;
}

class HomeStat {
  const HomeStat({required this.value, required this.label});

  final String value;
  final String label;
}

class HomeTeamMember {
  const HomeTeamMember({
    required this.name,
    required this.role,
    required this.tooltip,
    required this.contactUrl,
    required this.avatarPath,
    this.afdUrl,
  });

  final String name;
  final String role;
  final String tooltip;
  final String contactUrl;
  final String? afdUrl;
  final String avatarPath;
}

