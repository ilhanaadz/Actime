import 'package:flutter/material.dart';
import '../screens/events/events_list_screen.dart';
import '../screens/clubs/clubs_list_screen.dart';
import '../screens/user/history_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    // Avoid navigating to the same page
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        // Navigate to Events
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventsListScreen()),
        );
        break;
      case 1:
        // Navigate to Clubs
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClubsListScreen()),
        );
        break;
      case 2:
        // Navigate to History
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
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
          label: 'History',
        ),
      ],
    );
  }
}