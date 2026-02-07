import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/address.dart';
import '../models/city.dart';
import '../services/address_service.dart';
import '../services/city_service.dart';
import '../utils/validators.dart';
import '../utils/form_error_handler.dart';
import 'actime_button.dart';
import 'actime_text_field.dart';
import 'searchable_dropdown.dart';

class AddAddressModal extends StatefulWidget {
  final Function(Address) onAddressCreated;

  const AddAddressModal({
    super.key,
    required this.onAddressCreated,
  });

  static Future<Address?> show(BuildContext context) async {
    Address? createdAddress;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddAddressModal(
        onAddressCreated: (address) {
          createdAddress = address;
          Navigator.of(context).pop();
        },
      ),
    );

    return createdAddress;
  }

  @override
  State<AddAddressModal> createState() => _AddAddressModalState();
}

class _AddAddressModalState extends State<AddAddressModal> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _coordinatesController = TextEditingController();

  final AddressService _addressService = AddressService();
  final CityService _cityService = CityService();

  List<City> _cities = [];
  City? _selectedCity;
  bool _isLoading = false;
  bool _isCitiesLoading = true;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};
  String? _cityError;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => _isCitiesLoading = true);
    try {
      _cities = await _cityService.getAllCities();
    } catch (e) {
      _errorMessage = 'Greska pri ucitavanju gradova';
    }
    setState(() => _isCitiesLoading = false);
  }

  Future<void> _createAddress() async {
    // Očisti greške
    setState(() {
      _fieldErrors = {};
      _cityError = null;
      _errorMessage = null;
    });

    bool isValid = _formKey.currentState!.validate();

    if (_selectedCity == null) {
      setState(() => _cityError = 'Odaberite grad');
      isValid = false;
    }

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _addressService.createAddress(
        street: _streetController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        cityId: _selectedCity!.id,
        coordinates: _coordinatesController.text.trim().isNotEmpty
            ? _coordinatesController.text.trim()
            : null,
      );

      if (response.success && response.data != null) {
        widget.onAddressCreated(response.data!);
      } else {
        // Mapiraj API greške na polja
        if (response.hasErrors) {
          setState(() {
            _fieldErrors = FormErrorHandler.mapApiErrors(response.errors);
          });
        } else {
          setState(() => _errorMessage = response.message ?? 'Greška pri kreiranju adrese');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Došlo je do greške');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddCityDialog() async {
    final nameController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    final result = await showDialog<City>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Dodaj novi grad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActimeTextField(
                controller: nameController,
                labelText: 'Naziv grada',
                isOutlined: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Napomena: Grad ce biti dodan za BiH',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        setState(() => errorMessage = 'Unesite naziv grada');
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      final response = await _cityService.createCity(
                        name: nameController.text.trim(),
                        countryId: 1, // Default to BiH
                      );

                      if (!context.mounted) return;

                      setState(() => isLoading = false);

                      if (response.success && response.data != null) {
                        Navigator.pop(context, response.data);
                      } else {
                        setState(() {
                          errorMessage = response.message ?? 'Grad već postoji ili greška pri dodavanju';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Dodaj'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _cities.add(result);
        _selectedCity = result;
      });
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _postalCodeController.dispose();
    _coordinatesController.dispose();
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
                      'Nova adresa',
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

                // Street
                ActimeTextFormField(
                  controller: _streetController,
                  labelText: 'Ulica i broj *',
                  hintText: 'npr. Zmaja od Bosne 10',
                  isOutlined: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.compose([
                    Validators.requiredField('Ulica'),
                    Validators.minLengthField(2, 'Ulica'),
                  ]),
                  errorText: _fieldErrors['street'],
                ),
                const SizedBox(height: 16),

                // City dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchableDropdown<City>(
                      labelText: 'Grad *',
                      hintText: 'Odaberi grad',
                      selectedValue: _selectedCity,
                      items: _cities,
                      itemLabel: (city) => city.name,
                      itemSubtitle: (city) => city.country?.name ?? city.countryName ?? '',
                      isLoading: _isCitiesLoading,
                      onChanged: (city) {
                        setState(() {
                          _selectedCity = city;
                          _cityError = null;
                        });
                      },
                      onAddNew: _showAddCityDialog,
                      addNewLabel: 'Dodaj novi grad',
                    ),
                    if (_cityError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          _cityError!,
                          style: const TextStyle(color: AppColors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Postal code
                ActimeTextFormField(
                  controller: _postalCodeController,
                  labelText: 'Poštanski broj *',
                  hintText: 'npr. 71000',
                  isOutlined: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: Validators.requiredField('Poštanski broj'),
                  errorText: _fieldErrors['postalCode'],
                ),
                const SizedBox(height: 16),

                // Coordinates (optional)
                ActimeTextFormField(
                  controller: _coordinatesController,
                  labelText: 'Koordinate (opciono)',
                  hintText: 'npr. 43.8563, 18.4131',
                  isOutlined: true,
                  textInputAction: TextInputAction.done,
                  errorText: _fieldErrors['coordinates'],
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
                        onPressed: _isLoading ? null : _createAddress,
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
