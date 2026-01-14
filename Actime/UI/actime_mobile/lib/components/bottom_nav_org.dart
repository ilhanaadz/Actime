import 'package:flutter/material.dart';
import '../screens/organization/my_events_org_screen.dart';
import '../screens/organization/enrollment_applications_screen.dart';
import '../screens/user/people_screen.dart';

class BottomNavOrg extends StatelessWidget {
  final int currentIndex;

  const BottomNavOrg({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyEventsOrgScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EnrollmentApplicationsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PeopleScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: const Color(0xFF0D7C8C),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'My Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Applications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Members',
        ),
      ],
    );
  }
}