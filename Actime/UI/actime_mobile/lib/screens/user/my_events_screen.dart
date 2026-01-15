import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../components/event_card.dart';
import '../../components/tab_button.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My events',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingDefault),
            child: ActimeTabBar(
              tabs: const ['Upcoming', 'Past'],
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
          const SizedBox(height: AppSizes.spacingDefault),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingDefault),
              itemCount: 5,
              itemBuilder: (context, index) {
                return EventCard(
                  title: 'Bjelašnica hiking trip',
                  price: 'Free',
                  date: '11.10.2022',
                  location: 'Bjelašnica',
                  participants: '205',
                  icon: Icons.hiking,
                  showFavorite: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingDefault),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.borderLight,
            child: Icon(Icons.person, size: 30, color: AppColors.textMuted),
          ),
          const SizedBox(width: AppSizes.spacingDefault),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'john.doe@email.com',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
