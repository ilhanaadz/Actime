import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/image_service.dart';
import '../../utils/validators.dart';
import '../../utils/form_error_handler.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final _userService = UserService();
  final _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);

    try {
      final response = await _userService.getCurrentUser();

      if (!mounted) return;

      if (response.success && response.data != null) {
        _user = response.data;
        _firstNameController.text = _user?.firstName ?? '';
        _lastNameController.text = _user?.lastName ?? '';
        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() => _isSaving = true);

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      final response = await _userService.updateProfile({
        if (firstName.isNotEmpty) 'FirstName': firstName,
        if (lastName.isNotEmpty) 'LastName': lastName,
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil je uspješno ažuriran'),
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
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _changeProfileImage() async {
    final source = await showModalBottomSheet<ImageSource>(
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
          ],
        ),
      ),
    );

    if (source == null) return;

    final xFile = source == ImageSource.gallery
        ? await _imageService.pickImageFromGallery()
        : await _imageService.pickImageFromCamera();

    if (xFile == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final file = File(xFile.path);
      final uploadResponse = await _imageService.uploadImage(
        file,
        ImageUploadType.profile,
      );

      if (!mounted) return;

      if (uploadResponse.success && uploadResponse.data != null) {
        final updateResponse = await _userService.updateProfile({
          'ProfileImageUrl': uploadResponse.data,
        });

        if (!mounted) return;

        if (updateResponse.success) {
          setState(() {
            _user = _user?.copyWith(profileImageUrl: uploadResponse.data);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Slika je uspješno promijenjena')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(updateResponse.message ?? 'Greška pri spremanju')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uploadResponse.message ?? 'Greška pri uploadu')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Uredi profil',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.borderLight,
                            backgroundImage: _user?.avatar != null
                                ? NetworkImage(_imageService.getFullImageUrl(_user!.avatar))
                                : null,
                            child: _user?.avatar == null
                                ? Icon(Icons.person, size: 50, color: AppColors.textMuted)
                                : null,
                          ),
                          if (_isUploadingImage)
                            const Positioned.fill(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.black38,
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
                              onTap: _isUploadingImage ? null : _changeProfileImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
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

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (_fieldErrors['firstName'] != null) {
                          return _fieldErrors['firstName'];
                        }
                        return Validators.required(value, 'Ime');
                      },
                      decoration: InputDecoration(
                        labelText: 'Ime',
                        hintText: 'Unesite ime',
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

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (_fieldErrors['lastName'] != null) {
                          return _fieldErrors['lastName'];
                        }
                        return Validators.required(value, 'Prezime');
                      },
                      decoration: InputDecoration(
                        labelText: 'Prezime',
                        hintText: 'Unesite prezime',
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
                                  'Spremi',
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
    );
  }
}
