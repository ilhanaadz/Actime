import 'package:flutter/material.dart';
import '../screens/organization/my_events_org_screen.dart';
import '../screens/organization/people_org_screen.dart';
import '../screens/organization/gallery_org_screen.dart';

class BottomNavOrg extends StatelessWidget {
  final int currentIndex;
  final String organizationId;

  const BottomNavOrg({
    super.key,
    required this.currentIndex,
    required this.organizationId,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyEventsOrgScreen(organizationId: organizationId),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryOrgScreen(organizationId: organizationId),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PeopleOrgScreen(organizationId: organizationId),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use 0 as fallback when currentIndex is invalid (e.g., -1 for profile screen)
    final safeIndex = currentIndex >= 0 && currentIndex < 3 ? currentIndex : 0;

    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: currentIndex >= 0 ? const Color(0xFF0D7C8C) : Colors.grey,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'My events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          label: 'Gallery',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'People',
        ),
      ],
    );
  }
}
