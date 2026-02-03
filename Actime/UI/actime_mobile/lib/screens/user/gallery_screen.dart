import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/image_service.dart';
import '../../services/gallery_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _userService = UserService();
  final _galleryService = GalleryService();
  final _imageService = ImageService();

  User? _user;
  List<GalleryImage> _images = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userResponse = await _userService.getCurrentUser();

      if (!mounted) return;

      if (userResponse.success && userResponse.data != null) {
        _user = userResponse.data;

        final galleryResponse = await _galleryService.getByUserId(_user!.id);
        if (galleryResponse.success && galleryResponse.data != null) {
          _images = galleryResponse.data!;
        }
      }
    } catch (e) {
      // Ignore errors
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage() async {
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

    setState(() => _isUploading = true);

    try {
      final file = File(xFile.path);
      final uploadResponse = await _imageService.uploadImage(
        file,
        ImageUploadType.gallery,
      );

      if (!mounted) return;

      if (uploadResponse.success && uploadResponse.data != null) {
        final addResponse = await _galleryService.addImage(
          imageUrl: uploadResponse.data!,
          userId: _user?.id,
        );

        if (!mounted) return;

        if (addResponse.success && addResponse.data != null) {
          setState(() {
            _images.insert(0, addResponse.data!);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Slika je uspješno dodana')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(addResponse.message ?? 'Greška pri spremanju')),
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
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteImage(GalleryImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši sliku'),
        content: const Text('Da li ste sigurni da želite obrisati ovu sliku?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await _galleryService.deleteImage(image.id);

    if (!mounted) return;

    if (response.success) {
      setState(() {
        _images.removeWhere((i) => i.id == image.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slika je obrisana')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Greška pri brisanju')),
      );
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gallery',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
            onPressed: _isUploading ? null : _uploadImage,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.orange.shade50,
                        backgroundImage: _user?.avatar != null
                            ? NetworkImage(_imageService.getFullImageUrl(_user!.avatar))
                            : null,
                        child: _user?.avatar == null
                            ? const Icon(Icons.person, color: Colors.orange, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user?.fullName ?? 'Korisnik',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${_images.length} slika',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Gallery Grid
                  Expanded(
                    child: _images.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Vaša galerija je prazna',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _uploadImage,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Dodaj prvu sliku'),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              final image = _images[index];
                              return GestureDetector(
                                onLongPress: () => _deleteImage(image),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _imageService.getFullImageUrl(image.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
