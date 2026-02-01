import 'package:flutter/material.dart';
import 'organization_profile_screen.dart';
import '../landing/landing_not_logged_screen.dart';
import '../../models/models.dart';
import '../../services/services.dart';

class CompleteSignUpScreen extends StatefulWidget {
  const CompleteSignUpScreen({super.key});

  @override
  State<CompleteSignUpScreen> createState() => _CompleteSignUpScreenState();
}

class _CompleteSignUpScreenState extends State<CompleteSignUpScreen> {
  final _categoryService = CategoryService();
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška pri učitavanju kategorija'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Actime',
          style: TextStyle(
            color: Color(0xFF0D7C8C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF0D7C8C)),
            onPressed: () {
              // Navigate back to landing page and clear navigation stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingPageNotLogged()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dear Organization,',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D7C8C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please fill out all of the fields to make\nYour organization profile complete.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 32),
            
            // Profile Image Placeholder
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Category Dropdown
            _isLoadingCategories
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D7C8C),
                      ),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      hintText: 'Odaberi kategoriju',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategorija je obavezna';
                      }
                      return null;
                    },
                  ),
            const SizedBox(height: 24),
            
            // Phone
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: 'Phone',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Address
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'Address',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Please describe yourself',
                hintText: 'Please describe yourself',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            // Complete Button
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate form before proceeding
                    if (_formKey.currentState!.validate()) {
                      // Clear navigation stack and go to organization profile
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrganizationProfileScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7C8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}