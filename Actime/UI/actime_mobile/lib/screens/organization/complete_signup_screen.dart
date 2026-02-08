import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'organization_profile_screen.dart';
import '../landing/landing_not_logged_screen.dart';
import '../auth/email_confirmation_screen.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/image_service.dart';
import '../../utils/validators.dart';
import '../../constants/constants.dart';
import '../../components/add_address_modal.dart';

class CompleteSignUpScreen extends StatefulWidget {
  const CompleteSignUpScreen({super.key});

  @override
  State<CompleteSignUpScreen> createState() => _CompleteSignUpScreenState();
}

class _CompleteSignUpScreenState extends State<CompleteSignUpScreen> {
  final _categoryService = CategoryService();
  final _authService = AuthService();
  final _addressService = AddressService();
  final _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Category> _categories = [];
  List<Address> _addresses = [];
  String? _selectedCategoryId;
  Address? _selectedAddress;
  bool _isLoadingCategories = true;
  bool _isLoadingAddresses = true;
  bool _isSubmitting = false;
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _addressService.getAllAddresses();
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAddresses = false;
        });
      }
    }
  }

  Future<void> _showAddAddressModal() async {
    final newAddress = await AddAddressModal.show(context);
    if (newAddress != null && mounted) {
      setState(() {
        _addresses.add(newAddress);
        _selectedAddress = newAddress;
      });
    }
  }

  Future<void> _showAddressPickerModal() async {
    final selectedAddress = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressPickerBottomSheet(
        addresses: _addresses,
        selectedAddress: _selectedAddress,
        onAddNew: () async {
          Navigator.pop(context);
          await _showAddAddressModal();
        },
      ),
    );

    if (selectedAddress != null && mounted) {
      setState(() {
        _selectedAddress = selectedAddress;
      });
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

  Future<void> _pickImage() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF0D7C8C),
                ),
                title: const Text('Galerija'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0D7C8C)),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.red),
                  title: const Text(
                    'Ukloni sliku',
                    style: TextStyle(color: AppColors.red),
                  ),
                  onTap: () => Navigator.pop(context, 'remove'),
                ),
            ],
          ),
        ),
      ),
    );

    if (result == null) return;

    // Handle remove action
    if (result == 'remove') {
      setState(() {
        _selectedImage = null;
      });
      return;
    }

    final source = result as ImageSource;
    final xFile = source == ImageSource.gallery
        ? await _imageService.pickImageFromGallery()
        : await _imageService.pickImageFromCamera();

    if (xFile == null) return;

    setState(() {
      _selectedImage = File(xFile.path);
    });
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Molimo odaberite ili dodajte adresu'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? logoUrl;

      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);

        final uploadResponse = await _imageService.uploadImage(
          _selectedImage!,
          ImageUploadType.organization,
        );

        if (!mounted) return;

        if (uploadResponse.success && uploadResponse.data != null) {
          logoUrl = uploadResponse.data;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                uploadResponse.message ?? 'Greška pri uploadu slike',
              ),
              backgroundColor: AppColors.red,
            ),
          );
          setState(() {
            _isUploadingImage = false;
            _isSubmitting = false;
          });
          return;
        }

        setState(() => _isUploadingImage = false);
      }

      final request = CompleteOrganizationRequest(
        name: _nameController.text.trim(),
        categoryId: int.parse(_selectedCategoryId!),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        addressId: _selectedAddress!.id,
        logoUrl: logoUrl,
      );

      final response = await _authService.completeOrganization(request);

      if (!mounted) return;

      if (response.success) {
        if (response.data?.emailConfirmed == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const OrganizationProfileScreen(),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => EmailConfirmationScreen(
                email: response.data?.email ?? '',
                isPasswordReset: false,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'Greška pri završavanju registracije',
            ),
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
        setState(() {
          _isSubmitting = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Napusti registraciju?'),
            content: const Text(
              'Vaš nalog neće biti kreiran ako napustite ovaj ekran.\n\n'
              'Da li ste sigurni da želite da napustite?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Ostani'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('Napusti'),
              ),
            ],
          ),
        );

        if (shouldLeave == true && context.mounted) {
          try {
            final response = await _authService.deleteMyAccount(
              hardDelete: true,
            );
           
            if (!context.mounted) return;

            if (!response.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Greška pri brisanju naloga: ${response.message}',
                  ),
                  backgroundColor: AppColors.red,
                ),
              );
              return;
            }

            Navigator.pop(context);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Greška: $e'),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          }
        }
      },
      child: Scaffold(
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
              onPressed: () async {
                final shouldLeave = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Napusti registraciju?'),
                    content: const Text(
                      'Vaš nalog neće biti kreiran ako napustite ovaj ekran.\n\n'
                      'Da li ste sigurni da želite da napustite?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Ostani'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.red,
                        ),
                        child: const Text('Napusti'),
                      ),
                    ],
                  ),
                );

                if (shouldLeave == true && context.mounted) {
                  try {
                    final response = await _authService.deleteMyAccount(
                      hardDelete: true,
                    );

                    if (!context.mounted) return;

                    if (!response.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Greška pri uklanjanju naloga: ${response.message}',
                          ),
                          backgroundColor: AppColors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingPageNotLogged(),
                      ),
                      (route) => false,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Greška: $e'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  }
                }
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 32),

                // Profile Image Placeholder
                Center(
                  child: GestureDetector(
                    onTap: _isSubmitting ? null : _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedImage != null
                                  ? const Color(0xFF0D7C8C)
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 40,
                                        color: Colors.grey[400],
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                        ),
                        if (_isUploadingImage)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        if (_selectedImage == null && !_isSubmitting)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0D7C8C),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        if (_selectedImage != null && !_isSubmitting)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0D7C8C),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_selectedImage != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        'Logo odabran',
                        style: TextStyle(
                          color: Color(0xFF0D7C8C),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                        initialValue: _selectedCategoryId,
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

                // Address Selector
                GestureDetector(
                  onTap: _isSubmitting || _isLoadingAddresses
                      ? null
                      : _showAddressPickerModal,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Adresa',
                      hintText: 'Odaberite adresu',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      suffixIcon: _isLoadingAddresses
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0D7C8C),
                                ),
                              ),
                            )
                          : const Icon(Icons.arrow_drop_down),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                      ),
                    ),
                    child: Text(
                      _selectedAddress?.displayAddress ?? 'Odaberite adresu',
                      style: TextStyle(
                        color: _selectedAddress != null
                            ? Colors.black87
                            : Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ),
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
      ), // Zatvara PopScope child
    );
  }
}

