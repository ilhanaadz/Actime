import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../components/confirmation_dialog.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _eventNameController = TextEditingController(text: 'Bjelašnica hiking trip');
  final _locationController = TextEditingController(text: 'Bjelašnica');
  final _dateController = TextEditingController(text: '11.10.2022');
  final _timeController = TextEditingController(text: '06:00');
  final _priceController = TextEditingController(text: '0');
  final _maxParticipantsController = TextEditingController(text: '250');
  final _descriptionController = TextEditingController(
    text: 'Departing between 06:00am and 07:00am in Lehn at Längenfeld, this demanding long walk lets avid hikers explore the lofty and rugged mountain world of Ötztal Valley.',
  );
  String _selectedCategory = 'Sports';

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
          'Edit Event',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImageSection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              ActimeTextField(
                controller: _eventNameController,
                labelText: 'Event Name',
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildCategoryDropdown(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildDateTimeRow(),
              const SizedBox(height: AppDimensions.spacingLarge),
              ActimeTextField(
                controller: _locationController,
                labelText: 'Location',
                suffixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildPriceParticipantsRow(),
              const SizedBox(height: AppDimensions.spacingLarge),
              ActimeTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 4,
                isOutlined: true,
              ),
              const SizedBox(height: AppDimensions.spacingXLarge),
              ActimePrimaryButton(
                label: 'Save Changes',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event updated successfully!')),
                  );
                  Navigator.pop(context);
                },
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
      initialValue: _selectedCategory,
      labelText: 'Category',
      items: ['Sports', 'Music', 'Art', 'Education', 'Other']
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
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
            labelText: 'Date',
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        Expanded(
          child: ActimeTextField(
            controller: _timeController,
            labelText: 'Time',
            readOnly: true,
            suffixIcon: const Icon(Icons.access_time, color: AppColors.primary),
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
            labelText: 'Price',
            keyboardType: TextInputType.number,
            prefixText: '\$ ',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        Expanded(
          child: ActimeTextField(
            controller: _maxParticipantsController,
            labelText: 'Max Participants',
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await ConfirmationDialog.showDelete(
      context: context,
      itemName: 'Event',
    );
    if (confirmed == true && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted')),
      );
    }
  }
}
