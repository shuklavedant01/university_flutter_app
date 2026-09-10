import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'services/autocops_privacy_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AutoCopsPrivacyService.instance.initialize();
  runApp(const VeritasUniversityApp());
}

class VeritasUniversityApp extends StatelessWidget {
  const VeritasUniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veritas University',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ta'),
        Locale('te'),
        Locale('bn'),
        Locale('mr'),
        Locale('gu'),
        Locale('kn'),
        Locale('ml'),
        Locale('pa'),
        Locale('ur'),
        Locale('or'),
        Locale('as'),
        Locale('mai'),
        Locale('sa'),
        Locale('ne'),
        Locale('sd'),
        Locale('ks'),
        Locale('kok'),
        Locale('doi'),
        Locale('mni'),
        Locale('sat'),
        Locale('brx'),
      ],
      home: const MainNavigationScreen(),
    );
  }
}
