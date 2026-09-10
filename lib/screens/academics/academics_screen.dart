import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        'code': 'ECON-401',
        'title': 'Advanced Macroeconomics',
        'credits': '4.0 Units',
        'grade': 'A',
        'instructor': 'Prof. Julian Vance',
        'schedule': 'Mon, Wed 11:30 AM - 1:00 PM',
      },
      {
        'code': 'ECON-412',
        'title': 'Applied Econometrics II',
        'credits': '4.0 Units',
        'grade': 'A-',
        'instructor': 'Dr. Marcus Sterling',
        'schedule': 'Tue, Thu 9:00 AM - 10:30 AM',
      },
      {
        'code': 'POLI-305',
        'title': 'Contemporary Political Philosophy',
        'credits': '3.0 Units',
        'grade': 'A',
        'instructor': 'Dr. Helena Roy',
        'schedule': 'Wed 2:00 PM - 5:00 PM',
      },
      {
        'code': 'INTL-380',
        'title': 'Global Trade Policy & Regulation',
        'credits': '3.0 Units',
        'grade': 'Enrolled',
        'instructor': 'Dean Arthur Pendelton',
        'schedule': 'Fri 10:00 AM - 1:00 PM',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'ACADEMIC PORTAL',
                      style: TextStyle(
                        color: AppColors.tertiaryFixedDim,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Degree Audit 88%',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Term & Transcript',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'B.A. Economics & International Policy • Faculty of Social Sciences',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generating official cryptographically signed PDF transcript...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.description, size: 16),
                        label: const Text('Request Transcript', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Degree Audit Worksheet...')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.analytics, size: 16),
                        label: const Text('Degree Audit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Enrolled Courses List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fall 2025 Enrolled Courses', style: Theme.of(context).textTheme.headlineSmall),
              Text('14.0 Total Units', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = courses[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            c['code']!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c['grade']!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.tertiaryContainer),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(c['title']!, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${c['instructor']} • ${c['credits']}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(c['schedule']!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
