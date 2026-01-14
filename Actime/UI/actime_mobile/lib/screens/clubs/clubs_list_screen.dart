import 'package:flutter/material.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatelessWidget {
  const ClubsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ActimeAppBar(
        showSearch: true,
        showFilter: true,
        onProfileTap: () {
          print('Navigate to Profile');
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildClubItem(
            context,
            'Velež',
            'Football',
            'info@velez.ba',
            '+387 62 674 889',
            '89',
            Icons.sports_soccer,
            Colors.red,
            true,
          ),
          const SizedBox(height: 16),
          _buildClubItem(
            context,
            'Student',
            'Volleyball',
            'info@student.ba',
            '+387 62 665 889',
            '114',
            Icons.sports_volleyball,
            Colors.orange,
            false,
          ),
          const SizedBox(height: 16),
          _buildClubItem(
            context,
            'Velež',
            'Football',
            'info@velez.ba',
            '+387 62 674 889',
            '89',
            Icons.sports_soccer,
            Colors.red,
            false,
          ),
          const SizedBox(height: 16),
          _buildClubItem(
            context,
            'Student',
            'Volleyball',
            'info@student.ba',
            '+387 62 665 889',
            '114',
            Icons.sports_volleyball,
            Colors.orange,
            false,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildClubItem(
    BuildContext context,
    String name,
    String sport,
    String email,
    String phone,
    String members,
    IconData icon,
    Color iconColor,
    bool isFavorite,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClubDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                if (isFavorite)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D7C8C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sport,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    phone,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  members,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D7C8C),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.favorite_border, size: 20, color: Color(0xFF0D7C8C)),
          ],
        ),
      ),
    );
  }
}