import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../services/autocops_privacy_service.dart';

enum GrievanceStep { form, verify, success }

class GrievanceRedressalScreen extends StatefulWidget {
  const GrievanceRedressalScreen({super.key});

  @override
  State<GrievanceRedressalScreen> createState() => _GrievanceRedressalScreenState();
}

class _GrievanceRedressalScreenState extends State<GrievanceRedressalScreen> {
  int _currentTab = 0; // 0: Lodge Grievance, 1: Track Docket

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  final _otpController = TextEditingController();

  // Lookup Controllers
  final _lookupIdController = TextEditingController();
  final _lookupTokenController = TextEditingController();
  final _feedbackCommentsController = TextEditingController();

  String _selectedCategory = 'GENERAL';
  GrievanceStep _currentStep = GrievanceStep.form;

  String _challengeId = '';
  String _maskedRecipient = '';
  String _confirmedGrievanceId = '';
  String _verificationChannel = 'email';

  bool _isLoading = false;
  String? _errorMessage;

  // Track / Lookup State
  bool _isLookingUp = false;
  GrievanceLookupResult? _lookupResult;
  String? _lookupErrorMessage;
  int _selectedRating = 5;
  bool _isSubmittingFeedback = false;
  String? _feedbackSuccessMessage;

  static const List<Map<String, String>> _categories = [
    {
      'code': 'GENERAL',
      'label': 'General Complaint',
      'provision': 'General Helpdesk',
      'desc': 'Non-privacy general student academic, housing, or support issue.',
    },
    {
      'code': 'DATA_ACCESS',
      'label': 'Data Access Issue',
      'provision': 'DPDP Act §11',
      'desc': 'Delay or failure in fulfilling statutory data access request.',
    },
    {
      'code': 'DATA_ACCURACY',
      'label': 'Data Correction Issue',
      'provision': 'DPDP Act §12',
      'desc': 'Failure or inaccuracy in correcting university student records.',
    },
    {
      'code': 'DATA_ERASURE',
      'label': 'Data Erasure Issue',
      'provision': 'DPDP Act §12',
      'desc': 'Unresolved request for erasure of non-statutory personal data.',
    },
    {
      'code': 'CONSENT_RELATED',
      'label': 'Consent Related',
      'provision': 'DPDP Act §6',
      'desc': 'Unclear privacy notice, forced bundling, or ambiguous consent requests.',
    },
    {
      'code': 'CONSENT_WITHDRAWAL',
      'label': 'Consent Withdrawal Not Honored',
      'provision': 'DPDP Act §6(4)',
      'desc': 'Failure to cease personal data processing post-consent withdrawal.',
    },
    {
      'code': 'BREACH_NOTIFICATION',
      'label': 'Breach Notification Issue',
      'provision': 'DPDP Act §8(6)',
      'desc': 'Concern regarding potential student personal data incident or unauthorized leak.',
    },
    {
      'code': 'CHILDREN_DATA',
      'label': 'Children\'s Data Concern',
      'provision': 'DPDP Act §9',
      'desc': 'Processing minor student data without verifiable parental consent.',
    },
    {
      'code': 'NOMINATION_ISSUE',
      'label': 'Nomination Issue',
      'provision': 'DPDP Act §14',
      'desc': 'Dispute or registration failure regarding registered student nominee.',
    },
    {
      'code': 'OTHER',
      'label': 'Other Grievances',
      'provision': 'Compliance Office',
      'desc': 'Unlisted privacy or statutory data protection grievance.',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _descController.dispose();
    _otpController.dispose();
    _lookupIdController.dispose();
    _lookupTokenController.dispose();
    _feedbackCommentsController.dispose();
    super.dispose();
  }

  Map<String, String> get _currentCategoryMeta {
    return _categories.firstWhere(
      (c) => c['code'] == _selectedCategory,
      orElse: () => _categories.first,
    );
  }

  Future<void> _handleInitiateChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    if (_emailController.text.trim().isEmpty && _phoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please provide either an email address or a phone number for verification.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AutoCopsPrivacyService.instance.initiateGrievanceChallenge(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      category: _selectedCategory,
      subject: _subjectController.text,
      description: _descController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.ok && result.challengeId != null) {
        _challengeId = result.challengeId!;
        _verificationChannel = result.channel ?? (_emailController.text.isNotEmpty ? 'email' : 'SMS');
        _maskedRecipient = result.emailMasked ??
            (_emailController.text.isNotEmpty ? _emailController.text.trim() : _phoneController.text.trim());
        _otpController.clear();
        _currentStep = GrievanceStep.verify;
      } else {
        _errorMessage = result.error ?? 'Failed to initiate verification code. Please check details.';
      }
    });
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit verification code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AutoCopsPrivacyService.instance.submitGrievanceVerification(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      category: _selectedCategory,
      subject: _subjectController.text,
      description: _descController.text,
      challengeId: _challengeId,
      otp: otp,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.ok && result.grievanceId != null) {
        _confirmedGrievanceId = result.grievanceId!;
        _currentStep = GrievanceStep.success;
      } else {
        _errorMessage = result.error ?? 'Invalid verification code. Please check and try again.';
      }
    });
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _descController.clear();
      _otpController.clear();
      _selectedCategory = 'GENERAL';
      _challengeId = '';
      _maskedRecipient = '';
      _confirmedGrievanceId = '';
      _errorMessage = null;
      _currentStep = GrievanceStep.form;
    });
  }

  Future<void> _handleLookup() async {
    final id = _lookupIdController.text.trim();
    if (id.isEmpty) {
      setState(() {
        _lookupErrorMessage = 'Please enter a Grievance Reference ID.';
      });
      return;
    }

    setState(() {
      _isLookingUp = true;
      _lookupErrorMessage = null;
      _lookupResult = null;
      _feedbackSuccessMessage = null;
    });

    final res = await AutoCopsPrivacyService.instance.lookupGrievanceStatus(
      grievanceId: id,
      token: _lookupTokenController.text.trim().isEmpty ? null : _lookupTokenController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLookingUp = false;
      if (res.ok) {
        _lookupResult = res;
      } else {
        _lookupErrorMessage = res.error ?? 'Grievance ticket not found.';
      }
    });
  }

  Future<void> _handleFeedbackSubmit() async {
    if (_lookupResult == null || _lookupResult!.grievanceId == null) return;

    setState(() {
      _isSubmittingFeedback = true;
    });

    final res = await AutoCopsPrivacyService.instance.submitGrievanceFeedback(
      grievanceId: _lookupResult!.grievanceId!,
      rating: _selectedRating,
      comments: _feedbackCommentsController.text,
      token: _lookupTokenController.text.trim().isEmpty ? null : _lookupTokenController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmittingFeedback = false;
      if (res.ok) {
        _feedbackSuccessMessage = 'Thank you! Your feedback has been recorded.';
        _feedbackCommentsController.clear();
      } else {
        _lookupErrorMessage = res.error ?? 'Failed to submit feedback.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildTabSelector(),
            const SizedBox(height: 20),
            if (_currentTab == 0) ...[
              if (_errorMessage != null) ...[
                _buildErrorBanner(_errorMessage!),
                const SizedBox(height: 16),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentLodgeStepWidget(),
              ),
            ] else ...[
              _buildTrackSection(),
            ],
            const SizedBox(height: 24),
            _buildAutoCopsFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F2942),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gavel, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'DPDP ACT 2023 (§13)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DOMAIN: University-App',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Student Grievance Redressal Portal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Lodge statutory grievances regarding personal data processing, consent withdrawals, or privacy rights with the University Grievance Redressal Officer (GRO). Verified via Dual-Channel OTP challenge.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentTab = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    'Lodge Grievance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _currentTab == 0 ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentTab = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 1 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    'Track Docket Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _currentTab == 1 ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.urgentCrimson.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.urgentCrimson, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.urgentCrimson,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLodgeStepWidget() {
    switch (_currentStep) {
      case GrievanceStep.form:
        return _buildStage1Form();
      case GrievanceStep.verify:
        return _buildStage2Verify();
      case GrievanceStep.success:
        return _buildSuccessCard();
    }
  }

  Widget _buildStage1Form() {
    final meta = _currentCategoryMeta;
    return Container(
      key: const ValueKey('grievance_step_form'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Step 1: Grievance Particulars',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Fill out the form below. An OTP challenge will be dispatched to verify your identity.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const Divider(height: 28),

            // Full Name
            const Text(
              'Full Name',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Priya Patel',
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Please enter your legal name' : null,
            ),
            const SizedBox(height: 16),

            // Email Address
            const Text(
              'Email Address',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'priya@example.com',
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number
            const Text(
              'Mobile / Phone Number',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+91 98765 43210',
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                helperText: 'Verification OTP will be sent via Email or SMS.',
                helperStyle: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            const Text(
              'Grievance Category',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.category_outlined, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem<String>(
                  value: c['code'],
                  child: Text(
                    c['label']!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                  });
                }
              },
            ),
            const SizedBox(height: 10),

            // Category helper description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta['provision'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta['desc'] ?? '',
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subject
            const Text(
              'Grievance Subject',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'e.g. Consent withdrawal request not honored',
                prefixIcon: const Icon(Icons.title, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Please enter a grievance subject' : null,
            ),
            const SizedBox(height: 16),

            // Detailed Description
            const Text(
              'Detailed Description of Grievance',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Provide complete details, timeline of incident, and any prior communication with university offices...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Please provide detailed description' : null,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleInitiateChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Initiate Grievance Verification',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStage2Verify() {
    final meta = _currentCategoryMeta;
    return Container(
      key: const ValueKey('grievance_step_verify'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.success.withOpacity(0.15),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Step 2: Enter Verification Code',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Confirm your identity to authorize official logging of your student grievance docket.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const Divider(height: 28),

          // Channel alert
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceContainerHigh),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _verificationChannel == 'SMS' ? Icons.sms_outlined : Icons.mark_email_read_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.4),
                      children: [
                        TextSpan(
                          text: _verificationChannel == 'SMS'
                              ? 'A 6-digit OTP code has been dispatched via SMS to\n'
                              : 'A 6-digit verification code has been dispatched to\n',
                        ),
                        TextSpan(
                          text: _maskedRecipient.isNotEmpty ? _maskedRecipient : 'your registered contact',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const TextSpan(text: '. Please enter the OTP below.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Docket summary preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meta['label'] ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _challengeId.length > 18 ? '${_challengeId.substring(0, 18)}...' : _challengeId,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Principal: ${_nameController.text}',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  'Subject: ${_subjectController.text}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // OTP input
          const Center(
            child: Text(
              '6-Digit Verification Code (OTP)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 220,
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                  fontFamily: 'monospace',
                  color: AppColors.primary,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    letterSpacing: 10,
                    color: AppColors.outlineVariant.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Confirm & Submit Ticket',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Back Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _currentStep = GrievanceStep.form;
                        _errorMessage = null;
                      });
                    },
              child: const Text(
                '← Back to Edit Details',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    final meta = _currentCategoryMeta;
    return Container(
      key: const ValueKey('grievance_step_success'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successContainer),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A15803D),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.successContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: AppColors.success, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Grievance Ticket Successfully Registered',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Your grievance docket has been formally assigned and recorded in the AutoCops Redressal Engine.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 32),

          // Ticket Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceContainerHigh),
            ),
            child: Column(
              children: [
                const Text(
                  'OFFICIAL GRIEVANCE REFERENCE ID',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _confirmedGrievanceId,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _confirmedGrievanceId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Grievance ID copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Copy Reference ID',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Metadata Table
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Category', meta['label'] ?? ''),
                const Divider(height: 16),
                _buildSummaryRow('Subject', _subjectController.text),
                const Divider(height: 16),
                _buildSummaryRow('Principal', _nameController.text),
                const Divider(height: 16),
                _buildSummaryRow('Domain', AutoCopsPrivacyService.domain),
                const Divider(height: 16),
                _buildSummaryRow('Statutory Timeline', '30 Days (§13 DPDP Act)'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Lodge Another'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _lookupIdController.text = _confirmedGrievanceId;
                      _currentTab = 1;
                    });
                    _handleLookup();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Track This Ticket'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track Grievance Status',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your assigned reference ID to inspect GRO review progress or rate resolution.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const Divider(height: 28),

          // Ticket ID input
          const Text(
            'Grievance Reference ID',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _lookupIdController,
            decoration: InputDecoration(
              hintText: 'e.g. GRV-20260901-0041',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Security Token (Optional)
          const Text(
            'Access Token (Optional)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _lookupTokenController,
            decoration: InputDecoration(
              hintText: 'If provided in confirmation message',
              prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Track Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isLookingUp ? null : _handleLookup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLookingUp
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Check Docket Status', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          if (_lookupErrorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorBanner(_lookupErrorMessage!),
          ],

          if (_lookupResult != null && _lookupResult!.ok) ...[
            const SizedBox(height: 24),
            _buildLookupDetailsCard(_lookupResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildLookupDetailsCard(GrievanceLookupResult res) {
    final statusColor = res.status == 'RESOLVED'
        ? AppColors.success
        : (res.status == 'IN_REVIEW' ? AppColors.warning : AppColors.primary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                res.grievanceId ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: AppColors.primaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  res.status ?? 'PENDING',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (res.subject != null && res.subject!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              res.subject!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
          ],
          if (res.resolutionSummary != null && res.resolutionSummary!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resolution Summary:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    res.resolutionSummary!,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],

          // If resolved, show Satisfaction Feedback Rating
          if (res.status == 'RESOLVED') ...[
            const Divider(height: 24),
            const Text(
              'Rate Resolution Satisfaction (GRO Feedback)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starNum = index + 1;
                return IconButton(
                  icon: Icon(
                    starNum <= _selectedRating ? Icons.star : Icons.star_border,
                    color: AppColors.tertiary,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = starNum;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _feedbackCommentsController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Share comments regarding GRO promptness or resolution quality...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isSubmittingFeedback ? null : _handleFeedbackSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmittingFeedback
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit Feedback Rating'),
            ),
            if (_feedbackSuccessMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _feedbackSuccessMessage!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoCopsFooter() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.security, size: 20, color: AppColors.onSurfaceVariant),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AutoCops Grievance Redressal Engine',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      'GRO: dpo@veritas.edu.in • Statutory SLA: 30 days',
                      style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