class _AddressPickerBottomSheet extends StatefulWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final VoidCallback onAddNew;

  const _AddressPickerBottomSheet({
    required this.addresses,
    required this.selectedAddress,
    required this.onAddNew,
  });

  @override
  State<_AddressPickerBottomSheet> createState() =>
      _AddressPickerBottomSheetState();
}

class _AddressPickerBottomSheetState extends State<_AddressPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Address> _filteredAddresses = [];

  @override
  void initState() {
    super.initState();
    _filteredAddresses = widget.addresses;
  }

  void _filterAddresses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAddresses = widget.addresses;
      } else {
        _filteredAddresses = widget.addresses.where((address) {
          final displayAddress = address.displayAddress.toLowerCase();
          return displayAddress.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Odaberite adresu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D7C8C),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pretraži adrese...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0D7C8C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterAddresses,
            ),
          ),
          const SizedBox(height: 8),
          // Add new button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: widget.onAddNew,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0D7C8C)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF0D7C8C),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Dodaj novu adresu',
                      style: TextStyle(
                        color: Color(0xFF0D7C8C),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // Address list
          Expanded(
            child: _filteredAddresses.isEmpty
                ? Center(
                    child: Text(
                      'Nema rezultata',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredAddresses.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final address = _filteredAddresses[index];
                      final isSelected =
                          widget.selectedAddress?.id == address.id;

                      return ListTile(
                        title: Text(
                          address.displayAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          address.city?.country?.name ??
                              address.city?.countryName ??
                              '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF0D7C8C),
                              )
                            : null,
                        selected: isSelected,
                        selectedTileColor:
                            const Color(0xFF0D7C8C).withValues(alpha: 0.1),
                        onTap: () => Navigator.pop(context, address),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
