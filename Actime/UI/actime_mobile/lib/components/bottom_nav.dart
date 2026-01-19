import 'package:flutter/material.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/events/events_list_screen.dart';
import '../screens/clubs/clubs_list_screen.dart';

/// Bottom navigation for non-logged users
/// Events and Clubs are accessible, History requires login
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
        // Events - accessible to all
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventsListScreen(isLoggedIn: false)),
        );
        break;
      case 1:
        // Clubs - accessible to all
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClubsListScreen(isLoggedIn: false)),
        );
        break;
      case 2:
        // History - requires login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use -1 for landing page (no selection), clamp to valid range for display
    final safeIndex = currentIndex < 0 ? 0 : currentIndex;

    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: currentIndex < 0 ? Colors.grey : const Color(0xFF0D7C8C),
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