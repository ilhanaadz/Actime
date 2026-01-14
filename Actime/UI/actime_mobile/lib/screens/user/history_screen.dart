import 'package:flutter/material.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        onFavoriteTap: () {},
        onProfileTap: () {},
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Color(0xFF0D7C8C)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTab('All', true),
                const SizedBox(width: 12),
                _buildTab('This Month', false),
                const SizedBox(width: 12),
                _buildTab('This Year', false),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Past Events List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildEventCard(
                  'Volleyball tournament',
                  '\$10',
                  '21.09.2022',
                  'USCR Midhat Hujdur',
                  '31',
                  Icons.sports_volleyball,
                  index % 2 == 0,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavUser(currentIndex: 2),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0D7C8C) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF0D7C8C) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isActive ? Colors.white : Colors.grey,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String price,
    String date,
    String location,
    String participants,
    IconData icon,
    bool isCompleted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.orange, size: 24),
              ),
              if (isCompleted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
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
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Attended',
                          style: TextStyle(color: Colors.green, fontSize: 10),
                        ),
                      ),
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