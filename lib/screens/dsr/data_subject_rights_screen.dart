import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/dsr_request.dart';
import '../../services/autocops_privacy_service.dart';
import '../../widgets/autocops_privacy_banner.dart';

class DataSubjectRightsScreen extends StatefulWidget {
  const DataSubjectRightsScreen({super.key});

  @override
  State<DataSubjectRightsScreen> createState() => _DataSubjectRightsScreenState();
}

class _DataSubjectRightsScreenState extends State<DataSubjectRightsScreen> {
  bool _directoryVisibility = true;
  bool _researchSharing = false;
  bool _alumniMarketing = false;

  @override
  void initState() {
    super.initState();
    AutoCopsPrivacyService.instance.addListener(_onAutoCopsStateChanged);
  }

  @override
  void dispose() {
    AutoCopsPrivacyService.instance.removeListener(_onAutoCopsStateChanged);
    super.dispose();
  }

  void _onAutoCopsStateChanged() {
    if (mounted) setState(() {});
  }

  void _openAutoCopsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AutoCopsPrivacyBanner(
        onConsentRecorded: () {
          Navigator.pop(ctx);
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
          // Banner Header
          _buildPrivacyBanner(context),
          const SizedBox(height: 20),

          // AutoCops Cookie & Tracking Governance Card
          _buildAutoCopsConsentCard(context),
          const SizedBox(height: 20),

          // Active Request Tracker Card
          _buildActiveTrackerCard(context),
          const SizedBox(height: 24),

          // Data Rights Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Exercise Your Data Rights', style: Theme.of(context).textTheme.headlineSmall),
              Text('5 Provisions Available', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Select an authorized statutory action under global data governance bylaws.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // 1. Right to Access Card
          _buildDataRightCard(
            context: context,
            icon: Icons.cloud_download_outlined,
            title: 'Right to Access (Data Export)',
            statute: 'Article 15 GDPR • FERPA §99.10',
            tag: 'JSON / PDF',
            description:
                'Receive an exhaustive, machine-readable package containing academic records, faculty notes, course evaluations, and device connection telemetry.',
            buttonLabel: 'Request Export',
            buttonIcon: Icons.arrow_forward,
            onTap: () {
              _showExportConfirmationDialog(context);
            },
          ),
          const SizedBox(height: 16),

          // 2. Right to Rectification Card
          _buildDataRightCard(
            context: context,
            icon: Icons.edit_note_outlined,
            title: 'Right to Rectification',
            statute: 'Article 16 GDPR • FERPA Amendment',
            description:
                'Challenge and amend incorrect demographic data, erroneous transcript registrations, or misattributed research citations.',
            buttonLabel: 'File Correction',
            buttonIcon: Icons.rule,
            isSecondaryAction: true,
            onTap: () {
              _showRectificationDialog(context);
            },
          ),
          const SizedBox(height: 16),

          // 3. Right to Erasure Card
          _buildDataRightCard(
            context: context,
            icon: Icons.delete_forever_outlined,
            iconColor: AppColors.secondary,
            title: 'Right to Erasure (‘Forget Me’)',
            statute: 'Article 17 GDPR • CCPA Deletion',
            description:
                'Permanently purge post-graduation non-statutory records, athletic media files, and alumni marketing fingerprints. Official graduation registry retained by law.',
            buttonLabel: 'Request Purge',
            buttonIcon: Icons.verified_user_outlined,
            isDestructive: true,
            onTap: () {
              _showPurgeWarningDialog(context);
            },
          ),
          const SizedBox(height: 16),

          // 4. Consent Management Card
          _buildConsentManagementCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAutoCopsConsentCard(BuildContext context) {
    final service = AutoCopsPrivacyService.instance;
    final consent = service.consentState;
    final visitorId = service.visitorId;

    final isAnalytics = service.isCategoryAccepted(AutoCopsPrivacyService.catAnalytics);
    final isFunctional = service.isCategoryAccepted(AutoCopsPrivacyService.catFunctional);
    final isMarketing = service.isCategoryAccepted(AutoCopsPrivacyService.catMarketing);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F2942),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield, color: AppColors.tertiaryFixedDim, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AutoCops Privacy & Cookie Policy',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Text(
                        'Domain: University-App • Platform: AutoCops Engine',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: service.hasGivenConsent ? AppColors.successContainer : AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service.hasGivenConsent ? 'COMPLIANT' : 'ACTION NEEDED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: service.hasGivenConsent ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Cookie and device identifier permissions are bound to Data Principal ID: $visitorId and enforced across all sessions.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          // Category pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildStatusPill('Essential: ON', true),
              _buildStatusPill('Analytics: ${isAnalytics ? "ON" : "OFF"}', isAnalytics),
              _buildStatusPill('Functional: ${isFunctional ? "ON" : "OFF"}', isFunctional),
              _buildStatusPill('Marketing: ${isMarketing ? "ON" : "OFF"}', isMarketing),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openAutoCopsModal(context),
              icon: const Icon(Icons.tune, size: 16),
              label: const Text(
                'Update Cookie & Privacy Preferences',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.surfaceLow : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildPrivacyBanner(BuildContext context) {
    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_user, size: 14, color: AppColors.tertiaryFixedDim),
                    SizedBox(width: 4),
                    Text(
                      'FERPA • GDPR • CCPA • DPDP',
                      style: TextStyle(
                        color: AppColors.tertiaryFixedDim,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contacting Data Protection Officer Dr. Eleanor Vance (dpo@veritas.edu)')),
                  );
                },
                icon: const Icon(Icons.mail_outline, size: 16, color: AppColors.onPrimaryContainer),
                label: const Text(
                  'DPO Desk',
                  style: TextStyle(color: AppColors.surface, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Institutional Privacy & Subject Rights',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Veritas University safeguards your scholarly, biometric, and institutional data with cryptographic integrity and full statutory protection.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.tertiaryFixedDim, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('DATA PROTECTION OFFICER', style: TextStyle(fontSize: 9, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold)),
                      Text('Dr. Eleanor Vance, CIPP/E', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Level 3 Shield', style: TextStyle(fontSize: 10, color: AppColors.tertiaryFixedDim, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrackerCard(BuildContext context) {
    const sample = ActiveDsrTracker.activeSample;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
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
                children: const [
                  Icon(Icons.sync, color: AppColors.secondary, size: 20),
                  SizedBox(width: 6),
                  Text('Active Request Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.onSurface)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'IN PROGRESS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.tertiaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sample.id,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                    ),
                    const Icon(Icons.hourglass_top, size: 18, color: AppColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 4),
                Text(sample.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text(sample.description, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: sample.progress,
                    backgroundColor: AppColors.surfaceContainer,
                    color: AppColors.secondary,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lock_clock, size: 14, color: AppColors.secondary),
                        SizedBox(width: 4),
                        Text('ETA: ~36 Hours remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.key, size: 14, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 4),
                        Text('2FA Identity Verified', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRightCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String statute,
    required String description,
    required String buttonLabel,
    required IconData buttonIcon,
    required VoidCallback onTap,
    Color? iconColor,
    String? tag,
    bool isSecondaryAction = false,
    bool isDestructive = false,
  }) {
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDestructive ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
                      Text(statute, style: TextStyle(fontSize: 11, color: isDestructive ? AppColors.secondary : AppColors.onSurfaceVariant, fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ],
              ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive
                    ? AppColors.secondary
                    : isSecondaryAction
                        ? AppColors.surfaceContainerHigh
                        : AppColors.primary,
                foregroundColor: isSecondaryAction ? AppColors.onSurface : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: Size.zero,
              ),
              icon: Text(buttonLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              label: Icon(buttonIcon, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentManagementCard(BuildContext context) {
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
                children: const [
                  Icon(Icons.tune, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text('Consent Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Real-time', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Control how faculty labs, directory services, and student societies consume your personal markers.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Campus Directory Visibility', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Display email & major in internal student index', style: TextStyle(fontSize: 12)),
                  value: _directoryVisibility,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _directoryVisibility = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Academic Research Sharing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Allow anonymized grading data for pedagogy studies', style: TextStyle(fontSize: 12)),
                  value: _researchSharing,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _researchSharing = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Alumni Network Marketing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive invitations from affiliated chapters', style: TextStyle(fontSize: 12)),
                  value: _alumniMarketing,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _alumniMarketing = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Initiate Right to Access Export?'),
        content: const Text(
          'Your export package will include complete academic records, library access logs, and student portal telemetry. An email link will be sent within 48 hours after 2FA validation.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('DSR Access Export request submitted (#REQ-2025-0901)')),
              );
            },
            child: const Text('Confirm Request'),
          ),
        ],
      ),
    );
  }

  void _showRectificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('File Data Rectification Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Specify record field requiring correction:'),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(hintText: 'e.g. Middle Name spelling / Transcript Unit code...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rectification petition queued with Registrar Office.')),
              );
            },
            child: const Text('Submit Petition'),
          ),
        ],
      ),
    );
  }

  void _showPurgeWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Account Data Purge?'),
        content: const Text(
          'WARNING: Right to Erasure will delete non-mandatory marketing, athletic, and society records. Legal transcript and degree registry cannot be purged.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: AppColors.urgentCrimson, content: Text('Erasure request submitted to DPO desk for statutory audit.')),
              );
            },
            child: const Text('Confirm Purge'),
          ),
        ],
      ),
    );
  }
}
