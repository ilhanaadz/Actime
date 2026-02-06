import 'package:flutter/material.dart';
import 'organization_profile_screen.dart';
import '../landing/landing_not_logged_screen.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import '../../constants/constants.dart';

class CompleteSignUpScreen extends StatefulWidget {
  const CompleteSignUpScreen({super.key});

  @override
  State<CompleteSignUpScreen> createState() => _CompleteSignUpScreenState();
}

class _CompleteSignUpScreenState extends State<CompleteSignUpScreen> {
  final _categoryService = CategoryService();
  final _authService = AuthService();
  final _cityService = CityService();
  final _addressService = AddressService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Category> _categories = [];
  List<City> _cities = [];
  String? _selectedCategoryId;
  String? _selectedCityId;
  bool _isLoadingCategories = true;
  bool _isLoadingCities = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await _cityService.getAllCities();
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
        });
      }
    }
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

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // First, create the address
      final addressResponse = await _addressService.createAddress(
        street: _streetController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        cityId: int.parse(_selectedCityId!),
      );

      if (!mounted) return;

      if (!addressResponse.success || addressResponse.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(addressResponse.message ?? 'Greška pri kreiranju adrese'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      // Then complete organization with the created address
      final request = CompleteOrganizationRequest(
        name: _nameController.text.trim(),
        categoryId: int.parse(_selectedCategoryId!),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        addressId: addressResponse.data!.id,
      );

      final response = await _authService.completeOrganization(request);

      if (!mounted) return;

      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrganizationProfileScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri završavanju registracije'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Došlo je do greške: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
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

            // Organization Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ime organizacije',
                hintText: 'Unesite ime organizacije',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
              validator: Validators.compose([
                Validators.requiredField('Ime organizacije'),
                Validators.minLengthField(2, 'Ime organizacije'),
              ]),
            ),
            const SizedBox(height: 24),

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
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefon',
                hintText: 'Unesite broj telefona',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
              validator: Validators.phone,
            ),
            const SizedBox(height: 24),

            // City Dropdown
            _isLoadingCities
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D7C8C),
                      ),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: _selectedCityId,
                    decoration: InputDecoration(
                      labelText: 'Grad',
                      hintText: 'Odaberite grad',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                      ),
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city.id.toString(),
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCityId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Grad je obavezan';
                      }
                      return null;
                    },
                  ),
            const SizedBox(height: 24),

            // Street
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Ulica',
                hintText: 'Unesite ulicu i broj',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
              validator: Validators.compose([
                Validators.requiredField('Ulica'),
                Validators.minLengthField(2, 'Ulica'),
              ]),
            ),
            const SizedBox(height: 24),

            // Postal Code
            TextFormField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: 'Poštanski broj',
                hintText: 'Unesite poštanski broj',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
              validator: Validators.requiredField('Poštanski broj'),
            ),
            const SizedBox(height: 24),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Opišite svoju organizaciju',
                hintText: 'Opišite svoju organizaciju',
                hintStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
              validator: Validators.maxLengthField(500, 'Opis'),
            ),
            const SizedBox(height: 48),
            
            // Complete Button
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7C8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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