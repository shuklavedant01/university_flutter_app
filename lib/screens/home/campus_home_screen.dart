import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/status_badge.dart';
import '../../models/circular.dart';
import '../contact/student_inquiry_form_screen.dart';

class CampusHomeScreen extends StatelessWidget {
  final Function(int pageIndex)? onNavigateToTab;

  const CampusHomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Banner
          _buildStudentBanner(context),
          const SizedBox(height: 24),

          // Today on Campus Section
          _buildTodaySection(context),
          const SizedBox(height: 24),

          // Institutional Services Section
          _buildInstitutionalServices(context),
          const SizedBox(height: 24),

          // University Circulars
          _buildCircularsSection(context),
          const SizedBox(height: 24),

          // Campus Perspective Image Showcase
          _buildCampusPerspective(context),
          const SizedBox(height: 20),

          // Emergency SOS Banner
          _buildEmergencyBanner(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStudentBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F2942),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FALL SEMESTER 2025',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.tertiaryFixedDim,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.tertiaryFixedDim,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Dean\'s Honors • Enrolled',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome back, Elena',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.surface,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: #VU-892401 • Faculty of Social Sciences',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user, size: 18, color: AppColors.tertiaryFixedDim),
                  const SizedBox(width: 6),
                  Text(
                    'Academic Standing: Exemplary',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.surface,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'GPA 3.94',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.tertiaryFixedDim,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today on Campus',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Live Feed',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Next Lecture Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'NEXT LECTURE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'in 45 mins',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Advanced Macroeconomics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.meeting_room, size: 14, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 4),
                        Text(
                          'Hall 302 • 11:30 AM – 1:00 PM',
                          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _showSyllabusSheet(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Text('Syllabus', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid of 2 Mini Cards (Library & Campus Life)
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
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
                        const Icon(Icons.local_library, size: 22, color: AppColors.primary),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Low Density',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('34%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
                        Text('Occupancy', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.34,
                        backgroundColor: AppColors.surfaceLow,
                        color: AppColors.primary,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Memorial Library', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
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
                        const Icon(Icons.event, size: 22, color: AppColors.secondary),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '4:00 PM',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('CAMPUS LIFE', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondary)),
                    const SizedBox(height: 2),
                    Text(
                      'Dean\'s Colloquium',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text('Founders Hall Auditorium', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstitutionalServices(BuildContext context) {
    final services = [
      {'title': 'Admissions & Status', 'icon': Icons.badge_outlined, 'tab': 1},
      {'title': 'Campus Helpdesk', 'icon': Icons.contact_support_outlined, 'tab': 1},
      {'title': 'Data & Privacy', 'icon': Icons.shield_outlined, 'tab': 2},
      {'title': 'File Grievance', 'icon': Icons.gavel_outlined, 'tab': 3},
      {'title': 'Student Portal', 'icon': Icons.domain_verification_outlined, 'tab': 4},
      {'title': 'Academic Calendar', 'icon': Icons.calendar_month_outlined, 'tab': 4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Institutional Services', style: Theme.of(context).textTheme.headlineSmall),
            Text('Core Access', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, idx) {
            final item = services[idx];
            final isGrievance = item['title'] == 'File Grievance';
            return InkWell(
              onTap: () {
                if (item['title'] == 'Admissions & Status') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const StudentInquiryFormScreen()),
                  );
                } else {
                  onNavigateToTab?.call(item['tab'] as int);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isGrievance ? AppColors.secondaryContainer : AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: isGrievance ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCircularsSection(BuildContext context) {
    final circulars = UniversityCircular.sampleCirculars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('University Circulars', style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Displaying archived university notices.')),
                );
              },
              child: const Text(
                'View Archive',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: circulars.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = circulars[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.category == CircularCategory.actionRequired
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      c.icon,
                      size: 20,
                      color: c.category == CircularCategory.actionRequired ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge(
                              label: c.categoryLabel,
                              type: c.category == CircularCategory.actionRequired
                                  ? BadgeType.urgent
                                  : BadgeType.info,
                            ),
                            Text(c.date, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(c.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          c.snippet,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCampusPerspective(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.photo_library_outlined, size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Campus Perspective', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Text('North Quadrangle', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            height: 160,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/images/campus_perspective.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primaryDark.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    'Bancroft Academic Library • Founded 1892',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sos, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus Emergency SOS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Direct line to Campus Public Safety & Medical',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSecondaryContainer.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.urgentCrimson,
                  content: Text('Dialing Campus Safety Emergency Hotline: +1 (800) 555-SAFE'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
            ),
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Hotline', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showSyllabusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Advanced Macroeconomics (ECON-401)', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text('Prof. Julian Vance • Hall 302', style: TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Today\'s Topic: Monetary Policy Transmission & Fiscal Shocks'),
            const SizedBox(height: 8),
            const Text('• Required Reading: Chapter 7 (Blanchard-Fischer)'),
            const Text('• Problem Set #4 Submission due Friday 11:59 PM'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Full Syllabus PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
