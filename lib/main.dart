import 'package:flutter/material.dart';
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
      home: const MainNavigationScreen(),
    );
  }
}
