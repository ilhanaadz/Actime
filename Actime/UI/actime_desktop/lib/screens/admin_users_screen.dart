import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../components/pagination_widget.dart';
import '../components/search_sort_header.dart';
import '../components/delete_confirmation_dialog.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 4;
  String _sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: 'users',
      child: Column(
              children: [
                // Header with Search and Sort
                SearchSortHeader(
                  title: 'Users',
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
                      value: 'email',
                      child: Row(
                        children: [
                          Icon(Icons.email, size: 18),
                          SizedBox(width: 12),
                          Text('Sort by Email'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'organizations',
                      child: Row(
                        children: [
                          Icon(Icons.apartment, size: 18),
                          SizedBox(width: 12),
                          Text('Sort by Organizations'),
                        ],
                      ),
                    ),
                  ],
                  onSortSelected: (value) {
                    setState(() => _sortBy = value);
                  },
                ),

                // Users Table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
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
                          // Table Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 60),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'First Name',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Last Name',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Email Address',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Organizations',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Container(width: 40),
                              ],
                            ),
                          ),

                          // Table Rows
                          _buildUserRow('Furkan Cürek', 'furkancurek@outlook.com', '2 organizations'),
                          _buildUserRow('Armin Šišić', 'sisicarmin@gmail.com', '6 organizations'),
                          _buildUserRow('Test User', 'testuser@gmail.com', '1 organization'),
                          _buildUserRow('Another Cürek', 'anotherfurkan@gmail.com', '4 organizations'),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Pagination at bottom
                Container(
                  padding: const EdgeInsets.all(24),
                  child: PaginationWidget(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserRow(String name, String email, String orgs) {
    final nameParts = name.split(' ');
    final firstName = nameParts[0];
    final lastName = nameParts.length > 1 ? nameParts[1] : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D7C8C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                firstName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D7C8C),
                ),
              ),
            ),
          ),

          // First Name
          Expanded(
            flex: 2,
            child: Text(
              firstName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // Last Name
          Expanded(
            flex: 2,
            child: Text(
              lastName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // Email
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Organizations
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.apartment_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  orgs,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Delete Icon
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _showDeleteUserDialog(name),
            color: Colors.red[400],
            tooltip: 'Delete user',
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteUserDialog(String userName) async {
    final result = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Delete User',
      message: 'Are you sure you want to delete $userName? This action cannot be undone.',
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$userName deleted successfully')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}