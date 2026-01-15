import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/circle_icon_container.dart';
import '../../components/info_row.dart';
import '../../components/actime_button.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrganizerSection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildTitleSection(),
              const SizedBox(height: AppDimensions.spacingSmall),
              const Text(
                'Hiking',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              const InfoRow(icon: Icons.calendar_today, text: '11.10.2022.'),
              const SizedBox(height: AppDimensions.spacingMedium),
              const InfoRow(icon: Icons.location_on_outlined, text: 'Bjelašnica'),
              const SizedBox(height: AppDimensions.spacingMedium),
              const InfoRow(icon: Icons.attach_money, text: '10'),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildDetailsSection(),
              const SizedBox(height: AppDimensions.spacingXLarge),
              ActimePrimaryButton(
                label: 'Join',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Joined event successfully!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizerSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleIconContainer(
              icon: Icons.hiking,
              iconColor: AppColors.orange,
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organizator',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const Text(
                  '"Alpe"',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            const Text(
              '89',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXSmall),
            Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bjelašnica hiking trip',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium),
        Text(
          'Departing between 06:00am and 07:00am in Lehn at Längenfeld, this demanding long walk lets avid hikers explore the lofty and rugged mountain world of Ötztal Valley. The route winds across amazingly beautiful sceneries and passes four aquatic jewels.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
