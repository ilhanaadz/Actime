import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../components/confirmation_dialog.dart';
import '../../models/models.dart';
import '../../services/services.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _eventService = EventService();
  final _categoryService = CategoryService();

  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _descriptionController = TextEditingController();

  Event? _event;
  List<Category> _categories = [];
  String? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      final eventResponse = await _eventService.getEventById(widget.eventId);
      final categoriesResponse = await _categoryService.getCategories();

      if (!mounted) return;

      if (categoriesResponse.success && categoriesResponse.data != null) {
        _categories = categoriesResponse.data!.data;
      }

      if (eventResponse.success && eventResponse.data != null) {
        _event = eventResponse.data;
        _populateFields();
      }

      setState(() => _isLoadingData = false);
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

  void _populateFields() {
    if (_event == null) return;

    _eventNameController.text = _event!.name;
    _locationController.text = _event!.location ?? '';
    _descriptionController.text = _event!.description ?? '';
    _priceController.text = _event!.price?.toString() ?? '';
    _maxParticipantsController.text = _event!.maxParticipants?.toString() ?? '';

    _selectedDate = _event!.startDate;
    _dateController.text = DateFormat('dd.MM.yyyy.').format(_event!.startDate);

    _selectedTime = TimeOfDay(
      hour: _event!.startDate.hour,
      minute: _event!.startDate.minute,
    );
    _timeController.text =
        '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    _selectedCategoryId = _event!.categoryId;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    if (_eventNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite naziv događaja')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Odaberite datum događaja')),
      );
      return;
    }

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
        'Name': _eventNameController.text.trim(),
        'Description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'Location': _locationController.text.isNotEmpty
            ? _locationController.text.trim()
            : null,
        'Start': startDate.toIso8601String(),
        'Price': _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text)
            : null,
        'MaxParticipants': _maxParticipantsController.text.isNotEmpty
            ? int.tryParse(_maxParticipantsController.text)
            : null,
        'CategoryId': _selectedCategoryId,
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Događaj je uspješno ažuriran!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri ažuriranju događaja'),
            backgroundColor: Colors.red,
          ),
        );
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
        Navigator.pop(context);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoverImageSection(),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    ActimeTextField(
                      controller: _eventNameController,
                      labelText: 'Naziv događaja',
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    _buildCategoryDropdown(),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    _buildDateTimeRow(),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    ActimeTextField(
                      controller: _locationController,
                      labelText: 'Lokacija',
                      suffixIcon: const Icon(Icons.location_on_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    _buildPriceParticipantsRow(),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    ActimeTextField(
                      controller: _descriptionController,
                      labelText: 'Opis',
                      maxLines: 4,
                      isOutlined: true,
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

  Widget _buildCategoryDropdown() {
    return ActimeDropdownField<String>(
      initialValue: _selectedCategoryId,
      labelText: 'Kategorija',
      items: _categories
          .map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: ActimeTextField(
            controller: _dateController,
            labelText: 'Datum',
            readOnly: true,
            suffixIcon:
                const Icon(Icons.calendar_today, color: AppColors.primary),
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
                });
              }
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        Expanded(
          child: ActimeTextField(
            controller: _timeController,
            labelText: 'Vrijeme',
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
    );
  }

  Widget _buildPriceParticipantsRow() {
    return Row(
      children: [
        Expanded(
          child: ActimeTextField(
            controller: _priceController,
            labelText: 'Cijena (opcionalno)',
            keyboardType: TextInputType.number,
            prefixText: 'BAM ',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        Expanded(
          child: ActimeTextField(
            controller: _maxParticipantsController,
            labelText: 'Max učesnika',
            keyboardType: TextInputType.number,
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
