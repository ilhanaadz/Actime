import 'package:flutter/material.dart';
import '../screens/events/events_list_screen.dart';
import '../screens/clubs/clubs_list_screen.dart';
import '../screens/user/my_events_screen.dart';

class BottomNavUser extends StatelessWidget {
  final int currentIndex;

  const BottomNavUser({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventsListScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClubsListScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyEventsScreen()),
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
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Clubs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'My Events',
        ),
      ],
    );
  }
}