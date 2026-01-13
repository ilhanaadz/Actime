import 'package:flutter/material.dart';
import 'edit_organization_profile_screen.dart';
import '../events/events_list_screen.dart';

class OrganizationProfileScreen extends StatelessWidget {
  const OrganizationProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Actime',
            style: TextStyle(
              color: Color(0xFF0D7C8C),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF0D7C8C)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image with volleyball icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.sports_volleyball,
                    size: 60,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            _buildProfileField(
              'Name',
              'Student',
              hasEdit: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditOrganizationProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Category
            _buildProfileField('Category', 'Volleyball'),
            const SizedBox(height: 16),

            // Phone
            _buildProfileField('Phone', '+12027953213'),
            const SizedBox(height: 16),

            // Address
            _buildProfileField('Address', '1894 Arlington Avenue'),
            const SizedBox(height: 16),

            // E-mail
            _buildProfileField('E-mail', 'club@volleyball.com'),
            const SizedBox(height: 16),

            // About us
            _buildProfileField(
              'About us',
              'Practice yoga postures while learning about how yoga can be used to manage stress, improve the mind-body connection, and increase strength and flexibility.',
              isMultiline: true,
            ),
            const SizedBox(height: 32),

            // Bottom Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.event_outlined,
                  'My events',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventsListScreen(),
                      ),
                    );
                  },
                ),
                _buildNavItem(Icons.photo_library_outlined, 'Gallery'),
                _buildNavItem(Icons.people_outline, 'People'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    String value, {
    bool hasEdit = false,
    bool isMultiline = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (hasEdit)
              GestureDetector(
                onTap: onTap,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF0D7C8C),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF0D7C8C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0D7C8C)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF0D7C8C), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
