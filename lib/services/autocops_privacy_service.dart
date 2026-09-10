import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
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
  static const String keyLang = 'autocops_cookie_lang_$domain';
  static const String keyTranslationsPrefix = '_ac_translations';

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

  static const Map<String, Map<String, String>> supportedLanguages = {
    'en': {'native': 'English', 'name': 'English', 'dir': 'ltr'},
    'hi': {'native': 'हिन्दी', 'name': 'Hindi', 'dir': 'ltr'},
    'ta': {'native': 'தமிழ்', 'name': 'Tamil', 'dir': 'ltr'},
    'te': {'native': 'తెలుగు', 'name': 'Telugu', 'dir': 'ltr'},
    'bn': {'native': 'বাংলা', 'name': 'Bengali', 'dir': 'ltr'},
    'mr': {'native': 'मराठी', 'name': 'Marathi', 'dir': 'ltr'},
    'gu': {'native': 'ગુજરાતી', 'name': 'Gujarati', 'dir': 'ltr'},
    'kn': {'native': 'ಕನ್ನಡ', 'name': 'Kannada', 'dir': 'ltr'},
    'ml': {'native': 'മലയാളം', 'name': 'Malayalam', 'dir': 'ltr'},
    'pa': {'native': 'ਪੰਜਾਬੀ', 'name': 'Punjabi', 'dir': 'ltr'},
    'ur': {'native': 'اردو', 'name': 'Urdu', 'dir': 'rtl'},
    'or': {'native': 'ଓଡ଼ିଆ', 'name': 'Odia', 'dir': 'ltr'},
    'as': {'native': 'অসমীয়া', 'name': 'Assamese', 'dir': 'ltr'},
    'mai': {'native': 'मैथिली', 'name': 'Maithili', 'dir': 'ltr'},
    'sa': {'native': 'संस्कृतम्', 'name': 'Sanskrit', 'dir': 'ltr'},
    'ne': {'native': 'नेपाली', 'name': 'Nepali', 'dir': 'ltr'},
    'sd': {'native': 'سنڌي', 'name': 'Sindhi', 'dir': 'rtl'},
    'ks': {'native': 'کٲشُر', 'name': 'Kashmiri', 'dir': 'rtl'},
    'kok': {'native': 'कोंकणी', 'name': 'Konkani', 'dir': 'ltr'},
    'doi': {'native': 'डोगरी', 'name': 'Dogri', 'dir': 'ltr'},
    'mni': {'native': 'মৈতৈলোন্', 'name': 'Manipuri', 'dir': 'ltr'},
    'sat': {'native': 'ᱥᱟᱱᱛᱟᱲᱤ', 'name': 'Santali', 'dir': 'ltr'},
    'brx': {'native': 'बर’', 'name': 'Bodo', 'dir': 'ltr'},
  };

  static const Map<String, String> fallbackHi = {
    'title': 'हम आपकी निजता का सम्मान करते हैं',
    'message':
        'हम आपके अनुभव को बेहतर बनाने और ट्रैफ़िक का विश्लेषण करने के लिए कुकीज़ का उपयोग करते हैं। आप सभी स्वीकार कर सकते हैं, गैर-आवश्यक अस्वीकार कर सकते हैं, या अपनी पसंद अनुकूलित कर सकते हैं।',
    'accept_all': 'सभी स्वीकार करें',
    'reject_all': 'गैर-आवश्यक अस्वीकार करें',
    'customize': 'अनुकूलित करें',
    'save_preferences': 'प्राथमिकताएँ सहेजें',
    'back': 'वापस',
    'cat_essential': 'आवश्यक कुकीज़',
    'cat_functional': 'कार्यात्मक कुकीज़',
    'cat_analytics': 'विश्लेषण कुकीज़',
    'cat_marketing': 'विपणन कुकीज़',
    'learn_more': 'हमारी गोपनीयता सूचना में और जानें',
    'draft_notice':
        'अनुवाद कानूनी समीक्षा में है — अंग्रेज़ी संस्करण प्रामाणिक है।',
  };

  static const Map<String, String> fallbackEn = {
    'title': 'We value your privacy',
    'message':
        'We use cookies to enhance your experience and analyse traffic. You can accept all, reject non-essential, or customise your choices.',
    'accept_all': 'Accept All',
    'reject_all': 'Reject Non Essential',
    'customize': 'Customise',
    'save_preferences': 'Save Preferences',
    'back': 'Back',
    'cat_essential': 'Essential cookies',
    'cat_functional': 'Functional cookies',
    'cat_analytics': 'Analytics cookies',
    'cat_marketing': 'Marketing cookies',
    'learn_more': 'Learn more in our privacy notice',
    'draft_notice':
        'Translation is under legal review — English version is authoritative.',
  };

  String? _visitorId;
  AutoCopsConsentState? _consentState;
  String _currentLanguage = 'en';
  final Map<String, Map<String, String>> _translationCache = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String get visitorId => _visitorId ?? '';
  AutoCopsConsentState? get consentState => _consentState;
  String get currentLanguage => _currentLanguage;

  bool isRtl(String lang) => supportedLanguages[lang]?['dir'] == 'rtl';

  bool get hasGivenConsent {
    if (_consentState == null) return false;
    return _consentState!.version == currentConfigVersion;
  }

  bool isCategoryAccepted(String category) {
    if (category == catStrictlyNecessary) return true;
    if (_consentState == null) return false;
    return _consentState!.acceptedCategories.contains(category);
  }

  String detectDeviceLanguage() {
    try {
      final locale = PlatformDispatcher.instance.locale;
      final langCode = locale.languageCode.toLowerCase();
      if (supportedLanguages.containsKey(langCode)) {
        return langCode;
      }
      for (final loc in PlatformDispatcher.instance.locales) {
        final code = loc.languageCode.toLowerCase();
        if (supportedLanguages.containsKey(code)) {
          return code;
        }
      }
    } catch (e) {
      debugPrint('[AutoCops] Error detecting device locale: $e');
    }
    return 'en';
  }

  Future<void> setLanguage(String lang) async {
    if (!supportedLanguages.containsKey(lang)) return;
    _currentLanguage = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyLang, lang);
    } catch (_) {}
  }

  Future<Map<String, String>> fetchTranslations(String lang) async {
    if (_translationCache.containsKey(lang)) {
      return _translationCache[lang]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('${keyTranslationsPrefix}_$lang');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(cachedStr);
        final Map<String, String> mapped =
            decoded.map((k, v) => MapEntry(k, v.toString()));
        _translationCache[lang] = mapped;
        // Asynchronous background refresh
        _fetchRemoteTranslations(lang);
        return mapped;
      }
    } catch (e) {
      debugPrint('[AutoCops] Error reading translation cache: $e');
    }

    if (lang == 'hi') {
      _translationCache[lang] = Map.from(fallbackHi);
    } else {
      _translationCache[lang] = Map.from(fallbackEn);
    }

    // Query remote API
    final remote = await _fetchRemoteTranslations(lang);
    if (remote.isNotEmpty) {
      return remote;
    }

    return _translationCache[lang]!;
  }

  Future<Map<String, String>> _fetchRemoteTranslations(String lang) async {
    final urls = [
      'https://app.autocops.org/v1/public/i18n/banner/$lang',
      'https://autocops.org/v1/public/i18n/banner/$lang',
    ];

    for (final url in urls) {
      try {
        final uri = Uri.parse(url);
        final res = await http.get(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data is Map && data['strings'] is Map) {
            final strings = data['strings'] as Map;
            final mapped = strings.map((k, v) => MapEntry(k.toString(), v.toString()));
            _translationCache[lang] = mapped;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('${keyTranslationsPrefix}_$lang', jsonEncode(mapped));
            return mapped;
          }
        }
      } catch (e) {
        debugPrint('[AutoCops] Translation fetch warning ($url): $e');
      }
    }
    return {};
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

      // Detect language
      final savedLang = prefs.getString(keyLang);
      if (savedLang != null && supportedLanguages.containsKey(savedLang)) {
        _currentLanguage = savedLang;
      } else {
        _currentLanguage = detectDeviceLanguage();
      }

      // Prefetch current language translations
      fetchTranslations(_currentLanguage);
    } catch (e) {
      debugPrint('SharedPreferences init fallback: $e');
      _visitorId ??= _generateUuidV4();
      _currentLanguage = detectDeviceLanguage();
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

  static const String apiKey = 'dpdp_c15c90e072957a2239a520f4a1372340bed2bce94d713d9f';

  /// Captures individual DPDP consent records for each checked form purpose
  Future<FormConsentResult> captureFormConsent({
    required String email,
    required String fullName,
    required String phone,
    required List<FormConsentItem> items,
  }) async {
    final List<String> registeredIds = [];
    final endpoints = [
      'https://app.autocops.org/v1/consent/external/capture',
      'https://autocops.org/v1/consent/external/capture',
    ];

    for (final item in items) {
      final payload = {
        'consent_method': 'EXPLICIT',
        'email': email.trim(),
        'data_principal_email': email.trim(),
        'data_principal_name': fullName.trim(),
        'name': fullName.trim(),
        'data_principal_phone': phone.trim(),
        'phone': phone.trim(),
        'geo_jurisdiction': 'IN',
        'language': _currentLanguage,
        'legal_basis': 'CONSENT',
        'notice_version': 'www.autocops.org-v1',
        'purpose': item.purposeDesc,
        'purpose_category': item.purposeCategory,
        'purpose_id': item.purposeId,
        'visitor_id': visitorId,
        'data_principal_id': visitorId,
      };

      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse(endpoint);
          final response = await http
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json; charset=UTF-8',
                  'X-API-Key': apiKey,
                  'User-Agent': 'VeritasUniversityApp/1.0 (Android; AutoCops-SDK/2.5)',
                },
                body: jsonEncode(payload),
              )
              .timeout(const Duration(seconds: 8));

          debugPrint('[AutoCops Form Consent] $endpoint response: ${response.statusCode} - ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            try {
              final resData = jsonDecode(response.body);
              if (resData is Map && resData['consent_id'] != null) {
                final cId = resData['consent_id'].toString();
                if (!registeredIds.contains(cId)) {
                  registeredIds.add(cId);
                }
              }
            } catch (_) {}
            break;
          }
        } catch (e) {
          debugPrint('[AutoCops Form Consent] Error capturing ${item.purposeId} at $endpoint: $e');
        }
      }
    }

    return FormConsentResult(
      success: registeredIds.isNotEmpty,
      consentIds: registeredIds,
    );
  }

  /// Initiates DSR Challenge (Stage 1 OTP generation)
  Future<DsrInitiateResult> initiateDsrChallenge({
    required String name,
    required String email,
    required String requestType,
    required String description,
  }) async {
    final payload = {
      'name': name.trim(),
      'email': email.trim(),
      'request_type': requestType,
      'description': description.trim(),
      'domain': domain,
    };

    final endpoints = [
      'https://app.autocops.org/v1/public/dsr/initiate',
      'https://autocops.org/v1/public/dsr/initiate',
    ];

    String? lastError;
    for (final endpoint in endpoints) {
      try {
        final uri = Uri.parse(endpoint);
        final response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'User-Agent': 'VeritasUniversityApp/1.0 (Android; AutoCops-SDK/2.5)',
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));

        debugPrint('[AutoCops DSR Initiate] $endpoint returned ${response.statusCode}: ${response.body}');
        final dynamic data = jsonDecode(response.body);

        if (data is Map && (response.statusCode == 200 || data['ok'] == true)) {
          return DsrInitiateResult(
            ok: true,
            challengeId: data['challenge_id']?.toString(),
            emailMasked: data['email_masked']?.toString(),
            message: data['message']?.toString(),
          );
        } else if (data is Map) {
          final err = (data['detail'] ?? data['message'] ?? 'Failed with status ${response.statusCode}').toString();
          if (response.statusCode < 500) {
            return DsrInitiateResult(ok: false, error: err);
          }
          lastError = err;
        }
      } catch (e) {
        debugPrint('[AutoCops DSR Initiate] Error at $endpoint: $e');
        lastError = e.toString();
      }
    }

    return DsrInitiateResult(
      ok: false,
      error: lastError ?? 'Unable to connect to AutoCops DSR service.',
    );
  }

  /// Verifies OTP and logs official DSR Request (Stage 2)
  Future<DsrSubmitResult> submitDsrVerification({
    required String name,
    required String email,
    required String requestType,
    required String description,
    required String challengeId,
    required String otp,
  }) async {
    final cleanOtp = otp.trim();
    final payload = {
      'name': name.trim(),
      'email': email.trim(),
      'request_type': requestType,
      'description': description.trim(),
      'domain': domain,
      'challenge_id': challengeId.trim(),
      'otp': cleanOtp,
      'code': cleanOtp,
    };

    final endpoints = [
      'https://app.autocops.org/v1/public/dsr',
      'https://autocops.org/v1/public/dsr',
    ];

    String? lastError;
    for (final endpoint in endpoints) {
      try {
        final uri = Uri.parse(endpoint);
        final response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'User-Agent': 'VeritasUniversityApp/1.0 (Android; AutoCops-SDK/2.5)',
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));

        debugPrint('[AutoCops DSR Submit] $endpoint returned ${response.statusCode}: ${response.body}');
        final dynamic data = jsonDecode(response.body);

        if (data is Map && (response.statusCode == 200 || data['ok'] == true)) {
          return DsrSubmitResult(
            ok: true,
            requestId: data['request_id']?.toString(),
            status: data['status']?.toString() ?? 'LOGGED',
          );
        } else if (data is Map) {
          final err = (data['detail'] ?? data['message'] ?? 'Verification failed').toString();
          if (response.statusCode < 500) {
            return DsrSubmitResult(ok: false, error: err);
          }
          lastError = err;
        }
      } catch (e) {
        debugPrint('[AutoCops DSR Submit] Error at $endpoint: $e');
        lastError = e.toString();
      }
    }

    return DsrSubmitResult(
      ok: false,
      error: lastError ?? 'Unable to verify DSR code. Please try again.',
    );
  }
}

class FormConsentItem {
  final String purposeId;
  final String purposeCategory;
  final String purposeDesc;

  const FormConsentItem({
    required this.purposeId,
    required this.purposeCategory,
    required this.purposeDesc,
  });
}

class FormConsentResult {
  final bool success;
  final List<String> consentIds;
  final String? errorMessage;

  const FormConsentResult({
    required this.success,
    required this.consentIds,
    this.errorMessage,
  });
}

class DsrInitiateResult {
  final bool ok;
  final String? challengeId;
  final String? emailMasked;
  final String? message;
  final String? error;

  const DsrInitiateResult({
    required this.ok,
    this.challengeId,
    this.emailMasked,
    this.message,
    this.error,
  });
}

class DsrSubmitResult {
  final bool ok;
  final String? requestId;
  final String? status;
  final String? error;

  const DsrSubmitResult({
    required this.ok,
    this.requestId,
    this.status,
    this.error,
  });
}

