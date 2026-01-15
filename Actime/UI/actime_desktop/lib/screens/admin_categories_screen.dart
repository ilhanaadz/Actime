import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../components/pagination_widget.dart';
import '../components/search_sort_header.dart';
import '../components/delete_confirmation_dialog.dart';
import '../components/input_dialog.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 4;
  String _sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: 'categories',
      child: Column(
              children: [
                // Header with Search and Sort
                SearchSortHeader(
                  title: 'Categories',
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

                // Categories Table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
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
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Name',
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
                              _buildCategoryRow('Volleyball', '3 organizations'),
                              _buildCategoryRow('Sports', '12 organizations'),
                              _buildCategoryRow('Hiking', '5 organizations'),
                              _buildCategoryRow('Swimming', '7 organizations'),
                              _buildCategoryRow('Basketball', '4 organizations'),
                              _buildCategoryRow('Football', '8 organizations'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        
                        // Floating Action Button
                        Center(
                          child: FloatingActionButton(
                            onPressed: () {
                              _showAddCategoryDialog();
                            },
                            backgroundColor: const Color(0xFF0D7C8C),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
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

  Widget _buildCategoryRow(String name, String orgs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _showEditCategoryDialog(name),
            color: Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _showDeleteCategoryDialog(name),
            color: Colors.red[400],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final categoryName = await InputDialog.show(
      context: context,
      title: 'Add Category',
      label: 'Category Name',
      confirmText: 'Add',
    );
    
    if (categoryName != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "$categoryName" added successfully')),
      );
    }
  }

  Future<void> _showEditCategoryDialog(String currentName) async {
    final categoryName = await InputDialog.show(
      context: context,
      title: 'Edit Category',
      label: 'Category Name',
      initialValue: currentName,
      confirmText: 'Save',
    );
    
    if (categoryName != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated to "$categoryName"')),
      );
    }
  }

  Future<void> _showDeleteCategoryDialog(String categoryName) async {
    final result = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "$categoryName"? This action cannot be undone.',
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "$categoryName" deleted successfully')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}