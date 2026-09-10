import 'package:flutter/material.dart';

class ActiveDsrTracker {
  final String id; // REQ #DSR-2025-0849
  final String title; // Full Academic History Export
  final String description;
  final double progress; // 0.66
  final String eta; // ~36 Hours remaining
  final bool isVerified;

  const ActiveDsrTracker({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.eta,
    this.isVerified = true,
  });

  static const ActiveDsrTracker activeSample = ActiveDsrTracker(
    id: 'REQ #DSR-2025-0849',
    title: 'Full Academic History Export',
    description: 'Compiling cryptographically signed transcripts, course audit trails, and biometric library check-ins.',
    progress: 0.66,
    eta: '~36 Hours remaining',
    isVerified: true,
  );
}

class ConsentOption {
  final String id;
  final String title;
  final String subtitle;
  bool isEnabled;

  ConsentOption({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isEnabled = false,
  });
}
