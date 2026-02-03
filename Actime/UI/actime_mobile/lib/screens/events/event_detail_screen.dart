import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/info_row.dart';
import '../../components/actime_button.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../auth/sign_in_screen.dart';
import 'checkout_bottom_sheet.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final bool isLoggedIn;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.isLoggedIn = true,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _eventService = EventService();
  final _favoriteService = FavoriteService();

  Event? _event;
  bool _isLoading = true;
  bool _isJoining = false;
  bool _isFavorite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _eventService.getEventById(widget.eventId);

      if (!mounted) return;

      if (response.success && response.data != null) {
        _event = response.data;
        await _checkFavoriteStatus();
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Greška pri učitavanju događaja';
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

  Future<void> _checkFavoriteStatus() async {
    if (_event == null) return;
    final isFav = await _favoriteService.isEventFavorite(_event!.id);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_event == null) return;
    final newStatus = await _favoriteService.toggleEventFavorite(_event!);
    if (mounted) {
      setState(() => _isFavorite = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus
              ? 'Dodano u favorite'
              : 'Uklonjeno iz favorita'),
        ),
      );
    }
  }

  Future<void> _handleJoinEvent() async {
    if (_event == null) return;

    // Paid event — show checkout; user pays (dummy), then we join with method.
    if (!_event!.isFree) {
      final paymentMethodId = await CheckoutBottomSheet.show(context, _event!);
      if (paymentMethodId == null) return; // user dismissed
      await _processJoinEvent(paymentMethodId: paymentMethodId);
      return;
    }

    // Free event - join directly
    await _processJoinEvent();
  }

  Future<void> _processJoinEvent({int? paymentMethodId}) async {
    if (_event == null) return;

    setState(() => _isJoining = true);

    try {
      final response = await _eventService.joinEvent(
        _event!,
        paymentMethodId: paymentMethodId,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uspješno ste se prijavili na događaj!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh event data
        _loadEvent();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri prijavi'),
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
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _handleLeaveEvent() async {
    if (_event == null) return;

    setState(() => _isJoining = true);

    try {
      final response = await _eventService.leaveEvent(_event!.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uspješno ste otkazali prijavu.'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh event data
        _loadEvent();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri otkazivanju'),
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
        setState(() => _isJoining = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy.').format(date);
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
              onPressed: _loadEvent,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_event == null) {
      return const Center(
        child: Text('Događaj nije pronađen'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrganizerSection(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildTitleSection(),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              _event!.activityTypeName ?? 'Događaj',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            InfoRow(icon: Icons.calendar_today, text: _formatDate(_event!.startDate)),
            const SizedBox(height: AppDimensions.spacingMedium),
            InfoRow(
              icon: Icons.location_on_outlined,
              text: _event!.location ?? 'Nije određeno',
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            InfoRow(
              icon: Icons.attach_money,
              text: _event!.formattedPrice,
            ),
            if (_event!.maxParticipants != null) ...[
              const SizedBox(height: AppDimensions.spacingMedium),
              InfoRow(
                icon: Icons.group,
                text: '${_event!.participantsCount}/${_event!.maxParticipants} učesnika',
              ),
            ],
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildDetailsSection(),
            const SizedBox(height: AppDimensions.spacingXLarge),
            _buildJoinButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organizator',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  _event!.organizationName ?? 'Nepoznato',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Text(
              _event!.participantsCount.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXSmall),
            Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
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
          child: Text(
            _event!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : AppColors.primary,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalji',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Text(
          _event!.description ?? 'Nema opisa za ovaj događaj.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton() {
    final isUpcoming = _event!.status == EventStatus.upcoming;
    final isPassed = _event!.status == EventStatus.completed ||
        _event!.status == EventStatus.cancelled ||
        _event!.status == EventStatus.inProgress;

    if (_isJoining) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Event has passed - show disabled button
    if (isPassed) {
      String label;
      switch (_event!.status) {
        case EventStatus.completed:
          label = 'Završeno';
          break;
        case EventStatus.cancelled:
          label = 'Otkazano';
          break;
        case EventStatus.inProgress:
          label = 'U toku';
          break;
        default:
          label = 'Završeno';
      }
      return ActimePrimaryButton(
        label: label,
        onPressed: null,
      );
    }

    // Not logged in - show button that redirects to login
    if (!widget.isLoggedIn) {
      final canJoin = _event!.hasAvailableSpots && isUpcoming;
      return ActimePrimaryButton(
        label: canJoin ? 'Pridruži se' : 'Popunjeno',
        onPressed: canJoin
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              }
            : null,
      );
    }

    // Already enrolled - show cancel button
    if (_event!.isEnrolled) {
      return ActimeOutlinedButton(
        label: 'Otkaži prijavu',
        onPressed: isUpcoming ? _handleLeaveEvent : null,
      );
    }

    // Not enrolled - show join button
    final canJoin = _event!.hasAvailableSpots && isUpcoming;
    return ActimePrimaryButton(
      label: canJoin ? 'Pridruži se' : 'Popunjeno',
      onPressed: canJoin ? _handleJoinEvent : null,
    );
  }
}
