import 'package:flutter/material.dart';

class HomeCategory {
  final String slug;
  final String label;
  final IconData icon;

  const HomeCategory({
    required this.slug,
    required this.label,
    required this.icon,
  });
}

const List<HomeCategory> kHomeCategories = [
  HomeCategory(
      slug: 'top_stories',
      label: 'Top Stories',
      icon: Icons.local_fire_department_outlined),
  HomeCategory(slug: 'world', label: 'World', icon: Icons.language_outlined),
  HomeCategory(slug: 'tech', label: 'Tech', icon: Icons.computer_outlined),
  HomeCategory(slug: 'design', label: 'Design', icon: Icons.wb_sunny_outlined),
  HomeCategory(
      slug: 'business', label: 'Business', icon: Icons.bar_chart_outlined),
  HomeCategory(
      slug: 'culture', label: 'Culture', icon: Icons.music_note_outlined),
  HomeCategory(
      slug: 'science', label: 'Science', icon: Icons.science_outlined),
  HomeCategory(slug: 'health', label: 'Health', icon: Icons.favorite_border),
  HomeCategory(slug: 'politics', label: 'Politics', icon: Icons.star_border),
  HomeCategory(
      slug: 'sports',
      label: 'Sports',
      icon: Icons.sports_basketball_outlined),
];
