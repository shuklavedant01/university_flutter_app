import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AutoCopsConsentState {
  final String version;
  final String method;
  final List<String> acceptedCategories;
  final int timestamp;

  const AutoCopsConsentState({
    required this.version,
    required this.method,
    required this.acceptedCategories,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'v': version,
        'method': method,
        'accepted': acceptedCategories,
        'at': timestamp,
      };

  factory AutoCopsConsentState.fromJson(Map<String, dynamic> json) {
    return AutoCopsConsentState(
      version: json['v'] as String? ?? '1.0',
      method: json['method'] as String? ?? 'UNKNOWN',
      acceptedCategories: (json['accepted'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['STRICTLY_NECESSARY'],
      timestamp: json['at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class AutoCopsPrivacyService extends ChangeNotifier {
  static final AutoCopsPrivacyService instance = AutoCopsPrivacyService._internal();

  AutoCopsPrivacyService._internal();

  static const String domain = 'University-App';
  static const String apiBase = 'https://app.autocops.org';
  static const String currentConfigVersion = '1.0';

  static const String keyConsent = 'autocops_cookie_consent_$domain';
  static const String keyVisitorId = '_ac_visitor_id';

  // Supported Categories
  static const String catStrictlyNecessary = 'STRICTLY_NECESSARY';
  static const String catAnalytics = 'ANALYTICS';
  static const String catFunctional = 'FUNCTIONAL';
  static const String catMarketing = 'MARKETING';

  static const List<String> allCategories = [
    catStrictlyNecessary,
    catAnalytics,
    catFunctional,
    catMarketing,
  ];

  String? _visitorId;
  AutoCopsConsentState? _consentState;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String get visitorId => _visitorId ?? '';
  AutoCopsConsentState? get consentState => _consentState;

  bool get hasGivenConsent {
    if (_consentState == null) return false;
    return _consentState!.version == currentConfigVersion;
  }

  bool isCategoryAccepted(String category) {
    if (category == catStrictlyNecessary) return true;
    if (_consentState == null) return false;
    return _consentState!.acceptedCategories.contains(category);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load or create RFC 4122 v4 visitor ID
      _visitorId = prefs.getString(keyVisitorId);
      if (_visitorId == null || _visitorId!.isEmpty) {
        _visitorId = _generateUuidV4();
        await prefs.setString(keyVisitorId, _visitorId!);
      }

      // Load existing consent decision
      final consentJson = prefs.getString(keyConsent);
      if (consentJson != null && consentJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(consentJson) as Map<String, dynamic>;
          _consentState = AutoCopsConsentState.fromJson(decoded);
        } catch (e) {
          debugPrint('Error parsing stored consent state: $e');
        }
      }
    } catch (e) {
      debugPrint('SharedPreferences init fallback: $e');
      _visitorId ??= _generateUuidV4();
    }

    _isInitialized = true;
    notifyListeners();
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10xx
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Accept All Cookies (BANNER_ACCEPT_ALL)
  Future<void> acceptAll() async {
    await recordConsent(
      method: 'BANNER_ACCEPT_ALL',
      accepted: List.from(allCategories),
      rejected: [],
    );
  }

  /// Reject Optional Cookies (BANNER_REJECT_ALL)
  Future<void> rejectAll() async {
    await recordConsent(
      method: 'BANNER_REJECT_ALL',
      accepted: [catStrictlyNecessary],
      rejected: [catAnalytics, catFunctional, catMarketing],
    );
  }

  /// Save Customized Preferences (BANNER_CUSTOMIZE_CONFIRMED)
  Future<void> saveCustomPreferences({
    required bool analytics,
    required bool functional,
    required bool marketing,
  }) async {
    final accepted = <String>[catStrictlyNecessary];
    final rejected = <String>[];

    if (analytics) {
      accepted.add(catAnalytics);
    } else {
      rejected.add(catAnalytics);
    }

    if (functional) {
      accepted.add(catFunctional);
    } else {
      rejected.add(catFunctional);
    }

    if (marketing) {
      accepted.add(catMarketing);
    } else {
      rejected.add(catMarketing);
    }

    await recordConsent(
      method: 'BANNER_CUSTOMIZE_CONFIRMED',
      accepted: accepted,
      rejected: rejected,
    );
  }

  /// Record consent, persist locally, and transmit asynchronously to AutoCops API
  Future<void> recordConsent({
    required String method,
    required List<String> accepted,
    required List<String> rejected,
  }) async {
    // Ensure Strictly Necessary is always accepted
    if (!accepted.contains(catStrictlyNecessary)) {
      accepted.insert(0, catStrictlyNecessary);
    }
    rejected.remove(catStrictlyNecessary);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _consentState = AutoCopsConsentState(
      version: currentConfigVersion,
      method: method,
      acceptedCategories: accepted,
      timestamp: timestamp,
    );

    // 1. Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyConsent, jsonEncode(_consentState!.toJson()));
    } catch (e) {
      debugPrint('Error saving consent state to storage: $e');
    }

    notifyListeners();

    // 2. Dispatch payload asynchronously to AutoCops Compliance Engine
    _dispatchConsentToAutoCops(
      accepted: accepted,
      rejected: rejected,
      method: method,
    );
  }

  void _dispatchConsentToAutoCops({
    required List<String> accepted,
    required List<String> rejected,
    required String method,
  }) async {
    // Normalize category keys to lowercase for AutoCops compliance engine
    final acceptedCategories = accepted.map((c) => c.toLowerCase()).toList();
    final rejectedCategories = rejected.map((c) => c.toLowerCase()).toList();

    final payload = {
      'categories_accepted': acceptedCategories,
      'categories_rejected': rejectedCategories,
      'consent_method': method,
      'data_principal_id': visitorId,
      'domain': domain,
      'geo_jurisdiction': 'IN',
      'user_agent': 'VeritasUniversityApp/1.0 (Android; AutoCops-SDK/2.5)',
      'observed_cookies': ['_ac_visitor_id', 'session_id'],
    };

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'User-Agent': 'VeritasUniversityApp/1.0 (Android; AutoCops-SDK/2.5)',
    };

    final encodedPayload = jsonEncode(payload);

    // Primary and secondary AutoCops endpoints
    final endpoints = [
      'https://app.autocops.org/v1/cookies/consents',
      'https://autocops.org/v1/cookies/consents',
    ];

    for (final endpoint in endpoints) {
      try {
        final uri = Uri.parse(endpoint);
        final response = await http
            .post(
              uri,
              headers: headers,
              body: encodedPayload,
            )
            .timeout(const Duration(seconds: 8));

        debugPrint('[AutoCops] Consent dispatched to $endpoint: ${response.statusCode} - ${response.body}');
      } catch (e) {
        debugPrint('[AutoCops] Network transmission note ($endpoint): $e');
      }
    }

    // Also dispatch observed cookies for tracking verification
    final observedEndpoints = [
      'https://app.autocops.org/v1/cookies/observed',
      'https://autocops.org/v1/cookies/observed',
    ];

    final obsPayload = jsonEncode({
      'domain': domain,
      'data_principal_id': visitorId,
      'categories_accepted': acceptedCategories,
      'categories_rejected': rejectedCategories,
      'cookie_names': ['_ac_visitor_id', 'session_id'],
    });

    for (final endpoint in observedEndpoints) {
      try {
        final uri = Uri.parse(endpoint);
        await http
            .post(
              uri,
              headers: headers,
              body: obsPayload,
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
  }
}
