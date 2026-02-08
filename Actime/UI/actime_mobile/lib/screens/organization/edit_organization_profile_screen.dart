import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/constants.dart';
import '../../components/searchable_dropdown.dart';
import '../../components/add_address_modal.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/image_service.dart';
import '../../utils/validators.dart';
import '../../utils/form_error_handler.dart';

class EditOrganizationProfileScreen extends StatefulWidget {
  final String organizationId;

  const EditOrganizationProfileScreen({
    super.key,
    required this.organizationId,
  });

  @override
  State<EditOrganizationProfileScreen> createState() =>
      _EditOrganizationProfileScreenState();
}

class _EditOrganizationProfileScreenState
    extends State<EditOrganizationProfileScreen> {
  final _organizationService = OrganizationService();
  final _categoryService = CategoryService();
  final _addressService = AddressService();
  final _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aboutController = TextEditingController();

  Organization? _organization;
  List<Category> _categories = [];
  List<Address> _addresses = [];
  String? _selectedCategoryId;
  Address? _selectedAddress;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAddressesLoading = true;
  bool _isUploadingImage = false;
  String? _error;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _loadOrganization();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganization() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load categories and organization in parallel
      final results = await Future.wait([
        _categoryService.getAllCategories(),
        _organizationService.getOrganizationById(widget.organizationId),
      ]);

      if (!mounted) return;

      _categories = results[0] as List<Category>;
      final response = results[1] as ApiResponse<Organization>;

      if (response.success && response.data != null) {
        _organization = response.data;
        _nameController.text = _organization?.name ?? '';
        _phoneController.text = _organization?.phone ?? '';
        _emailController.text = _organization?.email ?? '';
        _aboutController.text = _organization?.description ?? '';
        _selectedCategoryId = _organization?.categoryId;
        setState(() {
          _isLoading = false;
        });
        // Load addresses in background
        _loadAddresses();
      } else {
        setState(() {
          _error = response.message ?? 'Greska pri ucitavanju';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Doslo je do greske';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAddresses() async {
    setState(() => _isAddressesLoading = true);
    try {
      _addresses = await _addressService.getAllAddresses();
      // If organization has addressId, find and select the address
      if (_organization?.addressId != null) {
        final matchingAddress = _addresses.where(
          (a) => a.id == _organization!.addressId,
        );
        if (matchingAddress.isNotEmpty) {
          _selectedAddress = matchingAddress.first;
        }
      }
    } catch (e) {
      // Ignore error, addresses will be empty
    }
    if (mounted) {
      setState(() => _isAddressesLoading = false);
    }
  }

  Future<void> _showAddAddressModal() async {
    final newAddress = await AddAddressModal.show(context);
    if (newAddress != null) {
      setState(() {
        _addresses.add(newAddress);
        _selectedAddress = newAddress;
      });
    }
  }

  Future<void> _changeLogo() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerija'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (_organization?.logoUrl != null)
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
    );

    if (result == null) return;

    if (result == 'remove') {
      await _removeLogo();
      return;
    }

    final source = result as ImageSource;
    final xFile = source == ImageSource.gallery
        ? await _imageService.pickImageFromGallery()
        : await _imageService.pickImageFromCamera();

    if (xFile == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final file = File(xFile.path);
      final uploadResponse = await _imageService.uploadImage(
        file,
        ImageUploadType.organization,
      );

      if (!mounted) return;

      if (uploadResponse.success && uploadResponse.data != null) {
        final updateResponse = await _organizationService.updateMyOrganization({
          'LogoUrl': uploadResponse.data,
        });

        if (!mounted) return;

        if (updateResponse.success) {
          setState(() {
            _organization = _organization?.copyWith(
              logoUrl: uploadResponse.data,
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo je uspješno promijenjen')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(updateResponse.message ?? 'Greška pri spremanju'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadResponse.message ?? 'Greška pri uploadu'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Došlo je do greške')));
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _removeLogo() async {
    setState(() => _isUploadingImage = true);

    try {
      final updateResponse = await _organizationService.updateMyOrganization({
        'LogoUrl': '',
      });

      if (!mounted) return;

      if (updateResponse.success) {
        await _loadOrganization();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo je uspješno uklonjen')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updateResponse.message ?? 'Greška pri uklanjanju logoa'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Došlo je do greške')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) return;

    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await _organizationService.updateMyOrganization({
        'Name': _nameController.text,
        'PhoneNumber': _phoneController.text,
        'Email': _emailController.text,
        'Description': _aboutController.text,
        if (_selectedCategoryId != null)
          'CategoryId':
              int.tryParse(_selectedCategoryId!) ?? _selectedCategoryId,
        if (_selectedAddress != null) 'AddressId': _selectedAddress!.id,
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promjene su uspješno sačuvane'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (response.hasErrors) {
          setState(() {
            _fieldErrors = FormErrorHandler.mapApiErrors(response.errors);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Greška pri spremanju'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are about to change:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildChangeItem('Address', _selectedAddress?.displayAddress ?? ''),
            _buildChangeItem('E-mail', _emailController.text),
            _buildChangeItem('About us', _aboutController.text),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value.length > 30 ? '${value.substring(0, 30)}...' : value,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

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
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadOrganization,
              child: const Text('Pokusaj ponovo'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    key: ValueKey(_organization?.logoUrl ?? 'no-logo'),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: _organization?.logo != null
                        ? ClipOval(
                            child: Image.network(
                              _imageService.getFullImageUrl(
                                _organization!.logo,
                              ),
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
                      width: 120,
                      height: 120,
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _changeLogo,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_fieldErrors['name'] != null) {
                  return _fieldErrors['name'];
                }
                return Validators.required(value, 'Naziv');
              },
              decoration: InputDecoration(
                labelText: 'Naziv organizacije',
                hintText: 'Unesite naziv organizacije',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
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
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_fieldErrors['phone'] != null) {
                  return _fieldErrors['phone'];
                }
                return Validators.phone(value);
              },
              decoration: InputDecoration(
                labelText: 'Telefon',
                hintText: 'Unesite broj telefona (8-15 cifara)',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Address
            SearchableDropdown<Address>(
              labelText: 'Address',
              hintText: 'Odaberi adresu',
              selectedValue: _selectedAddress,
              items: _addresses,
              itemLabel: (address) => address.street,
              itemSubtitle: (address) =>
                  address.city?.name ?? address.cityName ?? '',
              isLoading: _isAddressesLoading,
              isOutlined: false,
              onChanged: (address) =>
                  setState(() => _selectedAddress = address),
              onAddNew: _showAddAddressModal,
              addNewLabel: 'Dodaj novu adresu',
            ),
            const SizedBox(height: 24),

            // E-mail
            TextFormField(
              controller: _emailController,
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (_fieldErrors['email'] != null) {
                  return _fieldErrors['email'];
                }
                return Validators.email(value);
              },
              decoration: InputDecoration(
                labelText: 'E-mail',
                hintText: 'Email adresa',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // About us
            TextFormField(
              controller: _aboutController,
              maxLines: 4,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_fieldErrors['description'] != null) {
                  return _fieldErrors['description'];
                }
                return Validators.maxLength(value, 500, 'Opis');
              },
              decoration: InputDecoration(
                labelText: 'O nama',
                hintText: 'Opišite svoju organizaciju',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Save Button
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save',
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
    );
  }
}
