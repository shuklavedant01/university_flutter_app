import 'package:flutter/material.dart';
import '../widgets/university_header.dart';
import '../widgets/autocops_privacy_banner.dart';
import '../services/autocops_privacy_service.dart';
import 'home/campus_home_screen.dart';
import 'contact/contact_us_screen.dart';
import 'dsr/data_subject_rights_screen.dart';
import 'grievance/grievance_redressal_screen.dart';
import 'academics/academics_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _showPrivacyBanner = true;

  final List<String> _subtitles = [
    'Home',
    'Contact',
    'Dsr / Privacy',
    'Grievance',
    'Academics',
  ];

  @override
  void initState() {
    super.initState();
    final service = AutoCopsPrivacyService.instance;
    _showPrivacyBanner = !service.hasGivenConsent;
    service.addListener(_onPrivacyStateChanged);
  }

  @override
  void dispose() {
    AutoCopsPrivacyService.instance.removeListener(_onPrivacyStateChanged);
    super.dispose();
  }

  void _onPrivacyStateChanged() {
    if (mounted) {
      setState(() {
        _showPrivacyBanner = !AutoCopsPrivacyService.instance.hasGivenConsent;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CampusHomeScreen(onNavigateToTab: _onTabTapped),
      const ContactUsScreen(),
      const DataSubjectRightsScreen(),
      const GrievanceRedressalScreen(),
      const AcademicsScreen(),
    ];

    return Scaffold(
      appBar: UniversityHeader(
        subtitle: _subtitles[_currentIndex],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          if (_showPrivacyBanner)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AutoCopsPrivacyBanner(
                onConsentRecorded: () {
                  setState(() {
                    _showPrivacyBanner = false;
                  });
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone_outlined),
            activeIcon: Icon(Icons.contact_phone),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: 'Privacy DSR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel_outlined),
            activeIcon: Icon(Icons.gavel),
            label: 'Grievances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Academics',
          ),
        ],
      ),
    );
  }
}
