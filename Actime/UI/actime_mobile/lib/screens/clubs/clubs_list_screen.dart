import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav.dart';
import '../../components/event_card.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatelessWidget {
  const ClubsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ActimeAppBar(
        showSearch: true,
        showFilter: true,
        onProfileTap: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingDefault),
        children: [
          ClubCard(
            name: 'Velež',
            sport: 'Football',
            email: 'info@velez.ba',
            phone: '+387 62 674 889',
            members: '89',
            icon: Icons.sports_soccer,
            iconColor: AppColors.red,
            isFavorite: true,
            onTap: () => _navigateToDetail(context),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ClubCard(
            name: 'Student',
            sport: 'Volleyball',
            email: 'info@student.ba',
            phone: '+387 62 665 889',
            members: '114',
            icon: Icons.sports_volleyball,
            iconColor: AppColors.orange,
            onTap: () => _navigateToDetail(context),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ClubCard(
            name: 'Velež',
            sport: 'Football',
            email: 'info@velez.ba',
            phone: '+387 62 674 889',
            members: '89',
            icon: Icons.sports_soccer,
            iconColor: AppColors.red,
            onTap: () => _navigateToDetail(context),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ClubCard(
            name: 'Student',
            sport: 'Volleyball',
            email: 'info@student.ba',
            phone: '+387 62 665 889',
            members: '114',
            icon: Icons.sports_volleyball,
            iconColor: AppColors.orange,
            onTap: () => _navigateToDetail(context),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClubDetailScreen()),
    );
  }
}
