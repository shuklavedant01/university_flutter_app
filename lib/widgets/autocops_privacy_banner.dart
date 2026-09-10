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

  String _lang = 'en';
  Map<String, String> _translations = {};

  @override
  void initState() {
    super.initState();
    final service = AutoCopsPrivacyService.instance;
    if (service.consentState != null) {
      _analytics = service.isCategoryAccepted(AutoCopsPrivacyService.catAnalytics);
      _functional = service.isCategoryAccepted(AutoCopsPrivacyService.catFunctional);
      _marketing = service.isCategoryAccepted(AutoCopsPrivacyService.catMarketing);
    }
    _lang = service.currentLanguage;
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final trans = await AutoCopsPrivacyService.instance.fetchTranslations(_lang);
    if (mounted) {
      setState(() {
        _translations = trans;
      });
    }
  }

  void _changeLanguage(String newLang) async {
    setState(() {
      _lang = newLang;
    });
    await AutoCopsPrivacyService.instance.setLanguage(newLang);
    final trans = await AutoCopsPrivacyService.instance.fetchTranslations(newLang);
    if (mounted) {
      setState(() {
        _translations = trans;
      });
    }
  }

  String _t(String key, String fallback) {
    final val = _translations[key];
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    return fallback;
  }

  void _handleAcceptAll() async {
    setState(() => _isSubmitting = true);
    await AutoCopsPrivacyService.instance.acceptAll();
    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onConsentRecorded?.call();
      _showSuccessFeedback(
        _lang == 'hi'
            ? 'सभी कुकीज़ और गोपनीयता अनुमतियाँ स्वीकृत कर ली गईं।'
            : 'All cookies and privacy permissions accepted.',
      );
    }
  }

  void _handleRejectAll() async {
    setState(() => _isSubmitting = true);
    await AutoCopsPrivacyService.instance.rejectAll();
    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onConsentRecorded?.call();
      _showSuccessFeedback(
        _lang == 'hi'
            ? 'वैकल्पिक कुकीज़ अस्वीकृत। केवल आवश्यक सेवाएँ सक्रिय हैं।'
            : 'Optional cookies rejected. Only essential services active.',
      );
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
      _showSuccessFeedback(
        _lang == 'hi'
            ? 'आपकी व्यक्तिगत गोपनीयता प्राथमिकताएँ सहेज ली गईं।'
            : 'Custom privacy preferences saved.',
      );
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
    final isRtl = AutoCopsPrivacyService.instance.isRtl(_lang);
    final langInfo = AutoCopsPrivacyService.supportedLanguages[_lang] ??
        {'native': 'English', 'name': 'English', 'dir': 'ltr'};

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
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
                // Top Bar with AutoCops Branding & Language Selector
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

                    // Language Selector Pill (23 DPDP Languages)
                    PopupMenuButton<String>(
                      initialValue: _lang,
                      tooltip: 'Select Language / भाषा चुनें',
                      onSelected: _changeLanguage,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (context) {
                        return AutoCopsPrivacyService.supportedLanguages.entries.map((entry) {
                          final code = entry.key;
                          final info = entry.value;
                          final isSelected = code == _lang;
                          return PopupMenuItem<String>(
                            value: code,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  info['native'] ?? code,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  info['name'] ?? code.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              langInfo['native'] ?? _lang.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title (Translated)
                Text(
                  _t('title', 'We value your privacy'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),

                // Description (Translated)
                Text(
                  _t(
                    'message',
                    'Veritas University respects your privacy. We use standard identifiers and cookies to maintain authenticated student sessions, track live campus occupancy, and guarantee data subject protection under Indian DPDP Act 2023 & GDPR bylaws.',
                  ),
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

                // Action Buttons (Translated)
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
                          child: Text(
                            _t('accept_all', 'Accept All'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
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
                          child: Text(
                            _t('reject_all', 'Reject Optional'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
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
                        child: Text(
                          _t('customize', 'Customize'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
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
                          label: Text(
                            _t('save_preferences', 'Save Preferences'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
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
                        child: Text(
                          _t('back', 'Back'),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    final isHindi = _lang == 'hi';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCardItem(
                title: _t('cat_essential', 'Essential'),
                subtitle: isHindi ? 'अनिवार्य • DPDP 2023' : 'Strictly Necessary',
                isSelected: true,
                isMandatory: true,
                onChanged: null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCardItem(
                title: _t('cat_analytics', 'Analytics'),
                subtitle: isHindi ? 'उपयोग और ट्रैफ़िक' : 'Usage Metrics',
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
                title: _t('cat_functional', 'Functional'),
                subtitle: isHindi ? 'व्यक्तिगत प्राथमिकताएँ' : 'Personalization',
                isSelected: _functional,
                isMandatory: false,
                onChanged: (val) => setState(() => _functional = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCardItem(
                title: _t('cat_marketing', 'Marketing'),
                subtitle: isHindi ? 'सूचनाएँ एवं संपर्क' : 'Alumni Outreach',
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
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
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
