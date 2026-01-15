import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../components/pagination_widget.dart';
import '../components/search_sort_header.dart';
import '../components/delete_confirmation_dialog.dart';

class AdminOrganizationsScreen extends StatefulWidget {
  const AdminOrganizationsScreen({super.key});

  @override
  State<AdminOrganizationsScreen> createState() => _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  final _searchController = TextEditingController();
  int? _selectedOrgIndex;
  int _currentPage = 1;
  final int _totalPages = 4;
  String _sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: 'organizations',
      child: _selectedOrgIndex == null
          ? _buildOrganizationsList()
          : _buildOrganizationDetail(),
    );
  }

  Widget _buildOrganizationsList() {
    return Column(
      children: [
        // Header with Search and Sort
        SearchSortHeader(
          title: 'Organizations',
          searchController: _searchController,
          sortItems: [
            const PopupMenuItem(
              value: 'name',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 18),
                  SizedBox(width: 12),
                  Text('Sort by Name'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'members',
              child: Row(
                children: [
                  Icon(Icons.people, size: 18),
                  SizedBox(width: 12),
                  Text('Sort by Members'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'events',
              child: Row(
                children: [
                  Icon(Icons.event, size: 18),
                  SizedBox(width: 12),
                  Text('Sort by Events'),
                ],
              ),
            ),
          ],
          onSortSelected: (value) {
            setState(() => _sortBy = value);
          },
        ),
        
        // Organizations List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: 3,
            itemBuilder: (context, index) => _buildOrganizationCard(index),
          ),
        ),
        
        // Pagination at bottom
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: PaginationWidget(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationCard(int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedOrgIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_volleyball,
                color: Colors.orange,
                size: 40,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Organization Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D7C8C),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '13 events',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  const Text(
                    'Volleyball',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '+12027953213',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '1894 Arlington Avenue',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'club@volleyball.com',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Volleyball is a team sport in which two teams of six players are separated by a net. Each team tries to score points by grounding a ball on the other team\'s court under organized rules.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '89 members',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.grey,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 8),
            
            Icon(Icons.more_vert, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationDetail() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Detail Header with Close Button
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Organization Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedOrgIndex = null),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          
          // Organization Detail Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildGallerySection(),
                  const SizedBox(height: 24),
                  _buildEventsSection(),
                  const SizedBox(height: 24),
                  _buildDeleteButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_volleyball,
              color: Colors.orange,
              size: 70,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Student',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D7C8C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Volleyball',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      'About',
      Text(
        'Volleyball is a team sport in which two teams of six players are separated by a net.',
        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
      ),
    );
  }

  Widget _buildGallerySection() {
    return _buildSection(
      'Gallery',
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, color: Colors.grey[400], size: 40),
          );
        },
      ),
    );
  }

  Widget _buildEventsSection() {
    return _buildSection(
      'Events',
      Column(
        children: [
          _buildEventItem('Bjelašnica hiking trip', '11.10.2022', '205 participants'),
          _buildEventItem('Volleyball tournament', '21.12.2022', '31 participants'),
          _buildEventItem('Training session', '15.11.2022', '45 participants'),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String date, String participants) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date • $participants',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final result = await DeleteConfirmationDialog.show(
            context: context,
            title: 'Delete Organization',
            message: 'Are you sure you want to delete this organization? This action cannot be undone.',
          );
          
          if (result == true && mounted) {
            setState(() => _selectedOrgIndex = null);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Organization deleted successfully')),
            );
          }
        },
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text('Delete Organization'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}