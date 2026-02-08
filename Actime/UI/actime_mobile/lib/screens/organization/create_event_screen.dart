import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../components/searchable_dropdown.dart';
import '../../components/add_location_modal.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import '../../utils/form_error_handler.dart';

class CreateEventScreen extends StatefulWidget {
  final String organizationId;

  const CreateEventScreen({super.key, required this.organizationId});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  final _organizationService = OrganizationService();
  final _locationService = LocationService();

  final _eventNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _descriptionController = TextEditingController();

  Organization? _organization;
  List<Location> _locations = [];
  ActivityType? _selectedActivityType;
  EventStatus _selectedEventStatus = EventStatus.pending;
  Location? _selectedLocation;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isLocationsLoading = true;
  Map<String, String> _fieldErrors = {};
  String? _locationError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);

      if (!mounted) return;

      if (orgResponse.success && orgResponse.data != null) {
        _organization = orgResponse.data;
      }

      // Set default activity type
      _selectedActivityType = ActivityType.values.first;

      setState(() => _isLoadingData = false);

      // Load locations in background
      _loadLocations();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadLocations() async {
    setState(() => _isLocationsLoading = true);
    try {
      _locations = await _locationService.getAllLocations();
    } catch (e) {
      // Ignore error, locations will be empty
    }
    if (mounted) {
      setState(() => _isLocationsLoading = false);
    }
  }

  Future<void> _showAddLocationModal() async {
    final newLocation = await AddLocationModal.show(context);
    if (newLocation != null) {
      setState(() {
        _locations.add(newLocation);
        _selectedLocation = newLocation;
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    setState(() {
      _fieldErrors = {};
      _locationError = null;
      _dateError = null;
    });

    bool isValid = _formKey.currentState!.validate();

    if (_selectedDate == null) {
      setState(() => _dateError = 'Odaberite datum događaja');
      isValid = false;
    }

    if (_selectedLocation == null) {
      setState(() => _locationError = 'Odaberite lokaciju događaja');
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      DateTime startDate = _selectedDate!;
      if (_selectedTime != null) {
        startDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      // End date defaults to 2 hours after start
      final endDate = startDate.add(const Duration(hours: 2));

      final price = _priceController.text.isNotEmpty
          ? double.tryParse(_priceController.text) ?? 0.0
          : 0.0;

      final response = await _eventService.createEvent({
        'Title': _eventNameController.text.trim(),
        'Description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'LocationId': _selectedLocation!.id,
        'Start': startDate.toIso8601String(),
        'End': endDate.toIso8601String(),
        'Price': price,
        'IsFree': price == 0,
        'MaxParticipants': _maxParticipantsController.text.isNotEmpty
            ? int.tryParse(_maxParticipantsController.text)
            : null,
        'OrganizationId': int.parse(widget.organizationId),
        'ActivityTypeId': _selectedActivityType!.id,
        'EventStatusId': _selectedEventStatus.id,
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Događaj je uspješno kreiran!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true for list refresh
      } else {
        if (response.hasErrors) {
          setState(() {
            _fieldErrors = FormErrorHandler.mapApiErrors(response.errors);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Greška pri kreiranju događaja'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške. Pokušajte ponovo.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kreiraj događaj',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrganizationInfo(),
                      const SizedBox(height: AppDimensions.spacingXLarge),
                      ActimeTextFormField(
                        controller: _eventNameController,
                        labelText: 'Naziv događaja',
                        hintText: 'Unesite naziv događaja',
                        validator: Validators.compose([
                          Validators.requiredField('Naziv događaja'),
                          Validators.minLengthField(2, 'Naziv događaja'),
                        ]),
                        errorText: _fieldErrors['title'],
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      _buildActivityTypeDropdown(),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      _buildEventStatusDropdown(),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      _buildDateTimeRow(),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchableDropdown<Location>(
                            labelText: 'Lokacija',
                            hintText: 'Odaberi lokaciju',
                            selectedValue: _selectedLocation,
                            items: _locations,
                            itemLabel: (location) => location.name,
                            itemSubtitle: (location) => location.address?.displayAddress ?? '',
                            isLoading: _isLocationsLoading,
                            onChanged: (location) {
                              setState(() {
                                _selectedLocation = location;
                                _locationError = null;
                              });
                            },
                            onAddNew: _showAddLocationModal,
                            addNewLabel: 'Dodaj novu lokaciju',
                          ),
                          if (_locationError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                _locationError!,
                                style: const TextStyle(color: AppColors.red, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      _buildPriceParticipantsRow(),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      ActimeTextFormField(
                        controller: _descriptionController,
                        labelText: 'Opis',
                        hintText: 'Unesite opis događaja (opcionalno)',
                        maxLines: 4,
                        isOutlined: true,
                        validator: Validators.maxLengthField(2000, 'Opis'),
                        errorText: _fieldErrors['description'],
                      ),
                      const SizedBox(height: AppDimensions.spacingXLarge),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            )
                          : ActimePrimaryButton(
                              label: 'Kreiraj događaj',
                              onPressed: _createEvent,
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildOrganizationInfo() {
    return Row(
      children: [
         CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.borderLight,
              backgroundImage: _organization?.logoUrl != null
                  ? NetworkImage(_organization!.logoUrl!)
                  : null,
              child: _organization?.logoUrl == null
                  ? Icon(Icons.groups, size: 20, color: AppColors.textMuted)
                  : null,
            ),
        const SizedBox(width: AppDimensions.spacingMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _organization?.name ?? 'Organizacija',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              _organization?.categoryName ?? 'Klub',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityTypeDropdown() {
    return ActimeDropdownField<ActivityType>(
      initialValue: _selectedActivityType,
      labelText: 'Tip aktivnosti',
      items: ActivityType.values
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedActivityType = value;
        });
      },
    );
  }

  Widget _buildEventStatusDropdown() {
    return ActimeDropdownField<EventStatus>(
      initialValue: _selectedEventStatus,
      labelText: 'Status događaja',
      items: EventStatus.values
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedEventStatus = value;
          });
        }
      },
    );
  }

  Widget _buildDateTimeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ActimeTextFormField(
                controller: _dateController,
                labelText: 'Datum',
                hintText: 'Odaberite datum',
                readOnly: true,
                suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Datum je obavezan';
                  }
                  return null;
                },
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      _dateController.text = DateFormat('dd.MM.yyyy.').format(date);
                      _dateError = null;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingDefault),
            Expanded(
              child: ActimeTextFormField(
                controller: _timeController,
                labelText: 'Vrijeme',
                hintText: 'Odaberite vrijeme',
                readOnly: true,
                suffixIcon: const Icon(Icons.access_time, color: AppColors.primary),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                      _timeController.text = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
                    });
                  }
                },
              ),
            ),
          ],
        ),
        if (_dateError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              _dateError!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceParticipantsRow() {
    return Row(
      children: [
        Expanded(
          child: ActimeTextFormField(
            controller: _priceController,
            labelText: 'Cijena (opcionalno)',
            hintText: '0.00',
            keyboardType: TextInputType.number,
            prefixText: 'BAM ',
            validator: (value) => Validators.positiveNumber(value, 'Cijena'),
            errorText: _fieldErrors['price'],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        Expanded(
          child: ActimeTextFormField(
            controller: _maxParticipantsController,
            labelText: 'Max učesnika',
            hintText: 'Opcionalno',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final num = int.tryParse(value);
              if (num == null || num < 1) {
                return 'Unesite validan broj';
              }
              return null;
            },
            errorText: _fieldErrors['maxParticipants'],
          ),
        ),
      ],
    );
  }
}
