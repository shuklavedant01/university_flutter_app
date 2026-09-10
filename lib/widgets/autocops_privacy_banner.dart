import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/autocops_privacy_service.dart';

class AutoCopsPrivacyBanner extends StatefulWidget {
  final VoidCallback? onConsentRecorded;

  const AutoCopsPrivacyBanner({
    super.key,
    this.onConsentRecorded,
  });

  @override
  State<AutoCopsPrivacyBanner> createState() => _AutoCopsPrivacyBannerState();
}

class _AutoCopsPrivacyBannerState extends State<AutoCopsPrivacyBanner> {
  bool _isCustomizing = false;
  bool _analytics = true;
  bool _functional = true;
  bool _marketing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final service = AutoCopsPrivacyService.instance;
    if (service.consentState != null) {
      _analytics = service.isCategoryAccepted(AutoCopsPrivacyService.catAnalytics);
      _functional = service.isCategoryAccepted(AutoCopsPrivacyService.catFunctional);
      _marketing = service.isCategoryAccepted(AutoCopsPrivacyService.catMarketing);
    }
  }

  void _handleAcceptAll() async {
    setState(() => _isSubmitting = true);
    await AutoCopsPrivacyService.instance.acceptAll();
    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onConsentRecorded?.call();
      _showSuccessFeedback('All cookies and privacy permissions accepted.');
    }
  }

  void _handleRejectAll() async {
    setState(() => _isSubmitting = true);
    await AutoCopsPrivacyService.instance.rejectAll();
    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onConsentRecorded?.call();
      _showSuccessFeedback('Optional cookies rejected. Only essential services active.');
    }
  }

  void _handleSaveCustom() async {
    setState(() => _isSubmitting = true);
    await AutoCopsPrivacyService.instance.saveCustomPreferences(
      analytics: _analytics,
      functional: _functional,
      marketing: _marketing,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onConsentRecorded?.call();
      _showSuccessFeedback('Custom privacy preferences saved.');
    }
  }

  void _showSuccessFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240F2942),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with AutoCops Branding
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
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'AutoCops Privacy Guard',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.verified, size: 14, color: AppColors.tertiary),
                            ],
                          ),
                          const Text(
                            'Domain: University-App • DPDP Act 2023 & GDPR',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'v2.5',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Veritas University respects your privacy. We use standard identifiers and cookies to maintain authenticated student sessions, track live campus occupancy, and guarantee data subject protection under Indian DPDP Act 2023 & GDPR bylaws.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 12),

              // Customization Accordion (Card Style)
              if (_isCustomizing) ...[
                _buildCategoryCards(),
                const SizedBox(height: 12),
              ],

              // Action Buttons
              if (!_isCustomizing) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleAcceptAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accept All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _handleRejectAll,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reject Optional', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() => _isCustomizing = true);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Customize', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleSaveCustom,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Save Preferences', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _isCustomizing = false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCardItem(
                title: 'Essential',
                subtitle: 'Strictly Necessary',
                isSelected: true,
                isMandatory: true,
                onChanged: null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCardItem(
                title: 'Analytics',
                subtitle: 'Usage Metrics',
                isSelected: _analytics,
                isMandatory: false,
                onChanged: (val) => setState(() => _analytics = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildCardItem(
                title: 'Functional',
                subtitle: 'Personalization',
                isSelected: _functional,
                isMandatory: false,
                onChanged: (val) => setState(() => _functional = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCardItem(
                title: 'Marketing',
                subtitle: 'Alumni Outreach',
                isSelected: _marketing,
                isMandatory: false,
                onChanged: (val) => setState(() => _marketing = val),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardItem({
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isMandatory,
    required ValueChanged<bool>? onChanged,
  }) {
    return InkWell(
      onTap: isMandatory ? null : () => onChanged?.call(!isSelected),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceLow : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: isSelected,
                onChanged: isMandatory ? null : (val) => onChanged?.call(val ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                      if (isMandatory) ...[
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(color: AppColors.urgentCrimson, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
