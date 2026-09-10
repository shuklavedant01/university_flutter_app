import 'package:flutter/material.dart';

enum CircularCategory {
  actionRequired,
  campusSafety,
  academicCall,
  generalNotice,
}

class UniversityCircular {
  final String id;
  final String title;
  final String snippet;
  final String date;
  final CircularCategory category;
  final String categoryLabel;
  final IconData icon;

  const UniversityCircular({
    required this.id,
    required this.title,
    required this.snippet,
    required this.date,
    required this.category,
    required this.categoryLabel,
    required this.icon,
  });

  static List<UniversityCircular> sampleCirculars = [
    const UniversityCircular(
      id: 'circ-1',
      title: 'Fall 2025 Final Course Registration Deadline',
      snippet: 'Registrar notice: Elective adjustments and formal audit declaration petitions close Friday at 11:59 PM EST.',
      date: 'Sept 28, 2025',
      category: CircularCategory.actionRequired,
      categoryLabel: 'Action Required',
      icon: Icons.priority_high,
    ),
    const UniversityCircular(
      id: 'circ-2',
      title: 'West Quad Pathway Lighting & Escort Service',
      snippet: 'Scheduled infrastructure repairs on West Quad are complete. Evening campus safety escort patrols operate regularly from dusk.',
      date: 'Today, 08:30 AM',
      category: CircularCategory.campusSafety,
      categoryLabel: 'Campus Safety',
      icon: Icons.security,
    ),
    const UniversityCircular(
      id: 'circ-3',
      title: 'Annual Research Symposium: Call for Abstracts',
      snippet: 'Undergraduate and graduate fellows are invited to submit interdisciplinary policy research manuscripts for the 2026 symposium.',
      date: '2 days ago',
      category: CircularCategory.academicCall,
      categoryLabel: 'Academic Call',
      icon: Icons.menu_book,
    ),
  ];
}
