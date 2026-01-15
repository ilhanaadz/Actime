import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_text_field.dart';
import '../../components/actime_button.dart';
import '../../components/circle_icon_container.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _descriptionController = TextEditingController();
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
          'Create Event',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrganizationInfo(),
              const SizedBox(height: AppDimensions.spacingXLarge),
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
                label: 'Create Event',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event created successfully!')),
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

  Widget _buildOrganizationInfo() {
    return Row(
      children: [
        CircleIconContainer(
          icon: Icons.sports_volleyball,
          iconColor: AppColors.orange,
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Volleyball',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textHint),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            'Add event cover image',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2025),
              );
              if (date != null) {
                _dateController.text = '${date.day}.${date.month}.${date.year}';
              }
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        Expanded(
          child: ActimeTextField(
            controller: _timeController,
            labelText: 'Time',
            readOnly: true,
            suffixIcon: const Icon(Icons.access_time, color: AppColors.primary),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                _timeController.text = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
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
            labelText: 'Price (optional)',
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
}
