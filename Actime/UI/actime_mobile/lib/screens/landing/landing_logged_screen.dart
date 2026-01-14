import 'package:flutter/material.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav.dart';

class LandingPageLogged extends StatelessWidget {
  const LandingPageLogged({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        onFavoriteTap: () {
          print('Show favorites');
        },
        onProfileTap: () {
          print('Navigate to Profile');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Clubs & Organizations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D7C8C),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF0D7C8C)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildClubCard(
                      'Velež',
                      'Football',
                      '89 members',
                      Icons.sports_soccer,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildClubCard(
                      'Student',
                      'Volleyball',
                      '89 members',
                      Icons.sports_volleyball,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D7C8C),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF0D7C8C)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            _buildEventCard(
              'Bjelašnica hiking trip',
              'Free',
              '11.10.2022',
              'Bjelašnica',
              '205',
              Icons.hiking,
            ),
            _buildEventCard(
              'Volleyball tournament',
              '\$10',
              '21.12.2022',
              'USCR Midhat Hujdur',
              '31',
              Icons.sports_volleyball,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildClubCard(String name, String sport, String members, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(members, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 4),
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String price, String date, String location, String participants, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D7C8C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(price, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite_border, size: 20, color: Color(0xFF0D7C8C)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(participants, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D7C8C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(location, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}