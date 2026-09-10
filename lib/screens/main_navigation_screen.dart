import 'package:flutter/material.dart';
import '../widgets/university_header.dart';
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

  final List<String> _subtitles = [
    'Home',
    'Contact',
    'Dsr / Privacy',
    'Grievance',
    'Academics',
  ];

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
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
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
