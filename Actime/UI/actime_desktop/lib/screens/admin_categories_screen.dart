import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../components/pagination_widget.dart';
import '../components/search_sort_header.dart';
import '../components/delete_confirmation_dialog.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';
import '../services/services.dart';
import '../models/models.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _searchController = TextEditingController();
  final _categoryService = CategoryService();

  int _currentPage = 1;
  int _totalPages = 1;
  String _sortBy = 'Name';
  bool _isLoading = true;
  String? _error;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty || _searchController.text.length >= 2) {
      setState(() => _currentPage = 1);     
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _categoryService.getCategories(
        page: _currentPage,
        perPage: 10,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        sortBy: _sortBy,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _categories = response.data!.data;
          _totalPages = response.data!.lastPage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load categories';
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

  Future<void> _createCategory(String name) async {
    setState(() => _isLoading = true);

    try {
      final response = await _categoryService.createCategory(name: name);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategorija "$name" uspješno dodana'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri dodavanju kategorije'),
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

  Future<void> _updateCategory(Category category, String newName) async {
    setState(() => _isLoading = true);

    try {
      final response = await _categoryService.updateCategory(
        id: category.id,
        name: newName,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategorija uspješno ažurirana'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri ažuriranju kategorije'),
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

  Future<void> _deleteCategory(Category category) async {
    final result = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
    );

    if (result != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await _categoryService.deleteCategory(category.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategorija "${category.name}" uspješno obrisana'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri brisanju kategorije'),
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
      currentRoute: 'categories',
      child: Column(
        children: [
          // Header with Search and Sort
          SearchSortHeader(
            title: 'Categories',
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
              const PopupMenuItem(
                value: 'OrganizationsCount',
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
              setState(() {
                _currentPage = 1;
                _sortBy = value;
              });
              _loadCategories();
            },
          ),

          // Categories Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _categories.isEmpty
                        ? _buildEmptyState()
                        : SingleChildScrollView(
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
                                            Container(width: 80),
                                          ],
                                        ),
                                      ),

                                      // Table Rows
                                      ...(_categories.map((category) => _buildCategoryRow(category))),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Floating Action Button
                                Center(
                                  child: FloatingActionButton(
                                    onPressed: _showAddCategoryDialog,
                                    backgroundColor: const Color(0xFF0D7C8C),
                                    child: const Icon(Icons.add, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),

          // Pagination at bottom
          if (!_isLoading && _error == null && _categories.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: PaginationWidget(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _loadCategories();
                },
              ),
            ),
        ],
      ),
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
            onPressed: _loadCategories,
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
          Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No categories found for "${_searchController.text}"'
                : 'No categories found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7C8C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Category category) {
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
              category.name,
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
                  '${category.organizationsCount} organization${category.organizationsCount != 1 ? 's' : ''}',
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
            onPressed: () => _showEditCategoryDialog(category),
            color: Colors.grey[600],
            tooltip: 'Edit category',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _deleteCategory(category),
            color: Colors.red[400],
            tooltip: 'Delete category',
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final categoryName = await CategoryFormDialog.show(
      context: context,
      isEdit: false,
    );

    if (categoryName != null && categoryName.isNotEmpty && mounted) {
      _createCategory(categoryName);
    }
  }

  Future<void> _showEditCategoryDialog(Category category) async {
    final categoryName = await CategoryFormDialog.show(
      context: context,
      initialName: category.name,
      isEdit: true,
    );

    if (categoryName != null && categoryName.isNotEmpty && mounted) {
      _updateCategory(category, categoryName);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}

// Category Form Dialog with Validation
class CategoryFormDialog extends StatefulWidget {
  final String? initialName;
  final bool isEdit;

  const CategoryFormDialog({
    super.key,
    this.initialName,
    this.isEdit = false,
  });

  static Future<String?> show({
    required BuildContext context,
    String? initialName,
    bool isEdit = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => CategoryFormDialog(
        initialName: initialName,
        isEdit: isEdit,
      ),
    );
  }

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Uredi kategoriju' : 'Nova kategorija'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: AppTextField(
            controller: _nameController,
            labelText: 'Naziv kategorije',
            hintText: 'Unesite naziv',
            autofocus: true,
            textInputAction: TextInputAction.done,
            validator: Validators.compose([
              Validators.requiredField('Naziv'),
              Validators.minLengthField(2, 'Naziv'),
              Validators.maxLengthField(100, 'Naziv'),
            ]),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Odustani'),
        ),
        AppButton(
          text: widget.isEdit ? 'Spremi' : 'Dodaj',
          onPressed: _handleSubmit,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
