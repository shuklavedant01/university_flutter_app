import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../services/autocops_privacy_service.dart';
import '../../widgets/autocops_privacy_banner.dart';

enum DsrStep { form, verify, success }

class DataSubjectRightsScreen extends StatefulWidget {
  const DataSubjectRightsScreen({super.key});

  @override
  State<DataSubjectRightsScreen> createState() => _DataSubjectRightsScreenState();
}

class _DataSubjectRightsScreenState extends State<DataSubjectRightsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descController = TextEditingController();
  final _otpController = TextEditingController();

  String _selectedRequestType = 'ACCESS';
  DsrStep _currentStep = DsrStep.form;

  String _challengeId = '';
  String _maskedRecipient = '';
  String _confirmedRequestId = '';

  bool _isLoading = false;
  String? _errorMessage;

  static const List<Map<String, String>> _requestTypes = [
    {
      'code': 'ACCESS',
      'label': 'Access my data (§11)',
      'section': 'DPDP Act §11',
      'desc': 'Provides summary of personal data & processing activities held by the university.',
    },
    {
      'code': 'CORRECTION',
      'label': 'Correct my data (§12)',
      'section': 'DPDP Act §12',
      'desc': 'Triggers data inaccuracy correction & update workflow for academic or personal records.',
    },
    {
      'code': 'ERASURE',
      'label': 'Erase my data (§12)',
      'section': 'DPDP Act §12',
      'desc': 'Initiates data deletion / right to be forgotten for non-statutory records.',
    },
    {
      'code': 'PORTABILITY',
      'label': 'Download data (portability) (§11)',
      'section': 'DPDP Act §11',
      'desc': 'Prepares a machine-readable JSON/CSV export of your principal data.',
    },
    {
      'code': 'NOMINATION',
      'label': 'Nominate representative (§14)',
      'section': 'DPDP Act §14',
      'desc': 'Registers a nominated person in the event of death or incapacity.',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Map<String, String> get _currentTypeMeta {
    return _requestTypes.firstWhere(
      (element) => element['code'] == _selectedRequestType,
      orElse: () => _requestTypes.first,
    );
  }

  Future<void> _handleInitiateChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AutoCopsPrivacyService.instance.initiateDsrChallenge(
      name: _nameController.text,
      email: _emailController.text,
      requestType: _selectedRequestType,
      description: _descController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.ok && result.challengeId != null) {
        _challengeId = result.challengeId!;
        _maskedRecipient = result.emailMasked ?? _emailController.text.trim();
        _otpController.clear();
        _currentStep = DsrStep.verify;
      } else {
        _errorMessage = result.error ?? 'Failed to initiate verification code. Please try again.';
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

    final result = await AutoCopsPrivacyService.instance.submitDsrVerification(
      name: _nameController.text,
      email: _emailController.text,
      requestType: _selectedRequestType,
      description: _descController.text,
      challengeId: _challengeId,
      otp: otp,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.ok && result.requestId != null) {
        _confirmedRequestId = result.requestId!;
        _currentStep = DsrStep.success;
      } else {
        _errorMessage = result.error ?? 'Invalid verification code. Please check and try again.';
      }
    });
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _descController.clear();
      _otpController.clear();
      _selectedRequestType = 'ACCESS';
      _challengeId = '';
      _maskedRecipient = '';
      _confirmedRequestId = '';
      _errorMessage = null;
      _currentStep = DsrStep.form;
    });
  }

  void _openCookieBannerModal() {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 16),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStepWidget(),
            ),
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
                    Icon(Icons.verified_user_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'DPDP ACT 2023 (§11-14)',
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
            'Data Subject Rights Portal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Exercise your statutory data rights under India\'s Digital Personal Data Protection Act 2023. Requests are verified via a two-stage OTP challenge before processing.',
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

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case DsrStep.form:
        return _buildStage1Form();
      case DsrStep.verify:
        return _buildStage2Verify();
      case DsrStep.success:
        return _buildSuccessCard();
    }
  }

  Widget _buildStage1Form() {
    final meta = _currentTypeMeta;
    return Container(
      key: const ValueKey('step_form'),
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
                  'Step 1: Request Details',
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
              'Enter your principal identification and select the right you wish to exercise.',
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
                hintText: 'e.g. Aarav Sharma',
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
                  (val == null || val.trim().isEmpty) ? 'Please enter your full legal name' : null,
            ),
            const SizedBox(height: 16),

            // Email / Mobile
            const Text(
              'Email Address or Mobile Number',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'name@example.com / +91-9876543210',
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
                helperText: 'AutoCops will send a 6-digit OTP challenge to this address.',
                helperStyle: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your email address or mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Request Type
            const Text(
              'Statutory Request Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedRequestType,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.gavel_outlined, size: 20),
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
              items: _requestTypes.map((t) {
                return DropdownMenuItem<String>(
                  value: t['code'],
                  child: Text(
                    t['label']!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRequestType = val;
                  });
                }
              },
            ),
            const SizedBox(height: 10),

            // Request Type Description Helper Card
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
                          meta['section'] ?? '',
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

            // Description
            const Text(
              'Description of Request',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Specify the exact records, categories, or corrections requested...',
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
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please describe your request details'
                  : null,
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
                            'Initiate Verification Code',
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
    final meta = _currentTypeMeta;
    return Container(
      key: const ValueKey('step_verify'),
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
            'Confirm your identity to authorize official logging of your DPDP request.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const Divider(height: 28),

          // Notification Alert
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
                const Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.4),
                      children: [
                        const TextSpan(text: 'A 6-digit verification code has been dispatched to\n'),
                        TextSpan(
                          text: _maskedRecipient.isNotEmpty ? _maskedRecipient : _emailController.text,
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

          // Pending request summary
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
                          'Confirm & Log DSR Ticket',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Back to edit button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _currentStep = DsrStep.form;
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
    final meta = _currentTypeMeta;
    return Container(
      key: const ValueKey('step_success'),
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
            'DSR Request Officially Logged',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Your statutory request has been verified and registered in the AutoCops Compliance Engine.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 32),

          // Ticket reference box
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
                  'OFFICIAL TICKET REFERENCE ID',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _confirmedRequestId,
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
                    Clipboard.setData(ClipboardData(text: _confirmedRequestId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ticket reference copied to clipboard!'),
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

          // Info Table
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Request Type', meta['label'] ?? ''),
                const Divider(height: 16),
                _buildSummaryRow('Principal', _nameController.text),
                const Divider(height: 16),
                _buildSummaryRow('Contact', _emailController.text),
                const Divider(height: 16),
                _buildSummaryRow('Domain', AutoCopsPrivacyService.domain),
                const Divider(height: 16),
                _buildSummaryRow('Statutory Timeline', '30 Days (§11-14 DPDP Act)'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit another request button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Submit Another Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
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
          child: Row(
            children: [
              const Icon(Icons.security, size: 20, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AutoCops DPDP Compliance Engine',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      'Cryptographic audit trail • Domain: University-App',
                      style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _openCookieBannerModal,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Cookie Settings',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
