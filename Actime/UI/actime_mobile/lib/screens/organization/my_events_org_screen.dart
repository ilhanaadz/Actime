import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/event_card.dart';
import '../../components/tab_button.dart';
import '../../components/circle_icon_container.dart';

class MyEventsOrgScreen extends StatefulWidget {
  const MyEventsOrgScreen({super.key});

  @override
  State<MyEventsOrgScreen> createState() => _MyEventsOrgScreenState();
}

class _MyEventsOrgScreenState extends State<MyEventsOrgScreen> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOrganizationHeader(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingDefault),
            child: ActimeTabBar(
              tabs: const ['Active', 'Past'],
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingDefault),
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
                  showEditButton: true,
                  onEditTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingDefault),
      child: Row(
        children: [
          CircleIconContainer.large(
            icon: Icons.sports_volleyball,
            iconColor: AppColors.orange,
          ),
          const SizedBox(width: AppDimensions.spacingDefault),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Volleyball',
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
