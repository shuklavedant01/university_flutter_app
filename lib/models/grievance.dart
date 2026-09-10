import 'package:flutter/material.dart';

enum GrievanceStatus {
  underInvestigation,
  resolved,
  pendingReview,
}

class GrievanceDocket {
  final String id;
  final String title;
  final String domain;
  final GrievanceStatus status;
  final String caseOfficer;
  final String lastActionTime;
  final String currentStepInfo;
  final int currentStep;
  final int totalSteps;
  final String? outcomeDate;
  final bool isAnonymous;

  const GrievanceDocket({
    required this.id,
    required this.title,
    required this.domain,
    required this.status,
    required this.caseOfficer,
    required this.lastActionTime,
    required this.currentStepInfo,
    required this.currentStep,
    required this.totalSteps,
    this.outcomeDate,
    this.isAnonymous = false,
  });

  static List<GrievanceDocket> sampleDockets = [
    const GrievanceDocket(
      id: '#GRV-9421',
      title: 'Library Study Space Accessibility Issue',
      domain: 'Campus Facilities & Inclusivity',
      status: GrievanceStatus.underInvestigation,
      caseOfficer: 'Dr. M. Vance (Ombudsman)',
      lastActionTime: '2 hours ago',
      currentStepInfo: 'Step 2 of 4: Evidentiary Hearing',
      currentStep: 2,
      totalSteps: 4,
    ),
    const GrievanceDocket(
      id: '#GRV-8812',
      title: 'Fee Re-evaluation & Refund Request',
      domain: 'Administrative & Financial Discrepancy',
      status: GrievanceStatus.resolved,
      caseOfficer: 'Bursar Appeals Board',
      lastActionTime: 'Closed on Oct 14, 2024',
      currentStepInfo: 'Step 4 of 4: Resolution & Filing',
      currentStep: 4,
      totalSteps: 4,
      outcomeDate: 'Oct 14, 2024',
    ),
  ];
}
