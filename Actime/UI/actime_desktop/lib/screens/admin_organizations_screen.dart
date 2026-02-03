import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../components/pagination_widget.dart';
import '../components/search_sort_header.dart';
import '../components/delete_confirmation_dialog.dart';
import '../services/services.dart';
import '../models/models.dart';

class AdminOrganizationsScreen extends StatefulWidget {
  const AdminOrganizationsScreen({super.key});

  @override
  State<AdminOrganizationsScreen> createState() => _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  final _searchController = TextEditingController();
  final _organizationService = OrganizationService();

  Organization? _selectedOrg;
  int _currentPage = 1;
  int _totalPages = 1;
  String _sortBy = 'name';
  bool _isLoading = true;
  String? _error;
  List<Organization> _organizations = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty || _searchController.text.length >= 2) {
      setState(() => _currentPage = 1);
      _loadOrganizations();
    }
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _organizationService.getOrganizations(
        page: _currentPage,
        perPage: 10,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        sortBy: _sortBy,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _organizations = response.data!.data;
          _totalPages = response.data!.lastPage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load organizations';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection error';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOrganizationDetails(int id) async {
    setState(() => _isLoading = true);

    try {
      final response = await _organizationService.getOrganizationById(id);

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _selectedOrg = response.data;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to load organization details'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteOrganization(Organization org) async {
    final result = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Delete Organization',
      message: 'Are you sure you want to delete ${org.name}? This action cannot be undone.',
    );

    if (result != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await _organizationService.deleteOrganization(org.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${org.name} deleted successfully')),
        );
        setState(() => _selectedOrg = null);
        _loadOrganizations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to delete organization'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: 'organizations',
      child: _selectedOrg == null
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
              value: 'Name',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 18),
                  SizedBox(width: 12),
                  Text('Sort by Name'),
                ],
              ),
            ),
          ],
          onSortSelected: (value) {
            setState(() {
              _sortBy = value;
              _currentPage = 1;
            });
            _loadOrganizations();
          },
        ),

        // Organizations List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorState()
                  : _organizations.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _organizations.length,
                          itemBuilder: (context, index) =>
                              _buildOrganizationCard(_organizations[index]),
                        ),
        ),

        // Pagination at bottom
        if (!_isLoading && _error == null && _organizations.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: PaginationWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadOrganizations();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadOrganizations,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No organizations found for "${_searchController.text}"'
                : 'No organizations found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(Organization org) {
    return GestureDetector(
      onTap: () => _loadOrganizationDetails(org.id),
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
              child: org.logo != null
                  ? Image.network(
                      org.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.apartment,
                        color: Colors.orange,
                        size: 40,
                      ),
                    )
                  : const Icon(
                      Icons.apartment,
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
                      Expanded(
                        child: Text(
                          org.name,
                          style: const TextStyle(
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
                            '${org.eventsCount} events',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (org.phone != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      org.phone!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],

                  if (org.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      org.address!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],

                  if (org.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      org.email!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],

                  if (org.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      org.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${org.membersCount} members',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationDetail() {
    final org = _selectedOrg!;

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
                  onPressed: () => setState(() => _selectedOrg = null),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Organization Detail Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection(org),
                        const SizedBox(height: 24),
                        _buildAboutSection(org),
                        const SizedBox(height: 24),
                        if (org.gallery != null && org.gallery!.isNotEmpty) ...[
                          _buildGallerySection(org),
                          const SizedBox(height: 24),
                        ],
                        _buildDeleteButton(org),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(Organization org) {
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
            child: org.logo != null
                ? ClipOval(
                    child: Image.network(
                      org.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.apartment,
                        color: Colors.orange,
                        size: 70,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.apartment,
                    color: Colors.orange,
                    size: 70,
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            org.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D7C8C),
            ),
          ),
          if (org.email != null) ...[
            const SizedBox(height: 8),
            Text(
              org.email!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(Icons.people, '${org.membersCount} members'),
              const SizedBox(width: 16),
              _buildStatChip(Icons.event, '${org.eventsCount} events'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Organization org) {
    return _buildSection(
      'About',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (org.description != null)
            Text(
              org.description!,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
            ),
          if (org.address != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(org.address!, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ],
          if (org.phone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(org.phone!, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ],
          if (org.website != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.language, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(org.website!, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGallerySection(Organization org) {
    if (org.gallery == null || org.gallery!.isEmpty) {
      return _buildSection(
        'Gallery',
        const Text('No gallery images available'),
      );
    }

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
        itemCount: org.gallery!.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                org.gallery![index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.image, color: Colors.grey[400], size: 40),
              ),
            ),
          );
        },
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

  Widget _buildDeleteButton(Organization org) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _deleteOrganization(org),
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
