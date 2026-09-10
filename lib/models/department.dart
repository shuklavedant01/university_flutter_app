import 'package:flutter/material.dart';

class Department {
  final String id;
  final String name;
  final String category; // 'admissions', 'registrar', 'finance', 'health', 'security'
  final String badgeText;
  final String description;
  final String location;
  final String hours;
  final String phone;
  final String email;
  final IconData icon;

  const Department({
    required this.id,
    required this.name,
    required this.category,
    required this.badgeText,
    required this.description,
    required this.location,
    required this.hours,
    required this.phone,
    required this.email,
    required this.icon,
  });

  static List<Department> sampleDepartments = [
    const Department(
      id: 'dept-1',
      name: 'Office of Admissions',
      category: 'admissions',
      badgeText: 'Undergraduate & Graduate',
      description: 'Admissions counseling, campus visitation inquiries, transfer credits, and application submissions.',
      location: 'Building A, Suite 104 (East Quad)',
      hours: 'Mon – Fri, 8:00 AM – 5:00 PM EST',
      phone: '+1 (555) 0192',
      email: 'admissions@veritas.edu',
      icon: Icons.school_outlined,
    ),
    const Department(
      id: 'dept-2',
      name: 'Office of the Registrar',
      category: 'registrar',
      badgeText: 'Academic Records',
      description: 'Official transcripts, enrollment certifications, degree audits, and course registration adjustments.',
      location: "Founder's Hall, Room 210",
      hours: 'Mon – Fri, 9:00 AM – 4:30 PM EST',
      phone: '+1 (555) 0193',
      email: 'registrar@veritas.edu',
      icon: Icons.description_outlined,
    ),
    const Department(
      id: 'dept-3',
      name: 'Student Financial Services',
      category: 'finance',
      badgeText: 'Bursar & Awards',
      description: 'Tuition payment processing, FAFSA advisory, scholarships disbursement, and institutional work-study.',
      location: 'Grace Hall, Ground Concourse G-12',
      hours: 'Mon – Thu, 8:30 AM – 5:00 PM (Fri till 4:00 PM)',
      phone: '+1 (555) 0198',
      email: 'bursar@veritas.edu',
      icon: Icons.account_balance_wallet_outlined,
    ),
    const Department(
      id: 'dept-4',
      name: 'Campus Health & Counseling',
      category: 'health',
      badgeText: 'Wellness & Medical',
      description: 'Primary medical care, mental health counseling, immunization compliance, and crisis support.',
      location: 'Health Sciences Wing, 1st Floor',
      hours: '24/7 Urgent Care • Clinic: Mon-Fri 8AM-6PM',
      phone: '+1 (555) 0199',
      email: 'health@veritas.edu',
      icon: Icons.medical_services_outlined,
    ),
    const Department(
      id: 'dept-5',
      name: 'Campus Public Safety & Police',
      category: 'security',
      badgeText: 'Safety & Protection',
      description: '24/7 campus patrol, emergency dispatch, parking permits, and lost & found bureau.',
      location: 'Security HQ, West Entrance Gatehouse',
      hours: '24 Hours / 365 Days',
      phone: '+1 (800) 555-SAFE',
      email: 'safety@veritas.edu',
      icon: Icons.local_police_outlined,
    ),
  ];
}
