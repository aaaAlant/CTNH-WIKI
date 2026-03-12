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
    required this.subTitle,
    required this.description,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String title;
  final String subTitle;
  final String description;
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
    required this.contactUrl,
    required this.avatarLabel,
    required this.avatarColor,
  });

  final String name;
  final String role;
  final String contactUrl;
  final String avatarLabel;
  final Color avatarColor;
}
