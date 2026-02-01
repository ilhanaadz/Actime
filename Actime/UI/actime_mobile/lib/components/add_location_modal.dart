import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/address.dart';
import '../models/location.dart';
import '../services/address_service.dart';
import '../services/location_service.dart';
import 'actime_button.dart';
import 'actime_text_field.dart';
import 'add_address_modal.dart';
import 'searchable_dropdown.dart';

/// Modal dialog for adding a new location
class AddLocationModal extends StatefulWidget {
  final Function(Location) onLocationCreated;

  const AddLocationModal({
    super.key,
    required this.onLocationCreated,
  });

  /// Show the modal and return the created location
  static Future<Location?> show(BuildContext context) async {
    Location? createdLocation;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddLocationModal(
        onLocationCreated: (location) {
          createdLocation = location;
          Navigator.of(context).pop();
        },
      ),
    );

    return createdLocation;
  }

  @override
  State<AddLocationModal> createState() => _AddLocationModalState();
}

class _AddLocationModalState extends State<AddLocationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _contactInfoController = TextEditingController();

  final LocationService _locationService = LocationService();
  final AddressService _addressService = AddressService();

  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = false;
  bool _isAddressesLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isAddressesLoading = true);
    try {
      _addresses = await _addressService.getAllAddresses();
    } catch (e) {
      _errorMessage = 'Greska pri ucitavanju adresa';
    }
    setState(() => _isAddressesLoading = false);
  }

  Future<void> _createLocation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAddress == null) {
      setState(() => _errorMessage = 'Odaberite adresu');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _locationService.createLocation(
        name: _nameController.text.trim(),
        addressId: _selectedAddress!.id,
        capacity: _capacityController.text.trim().isNotEmpty
            ? int.tryParse(_capacityController.text.trim())
            : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        contactInfo: _contactInfoController.text.trim().isNotEmpty
            ? _contactInfoController.text.trim()
            : null,
      );

      if (response.success && response.data != null) {
        widget.onLocationCreated(response.data!);
      } else {
        setState(() => _errorMessage = response.message ?? 'Greska pri kreiranju lokacije');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Doslo je do greske');
    } finally {
      setState(() => _isLoading = false);
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nova lokacija',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name
                ActimeTextField(
                  controller: _nameController,
                  labelText: 'Naziv lokacije *',
                  hintText: 'npr. Sportska dvorana Zetra',
                  isOutlined: true,
                ),
                const SizedBox(height: 16),

                // Address dropdown
                SearchableDropdown<Address>(
                  labelText: 'Adresa *',
                  hintText: 'Odaberi adresu',
                  selectedValue: _selectedAddress,
                  items: _addresses,
                  itemLabel: (address) => address.street,
                  itemSubtitle: (address) => address.city?.name ?? address.cityName ?? '',
                  isLoading: _isAddressesLoading,
                  onChanged: (address) => setState(() => _selectedAddress = address),
                  onAddNew: _showAddAddressModal,
                  addNewLabel: 'Dodaj novu adresu',
                ),
                const SizedBox(height: 16),

                // Capacity
                ActimeTextField(
                  controller: _capacityController,
                  labelText: 'Kapacitet (opciono)',
                  hintText: 'npr. 100',
                  isOutlined: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Description
                ActimeTextField(
                  controller: _descriptionController,
                  labelText: 'Opis (opciono)',
                  hintText: 'Kratki opis lokacije',
                  isOutlined: true,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Contact info
                ActimeTextField(
                  controller: _contactInfoController,
                  labelText: 'Kontakt info (opciono)',
                  hintText: 'npr. +387 33 123 456',
                  isOutlined: true,
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.red),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ActimeOutlinedButton(
                        label: 'Odustani',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActimePrimaryButton(
                        label: 'Sacuvaj',
                        onPressed: _isLoading ? null : _createLocation,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
