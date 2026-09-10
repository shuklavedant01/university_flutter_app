import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/grievance_filing_sheet.dart';
import '../../models/grievance.dart';

class GrievanceRedressalScreen extends StatefulWidget {
  const GrievanceRedressalScreen({super.key});

  @override
  State<GrievanceRedressalScreen> createState() => _GrievanceRedressalScreenState();
}

class _GrievanceRedressalScreenState extends State<GrievanceRedressalScreen> {
  bool _isAnonymous = false;
  List<GrievanceDocket> _dockets = List.from(GrievanceDocket.sampleDockets);

  void _openFilingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => GrievanceFilingSheet(
        isAnonymous: _isAnonymous,
        onSubmit: (domain, summary) {
          setState(() {
            _dockets.insert(
              0,
              GrievanceDocket(
                id: '#GRV-${9800 + _dockets.length}',
                title: summary.length > 30 ? '${summary.substring(0, 30)}...' : summary,
                domain: domain,
                status: GrievanceStatus.underInvestigation,
                caseOfficer: 'Ombudsman Intake Officer',
                lastActionTime: 'Just now',
                currentStepInfo: 'Step 1 of 4: Initial Docket Intake',
                currentStep: 1,
                totalSteps: 4,
                isAnonymous: _isAnonymous,
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ombudsman Banner
          _buildOmbudsmanBanner(context),
          const SizedBox(height: 20),

          // Lodge Formal Grievance Card
          _buildLodgeGrievanceCard(context),
          const SizedBox(height: 24),

          // Grievance Channels Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grievance Channels', style: Theme.of(context).textTheme.headlineSmall),
              Text('4 Specialized Cells', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          _buildGrievanceChannelsGrid(context),
          const SizedBox(height: 24),

          // Active Dockets Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Dockets', style: Theme.of(context).textTheme.headlineSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_dockets.length} Active Records',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dockets.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final docket = _dockets[index];
              return _buildDocketCard(context, docket);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOmbudsmanBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
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
              Row(
                children: const [
                  Icon(Icons.verified_user, color: AppColors.secondaryContainer, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'CONFIDENTIAL & PROTECTED',
                    style: TextStyle(
                      color: AppColors.secondaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Encrypted', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ombudsman Redressal Cell',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'An impartial, non-punitive body advocating fair process. Reports are shielded by the Veritas Anti-Retaliation Charter of 2024.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 16),
          // Anonymous Switch Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility_off, color: AppColors.tertiaryFixedDim, size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Anonymous Reporting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        Text('Strip identifiable metadata', style: TextStyle(fontSize: 11, color: AppColors.onPrimaryContainer)),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _isAnonymous,
                  activeColor: AppColors.tertiaryFixedDim,
                  onChanged: (val) {
                    setState(() => _isAnonymous = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLodgeGrievanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x208B1E3F),
            blurRadius: 12,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OFFICIAL ACTION',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const Icon(Icons.security, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Lodge Formal Grievance',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Initiate an encrypted case docket with dedicated liaison assignment within 24 operational hours.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryContainer,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openFilingSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.note_add, size: 20),
              label: const Text('File New Grievance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrievanceChannelsGrid(BuildContext context) {
    final channels = [
      {
        'title': 'Academic',
        'desc': 'Grading disputes, credit transfers, faculty review.',
        'tier': 'Tier I',
        'icon': Icons.school_outlined,
        'isFastTrack': false,
      },
      {
        'title': 'Admin & Bursar',
        'desc': 'Scholarships, billing conflicts, hall allocations.',
        'tier': 'Tier I',
        'icon': Icons.account_balance_wallet_outlined,
        'isFastTrack': false,
      },
      {
        'title': 'Title IX & Ethics',
        'desc': 'Harassment, discrimination, bias escalation.',
        'tier': 'Fast-Track',
        'icon': Icons.policy_outlined,
        'isFastTrack': true,
      },
      {
        'title': 'Campus Logistics',
        'desc': 'Hostels, ADA accessibility, laboratory access.',
        'tier': 'Tier I',
        'icon': Icons.apartment_outlined,
        'isFastTrack': false,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: channels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, idx) {
        final item = channels[idx];
        final isFastTrack = item['isFastTrack'] as bool;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFastTrack ? AppColors.secondary : AppColors.outlineVariant,
              width: isFastTrack ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isFastTrack ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isFastTrack ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  Text(
                    item['tier'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isFastTrack ? AppColors.secondary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['desc'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocketCard(BuildContext context, GrievanceDocket docket) {
    final isResolved = docket.status == GrievanceStatus.resolved;

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
              Row(
                children: [
                  Text(docket.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isResolved ? AppColors.surfaceContainerHigh : AppColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isResolved ? 'RESOLVED' : 'UNDER INVESTIGATION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isResolved ? AppColors.primary : AppColors.tertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              if (docket.isAnonymous)
                const Icon(Icons.visibility_off, size: 16, color: AppColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 6),
          Text(docket.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Case Officer:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    Text(docket.caseOfficer, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.schedule, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Last Recorded Action:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    Text(docket.lastActionTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                docket.currentStepInfo,
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              if (isResolved)
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading Official Outcome Report PDF for ${docket.id}...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  icon: const Icon(Icons.download, size: 14),
                  label: const Text('PDF Report', style: TextStyle(fontSize: 11)),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    _showProgressModal(context, docket);
                  },
                  icon: const Text('View Progress', style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  label: const Icon(Icons.chevron_right, size: 16, color: AppColors.secondary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProgressModal(BuildContext context, GrievanceDocket docket) {
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
            Text('Docket Investigation Progress', style: Theme.of(context).textTheme.headlineSmall),
            Text('${docket.id} • ${docket.title}', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildStepRow(context, '1. Initial Docket Intake & Cryptographic Assignment', true),
            _buildStepRow(context, '2. Evidentiary Hearing & Faculty Review', true, isCurrent: true),
            _buildStepRow(context, '3. Ombudsman Findings Summary', false),
            _buildStepRow(context, '4. Official Resolution & Filing', false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close Tracker'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(BuildContext context, String text, bool isDone, {bool isCurrent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone ? (isCurrent ? Icons.play_circle_fill : Icons.check_circle) : Icons.radio_button_unchecked,
            color: isCurrent ? AppColors.secondary : (isDone ? AppColors.success : AppColors.outlineVariant),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? AppColors.primary : (isDone ? AppColors.onSurface : AppColors.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
