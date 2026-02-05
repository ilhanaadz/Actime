import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../constants/participation_constants.dart';
import '../../components/circle_icon_container.dart';
import '../../components/info_row.dart';
import '../../components/actime_button.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/gallery_service.dart';
import '../../services/image_service.dart';
import '../auth/sign_in_screen.dart';
import 'enrollment_application_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final String organizationId;
  final bool isLoggedIn;

  const ClubDetailScreen({
    super.key,
    required this.organizationId,
    this.isLoggedIn = true,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final _organizationService = OrganizationService();
  final _userService = UserService();
  final _reviewService = ReviewService();
  final _authService = AuthService();
  final _favoriteService = FavoriteService();
  final _galleryService = GalleryService();
  final _imageService = ImageService();

  Organization? _organization;
  List<Review> _reviews = [];
  List<GalleryImage> _galleryImages = [];
  double _averageRating = 0.0;
  bool _isLoading = true;
  bool _isCancelling = false;
  bool _isFavorite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrganization();
    _loadReviews();
    _loadFavoriteStatus();
    _loadGallery();
  }

  Future<void> _loadFavoriteStatus() async {
    if (!widget.isLoggedIn) return;
    final isFavorite = await _favoriteService.isClubFavorite(
      widget.organizationId,
    );
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (!widget.isLoggedIn || _organization == null) return;
    final isFavorite = await _favoriteService.toggleClubFavorite(
      _organization!,
    );
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _loadOrganization() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _organizationService.getOrganizationById(
        widget.organizationId,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _organization = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Greška pri učitavanju kluba';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Došlo je do greške. Pokušajte ponovo.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    final orgId = int.tryParse(widget.organizationId);
    if (orgId == null) return;

    try {
      final reviewsFuture = _reviewService.getReviewsByOrganization(orgId);
      final avgFuture = _reviewService.getOrganizationAverageRating(orgId);

      final reviewsResponse = await reviewsFuture;
      final avgResponse = await avgFuture;

      if (!mounted) return;

      setState(() {
        if (reviewsResponse.success && reviewsResponse.data != null) {
          _reviews = reviewsResponse.data!;
        }
        if (avgResponse.success && avgResponse.data != null) {
          _averageRating = avgResponse.data!;
        }
      });
    } catch (_) {
      // Reviews are non-critical — fail silently
    }
  }

  Future<void> _loadGallery() async {
    try {
      final response = await _galleryService.getByOrganizationId(
        widget.organizationId,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _galleryImages = response.data!;
        });
      }
    } catch (_) {
      // Gallery is non-critical — fail silently
    }
  }

  Future<void> _handleCancelMembership() async {
    if (_organization == null) return;

    final isPending =
        _organization!.membershipStatusId == MembershipStatus.pending;

    setState(() => _isCancelling = true);

    try {
      final response = await _userService.cancelMembershipByOrganization(
        _organization!.id,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPending
                  ? 'Prijava je uspješno otkazana.'
                  : 'Članstvo je uspješno otkazano.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh user data to update organization counts
        await _authService.getCurrentUser();
        // Refresh organization data
        _loadOrganization();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ??
                  (isPending
                      ? 'Greška pri otkazivanju prijave'
                      : 'Greška pri otkazivanju članstva'),
            ),
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
        setState(() => _isCancelling = false);
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              _error!,
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            TextButton(
              onPressed: _loadOrganization,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_organization == null) {
      return const Center(child: Text('Klub nije pronađen'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildTitleSection(),
            const SizedBox(height: AppDimensions.spacingLarge),
            if (_organization!.phone != null &&
                _organization!.phone!.isNotEmpty)
              InfoRow(icon: Icons.phone_outlined, text: _organization!.phone!),
            if (_organization!.phone != null &&
                _organization!.phone!.isNotEmpty)
              const SizedBox(height: AppDimensions.spacingMedium),
            if (_organization!.email != null &&
                _organization!.email!.isNotEmpty)
              InfoRow(icon: Icons.email_outlined, text: _organization!.email!),
            if (_organization!.email != null &&
                _organization!.email!.isNotEmpty)
              const SizedBox(height: AppDimensions.spacingMedium),
            if (_organization!.address != null &&
                _organization!.address!.isNotEmpty)
              InfoRow(
                icon: Icons.location_on_outlined,
                text: _organization!.address!,
              ),
            if (_organization!.address != null &&
                _organization!.address!.isNotEmpty)
              const SizedBox(height: AppDimensions.spacingMedium),
            InfoRow(
              icon: Icons.event,
              text: '${_organization!.eventsCount} događaja',
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildAboutSection(),
            if (_galleryImages.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildGallerySection(),
            ],
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildReviewsSection(),
            const SizedBox(height: AppDimensions.spacingXLarge),
            _buildMembershipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.borderLight,
              backgroundImage: _organization?.logoUrl != null
                  ? NetworkImage(_organization!.logoUrl!)
                  : null,
              child: _organization?.logoUrl == null
                  ? Icon(Icons.groups, size: 50, color: AppColors.textMuted)
                  : null,
            ),
          ],
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        if (_organization!.isVerified)
          Stack(
            children: [
              CircleIconContainer.xLarge(
                icon: Icons.verified,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.inputBackground,
              ),
            ],
          ),
        const Spacer(),
        Row(
          children: [
            Text(
              _organization!.membersCount.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXSmall),
            const Icon(
              Icons.person_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _organization!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXSmall),
              Text(
                _organization!.categoryName ?? 'Klub',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.isLoggedIn)
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.red : AppColors.primary,
            ),
            onPressed: _toggleFavorite,
          ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'O klubu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Text(
          _organization!.description ?? 'Nema opisa za ovaj klub.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galerija',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _galleryImages.length,
            itemBuilder: (context, index) {
              final image = _galleryImages[index];
              return GestureDetector(
                onTap: () => _showImageViewer(index),
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(
                    right: index < _galleryImages.length - 1
                        ? AppDimensions.spacingSmall
                        : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusLarge,
                    ),
                    child: Image.network(
                      _imageService.getFullImageUrl(image.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.inputBackground,
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showImageViewer(int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => _ImageViewerDialog(
        images: _galleryImages,
        initialIndex: initialIndex,
        imageService: _imageService,
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recenzije',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (widget.isLoggedIn)
              ActimeTextButton(
                label: 'Napišite recenziju',
                onPressed: _showLeaveReviewSheet,
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        if (_reviews.isNotEmpty) ...[
          _buildAverageRating(),
          const SizedBox(height: AppDimensions.spacingMedium),
          ...(_reviews.take(5).map((review) => _buildReviewCard(review))),
        ] else
          Text(
            'Još nema recenzija za ovaj klub.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
      ],
    );
  }

  Widget _buildAverageRating() {
    return Row(
      children: [
        Text(
          _averageRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < _averageRating.round() ? Icons.star : Icons.star_outline,
              color: AppColors.orange,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        Text(
          '(${_reviews.length} recenzija)',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_outline,
                    color: AppColors.orange,
                    size: 16,
                  ),
                ),
              ),
              Text(
                DateFormat('dd.MM.yyyy.').format(review.createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXSmall),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showLeaveReviewSheet() async {
    if (_organization == null) return;
    final orgId = int.tryParse(_organization!.id);
    if (orgId == null) return;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LeaveReviewSheet(organizationId: orgId),
    );

    if (submitted == true) {
      _loadReviews();
    }
  }

  Widget _buildMembershipButton() {
    if (_isCancelling) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Not logged in - show button that redirects to login
    if (!widget.isLoggedIn) {
      return ActimePrimaryButton(
        label: 'Prijava za članstvo',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        },
      );
    }

    final membershipStatus = _organization!.membershipStatusId;

    // Check membership status
    if (membershipStatus != null) {
      switch (membershipStatus) {
        case MembershipStatus.pending:
          // Application sent, waiting for approval
          return ActimeOutlinedButton(
            label: 'Otkaži prijavu',
            onPressed: _handleCancelMembership,
          );
        case MembershipStatus.active:
          // Active member - can cancel membership
          return ActimeOutlinedButton(
            label: 'Otkaži članstvo',
            onPressed: _handleCancelMembership,
          );
        case MembershipStatus.rejected:
        case MembershipStatus.cancelled:
        case MembershipStatus.expired:
          // Can apply again
          break;
        default:
          break;
      }
    }

    // No membership or can apply again - show join button
    return ActimePrimaryButton(
      label: 'Prijava za članstvo',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnrollmentApplicationScreen(
              organizationId: _organization!.id,
              organizationName: _organization!.name,
            ),
          ),
        ).then((_) async {
          // Refresh user data to update organization counts
          await _authService.getCurrentUser();
          _loadOrganization();
        });
      },
    );
  }
}

/// Bottom sheet for submitting a new review.
/// Returns `true` via Navigator.pop when submission succeeds.
class _LeaveReviewSheet extends StatefulWidget {
  final int organizationId;

  const _LeaveReviewSheet({required this.organizationId});

  @override
  State<_LeaveReviewSheet> createState() => __LeaveReviewSheetState();
}

class __LeaveReviewSheetState extends State<_LeaveReviewSheet> {
  final _reviewService = ReviewService();
  final _authService = AuthService();
  final _commentController = TextEditingController();

  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) return;

    final userId = _authService.currentUserId;
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    final response = await _reviewService.createReview(
      userId: userId,
      organizationId: widget.organizationId,
      rating: _selectedRating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.success) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Recenzija je uspješno dodana!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Greška pri dodavanju recenzije'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingLarge,
        right: AppDimensions.spacingLarge,
        top: AppDimensions.spacingLarge,
        bottom:
            AppDimensions.spacingLarge +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          const Text(
            'Napišite recenziju',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXSmall),
          Text(
            'Ocijenite ovaj klub od 1 do 5 zvezda',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          // Star selector
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _selectedRating = i + 1),
                child: Icon(
                  (i + 1) <= _selectedRating ? Icons.star : Icons.star_outline,
                  color: AppColors.orange,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          // Comment field
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Dodajte komentarz (opcionalno)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusLarge,
                ),
              ),
              contentPadding: const EdgeInsets.all(AppDimensions.spacingMedium),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          // Submit
          ActimePrimaryButton(
            label: 'Podijeliti recenziju',
            onPressed: _selectedRating > 0 && !_isSubmitting ? _submit : null,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer dialog with swipe navigation
class _ImageViewerDialog extends StatefulWidget {
  final List<GalleryImage> images;
  final int initialIndex;
  final ImageService imageService;

  const _ImageViewerDialog({
    required this.images,
    required this.initialIndex,
    required this.imageService,
  });

  @override
  State<_ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<_ImageViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.imageService.getFullImageUrl(image.imageUrl),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Image counter
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
