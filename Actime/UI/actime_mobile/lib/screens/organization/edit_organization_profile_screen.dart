import 'package:flutter/material.dart';
import 'widgets/save_changes_dialog.dart';

class EditOrganizationProfileScreen extends StatefulWidget {
  const EditOrganizationProfileScreen({super.key});

  @override
  State<EditOrganizationProfileScreen> createState() => _EditOrganizationProfileScreenState();
}

class _EditOrganizationProfileScreenState extends State<EditOrganizationProfileScreen> {
  final _nameController = TextEditingController(text: 'Student');
  final _categoryController = TextEditingController(text: 'Volleyball');
  final _phoneController = TextEditingController(text: '+12027953213');
  final _addressController = TextEditingController(text: '1894 Arlington Avenue');
  final _emailController = TextEditingController(text: 'club@volleyball.com');
  final _aboutController = TextEditingController(
    text: 'Practice yoga postures while learning about how yoga can be used to manage stress, improve the mind-body connection, and increase strength and flexibility.',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    super.dispose();
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
              color: Color(0xFF0D7C8C),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image with edit icon
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
            const SizedBox(height: 32),
            
            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Category
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                suffixIcon: const Icon(Icons.keyboard_arrow_down),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Phone
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Address
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // E-mail
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // About us
            TextField(
              controller: _aboutController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'About us',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D7C8C)),
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            // Save Button (opens confirmation)
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SaveChangesConfirmationDialog(
                          address: _addressController.text,
                          email: _emailController.text,
                          about: _aboutController.text,
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7C8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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