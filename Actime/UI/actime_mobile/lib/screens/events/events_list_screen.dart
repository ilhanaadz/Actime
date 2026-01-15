import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav.dart';
import '../../components/actime_text_field.dart';
import '../../components/event_card.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        onFavoriteTap: () {},
        onProfileTap: () {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingDefault),
            child: Row(
              children: [
                const Expanded(
                  child: ActimeSearchField(hintText: 'Search events...'),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.primary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingDefault),
              children: [
                EventCard(
                  title: 'Bjelašnica hiking trip',
                  price: 'Free',
                  date: '11.10.2022',
                  location: 'Bjelašnica',
                  participants: '205',
                  icon: Icons.hiking,
                  onTap: () => _navigateToDetail(context),
                ),
                EventCard(
                  title: 'Volleyball tournament',
                  price: '\$10',
                  date: '21.12.2022',
                  location: 'USCR Midhat Hujdur',
                  participants: '31',
                  icon: Icons.sports_volleyball,
                  onTap: () => _navigateToDetail(context),
                ),
                EventCard(
                  title: 'Bjelašnica hiking trip',
                  price: 'Free',
                  date: '11.10.2022',
                  location: 'Bjelašnica',
                  participants: '205',
                  icon: Icons.hiking,
                  onTap: () => _navigateToDetail(context),
                ),
                EventCard(
                  title: 'Volleyball tournament',
                  price: '\$10',
                  date: '21.12.2022',
                  location: 'USCR Midhat Hujdur',
                  participants: '31',
                  icon: Icons.sports_volleyball,
                  onTap: () => _navigateToDetail(context),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventDetailScreen()),
    );
  }
}
