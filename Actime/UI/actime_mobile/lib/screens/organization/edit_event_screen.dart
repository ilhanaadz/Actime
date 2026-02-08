import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/searchable_dropdown.dart';
import '../../components/add_location_modal.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import '../../utils/form_error_handler.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  final _locationService = LocationService();

  final _eventNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _descriptionController = TextEditingController();

  Event? _event;
  List<Location> _locations = [];
  ActivityType? _selectedActivityType;
  EventStatus? _selectedEventStatus;
  Location? _selectedLocation;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isLocationsLoading = true;
  Map<String, String> _fieldErrors = {};
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      final eventResponse = await _eventService.getEventById(widget.eventId);

      if (!mounted) return;

      if (eventResponse.success && eventResponse.data != null) {
        _event = eventResponse.data;
        _populateFields();
      }

      setState(() => _isLoadingData = false);

      // Load locations in background
      _loadLocations();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Greška pri učitavanju događaja'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadLocations() async {
    setState(() => _isLocationsLoading = true);
    try {
      _locations = await _locationService.getAllLocations();
      // If event has locationId, find and select the location
      if (_event?.locationId != null) {
        _selectedLocation = _locations.firstWhere(
          (l) => l.id == _event!.locationId,
          orElse: () => _locations.first,
        );
      }
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

  void _populateFields() {
    if (_event == null) return;

    _eventNameController.text = _event!.name;
    _descriptionController.text = _event!.description ?? '';
    _priceController.text = _event!.price.toString() ?? '';
    _maxParticipantsController.text = _event!.maxParticipants?.toString() ?? '';

    _selectedDate = _event!.startDate;
    _dateController.text = DateFormat('dd.MM.yyyy.').format(_event!.startDate);

    _selectedTime = TimeOfDay(
      hour: _event!.startDate.hour,
      minute: _event!.startDate.minute,
    );
    _timeController.text =
        '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    _selectedActivityType = ActivityType.fromId(_event!.activityTypeId);
    _selectedEventStatus = _event!.status;
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

  Future<void> _updateEvent() async {
    setState(() {
      _fieldErrors = {};
      _dateError = null;
    });

    bool isValid = _formKey.currentState!.validate();

    if (_selectedDate == null) {
      setState(() => _dateError = 'Odaberite datum događaja');
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

      final response = await _eventService.updateEvent(widget.eventId, {
        'Title': _eventNameController.text.trim(),
        'Description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'Start': startDate.toIso8601String(),
        'Price': _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text)
            : null,
        'MaxParticipants': _maxParticipantsController.text.isNotEmpty
            ? int.tryParse(_maxParticipantsController.text)
            : null,
        if (_selectedActivityType != null) 'ActivityTypeId': _selectedActivityType!.id,
        if (_selectedLocation != null) 'LocationId': _selectedLocation!.id,
        if (_selectedEventStatus != null) 'EventStatusId': _selectedEventStatus!.id,
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Događaj je uspješno ažuriran!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true za refresh liste
      } else {
        if (response.hasErrors) {
          setState(() {
            _fieldErrors = FormErrorHandler.mapApiErrors(response.errors);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Greška pri ažuriranju događaja'),
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

  Future<void> _deleteEvent() async {
    setState(() => _isLoading = true);

    try {
      final response = await _eventService.deleteEvent(widget.eventId);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Događaj je obrisan'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Return true for list refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri brisanju događaja'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške'),
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
          'Uredi događaj',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
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
                      _buildCoverImageSection(),
                      const SizedBox(height: AppDimensions.spacingLarge),
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
                      SearchableDropdown<Location>(
                        labelText: 'Lokacija',
                        hintText: 'Odaberi lokaciju',
                        selectedValue: _selectedLocation,
                        items: _locations,
                        itemLabel: (location) => location.name,
                        itemSubtitle: (location) => location.address?.displayAddress ?? '',
                        isLoading: _isLocationsLoading,
                        isOutlined: false,
                        onChanged: (location) => setState(() => _selectedLocation = location),
                        onAddNew: _showAddLocationModal,
                        addNewLabel: 'Dodaj novu lokaciju',
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
                              child:
                                  CircularProgressIndicator(color: AppColors.primary),
                            )
                          : ActimePrimaryButton(
                              label: 'Spremi promjene',
                              onPressed: _updateEvent,
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCoverImageSection() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.image, size: 60, color: AppColors.textSecondary),
          ),
          Positioned(
            bottom: AppDimensions.spacingSmall,
            right: AppDimensions.spacingSmall,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingSmall),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 16, color: AppColors.white),
            ),
          ),
        ],
      ),
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
    final currentStatus = _selectedEventStatus ?? EventStatus.pending;
    final availableStatuses = currentStatus.availableForSelection;

    return ActimeDropdownField<EventStatus>(
      initialValue: _selectedEventStatus,
      labelText: 'Status događaja',
      items: availableStatuses
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              ))
          .toList(),
      onChanged: currentStatus.isTerminal
          ? null
          : (value) {
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
                suffixIcon:
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Datum je obavezan';
                  }
                  return null;
                },
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
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
                suffixIcon:
                    const Icon(Icons.access_time, color: AppColors.primary),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                      _timeController.text =
                          '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
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

  Future<void> _showDeleteDialog() async {
    final confirmed = await ConfirmationDialog.showDelete(
      context: context,
      itemName: 'događaj',
    );
    if (confirmed == true && mounted) {
      _deleteEvent();
    }
  }
}
