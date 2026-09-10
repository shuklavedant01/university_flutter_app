import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GrievanceFilingSheet extends StatefulWidget {
  final bool isAnonymous;
  final Function(String domain, String summary)? onSubmit;

  const GrievanceFilingSheet({
    super.key,
    this.isAnonymous = false,
    this.onSubmit,
  });

  @override
  State<GrievanceFilingSheet> createState() => _GrievanceFilingSheetState();
}

class _GrievanceFilingSheetState extends State<GrievanceFilingSheet> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDomain = 'Academic & Grading Review';
  final TextEditingController _summaryController = TextEditingController();
  bool _hasFileAttached = false;
  bool _isSubmitting = false;

  final List<String> _domains = [
    'Academic & Grading Review',
    'Administrative & Financial Discrepancy',
    'Title IX & Discriminatory Conduct',
    'Campus Facilities & Inclusivity',
  ];

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onSubmit?.call(_selectedDomain, _summaryController.text);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isAnonymous
                        ? 'Anonymous Grievance docket successfully submitted & encrypted!'
                        : 'Confidential Docket #GRV-9852 filed with Ombudsman Secretariat.',
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock, color: AppColors.secondary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Confidential Docket Entry',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              if (widget.isAnonymous) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.visibility_off, size: 16, color: AppColors.warning),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anonymous Mode Active: Your student ID and metadata will be stripped from this docket.',
                          style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Primary Grievance Domain',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedDomain,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: _domains
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d, style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDomain = val);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Factual Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _summaryController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Provide incident timeline, individuals involved, and specific impact...',
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 10) {
                    return 'Please describe the grievance in at least 10 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() => _hasFileAttached = !_hasFileAttached);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _hasFileAttached ? AppColors.surfaceLow : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasFileAttached ? AppColors.secondary : AppColors.outlineVariant,
                      style: BorderStyle.solid,
                      width: _hasFileAttached ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _hasFileAttached ? Icons.check_circle : Icons.cloud_upload_outlined,
                        size: 28,
                        color: _hasFileAttached ? AppColors.secondary : AppColors.primary,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _hasFileAttached
                            ? 'Attached: Incident_Log_Statement.pdf (1.2 MB)'
                            : 'Upload Corroborative Evidence',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _hasFileAttached ? AppColors.secondary : AppColors.primary,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PDF, PNG, MP3 up to 25MB (End-to-end encrypted)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(_isSubmitting ? 'Encrypting & Transmitting...' : 'Submit to Ombudsman Secretariat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
