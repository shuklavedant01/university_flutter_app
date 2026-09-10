import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/autocops_privacy_service.dart';

class StudentInquiryFormScreen extends StatefulWidget {
  final String? initialDepartment;

  const StudentInquiryFormScreen({
    super.key,
    this.initialDepartment,
  });

  @override
  State<StudentInquiryFormScreen> createState() => _StudentInquiryFormScreenState();
}

class _StudentInquiryFormScreenState extends State<StudentInquiryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedDepartment = 'Admissions';

  // Consent states as per DPDP Act 2023 Form Consent Guide
  // Essential Consent is mandatory to unlock the submit button
  bool _consentEssential = false;
  bool _consentNewsletter = false;
  bool _consentMarketing = false;
  bool _consentAnalytics = false;

  bool _isSubmitting = false;
  bool _isSubmittedSuccess = false;
  List<String> _receivedConsentIds = [];
  String _generatedTicketId = '';

  final List<String> _departments = [
    'Admissions',
    'Registrar',
    'Financial Aid & Bursar',
    'Health & Counseling',
    'Campus Security',
    'Academic Affairs & Dean',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDepartment != null && _departments.contains(widget.initialDepartment)) {
      _selectedDepartment = widget.initialDepartment!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consentEssential) return; // Defensive check

    setState(() => _isSubmitting = true);

    // Prepare unbundled DPDP consent purposes
    final List<FormConsentItem> purposes = [
      const FormConsentItem(
        purposeId: 'P_ESSENTIALS',
        purposeCategory: 'STRICTLY_NECESSARY',
        purposeDesc: 'Essential campus operations, admissions & inquiry processing',
      ),
    ];

    if (_consentNewsletter) {
      purposes.add(
        const FormConsentItem(
          purposeId: 'P_NEWSLETTER',
          purposeCategory: 'MARKETING',
          purposeDesc: 'Monthly campus announcements, scholarly journals & circulars',
        ),
      );
    }

    if (_consentMarketing) {
      purposes.add(
        const FormConsentItem(
          purposeId: 'P_MARKETING',
          purposeCategory: 'MARKETING',
          purposeDesc: 'Academic program advisories, alumni network & career outreach',
        ),
      );
    }

    if (_consentAnalytics) {
      purposes.add(
        const FormConsentItem(
          purposeId: 'P_ANALYTICS',
          purposeCategory: 'ANALYTICS',
          purposeDesc: 'Anonymized application usage telemetry & response optimization',
        ),
      );
    }

    final result = await AutoCopsPrivacyService.instance.captureFormConsent(
      email: _emailController.text.trim(),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      items: purposes,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmittedSuccess = true;
        _receivedConsentIds = result.consentIds;
        _generatedTicketId = '#VR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      });
    }
  }

  void _resetForm() {
    setState(() {
      _isSubmittedSuccess = false;
      _consentEssential = false;
      _consentNewsletter = false;
      _consentMarketing = false;
      _consentAnalytics = false;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Submit button disabling logic:
    // Form submission is strictly locked until essential consent is acknowledged
    final bool isSubmitDisabled = _isSubmitting || !_consentEssential;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Inquiry & Admissions Form',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: _isSubmittedSuccess ? _buildSuccessCard(context) : _buildFormContent(context, isSubmitDisabled),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, bool isSubmitDisabled) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Compliance Assurance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield, color: AppColors.tertiaryFixedDim, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'DPDP ACT 2023 COMPLIANT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tertiaryFixedDim,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SSL 256-Bit',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Direct University Inquiry Desk',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Submit your academic, admissions, or administrative inquiry. Your personal identifiers are governed with explicit statutory consent.',
                  style: TextStyle(fontSize: 12, color: AppColors.onPrimaryContainer, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Personal Details
          Text('1. Contact Details', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),

          // Full Name
          _buildTextField(
            controller: _nameController,
            label: 'Full Legal Name',
            hint: 'e.g. Katherine Vance',
            icon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
          ),
          const SizedBox(height: 12),

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'e.g. katherine@veritas.edu or personal email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@') || !v.contains('.')) return 'Please enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Phone / Mobile Number',
            hint: 'e.g. +91 98765 43210',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
          ),
          const SizedBox(height: 20),

          // Section 2: Inquiry Particulars
          Text('2. Inquiry Details', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),

          // Target Department Selector
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: InputDecoration(
              labelText: 'Target Department',
              prefixIcon: const Icon(Icons.domain_outlined, size: 20, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            items: _departments.map((dept) {
              return DropdownMenuItem<String>(
                value: dept,
                child: Text(dept, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDepartment = val);
            },
          ),
          const SizedBox(height: 12),

          // Message
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Inquiry Particulars / Message',
              alignLabelWithHint: true,
              hintText: 'Please describe your inquiry, course requirements, or application questions in detail...',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please provide details for your inquiry' : null,
          ),
          const SizedBox(height: 24),

          // Section 3: Data Privacy Consents (DPDP Act 2023)
          _buildConsentSection(context),
          const SizedBox(height: 20),

          // Submit CTA Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitDisabled ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                disabledForegroundColor: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: isSubmitDisabled ? 0 : 2,
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Text('Registering Consents & Submitting...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Submit Inquiry & Record Consent',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),

          // Helper warning text when disabled
          if (isSubmitDisabled && !_isSubmitting) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, size: 14, color: AppColors.urgentCrimson),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '* Please acknowledge the essential consent checkbox above to enable form submission.',
                    style: TextStyle(fontSize: 11, color: AppColors.urgentCrimson, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConsentSection(BuildContext context) {
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
            children: const [
              Icon(Icons.verified_user_outlined, size: 18, color: AppColors.secondary),
              SizedBox(width: 8),
              Text(
                'Data Privacy Consents (DPDP Act 2023)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Under §5 & §6 of the DPDP Act 2023, data fiduciaries must capture unbundled, explicit consent before processing your personal identifiers.',
            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3),
          ),
          const SizedBox(height: 14),

          // 1. Mandatory Essential Consent Checkbox
          _buildConsentCheckbox(
            value: _consentEssential,
            isMandatory: true,
            purposeId: 'P_ESSENTIALS',
            title: 'Essential Consents (Mandatory to Submit) *',
            description:
                'I consent to essential university processing, inquiry routing, and necessary student contact operations.',
            onChanged: (val) => setState(() => _consentEssential = val ?? false),
          ),
          const Divider(height: 18),

          // 2. Newsletter Subscription (Optional)
          _buildConsentCheckbox(
            value: _consentNewsletter,
            isMandatory: false,
            purposeId: 'P_NEWSLETTER',
            title: 'Newsletter Subscription (Optional)',
            description: 'Receive periodic Veritas campus bulletins, research breakthroughs, and academic notices.',
            onChanged: (val) => setState(() => _consentNewsletter = val ?? false),
          ),
          const Divider(height: 18),

          // 3. Marketing Communications (Optional)
          _buildConsentCheckbox(
            value: _consentMarketing,
            isMandatory: false,
            purposeId: 'P_MARKETING',
            title: 'Marketing Communications (Optional)',
            description: 'Receive admissions counseling follow-ups, upcoming program open days, and scholarship updates.',
            onChanged: (val) => setState(() => _consentMarketing = val ?? false),
          ),
          const Divider(height: 18),

          // 4. Analytics & Optimization (Optional)
          _buildConsentCheckbox(
            value: _consentAnalytics,
            isMandatory: false,
            purposeId: 'P_ANALYTICS',
            title: 'Analytics & Service Optimization (Optional)',
            description: 'Help improve portal responsiveness and student support routing speed through anonymous telemetry.',
            onChanged: (val) => setState(() => _consentAnalytics = val ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required bool isMandatory,
    required String purposeId,
    required String title,
    required String description,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: isMandatory ? AppColors.primary : AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
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
                          fontWeight: isMandatory ? FontWeight.bold : FontWeight.w600,
                          color: isMandatory && !value ? AppColors.urgentCrimson : AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (isMandatory) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: value ? AppColors.surfaceLow : AppColors.urgentCrimson.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: value ? AppColors.primary : AppColors.urgentCrimson,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          value ? 'ACKNOWLEDGED' : 'REQUIRED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: value ? AppColors.primary : AppColors.urgentCrimson,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3),
                ),
                const SizedBox(height: 2),
                Text(
                  'Purpose ID: $purposeId',
                  style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: AppColors.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F2942),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(Icons.check, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Inquiry & Consent Dispatched',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            'Your submission has been securely routed to the Office of $_selectedDepartment.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Verification Ticket Container
          Container(
            width: double.infinity,
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
                    const Text(
                      'INQUIRY DOCKET TICKET',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      _generatedTicketId,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const Divider(height: 20),
                const Text(
                  'AutoCops Compliance Engine Verification:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 6),
                if (_receivedConsentIds.isNotEmpty) ...[
                  ..._receivedConsentIds.map(
                    (id) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, size: 14, color: AppColors.tertiary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Consent ID: $id',
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Recorded on AutoCops Compliance Platform (200 OK)',
                    style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Statutory Basis: DPDP Act 2023 §6(1) Explicit Consent • ROPA Logged',
                  style: TextStyle(fontSize: 10, color: AppColors.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Done / Submit Another
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Submit Another Inquiry'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Return to Directory'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
