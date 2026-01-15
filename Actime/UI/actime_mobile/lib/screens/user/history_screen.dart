import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import '../../models/models.dart';
import '../../services/services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _userService = UserService();
  final _authService = AuthService();

  List<Event> _events = [];
  bool _isLoading = true;
  String? _error;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'Niste prijavljeni';
          _isLoading = false;
        });
        return;
      }

      final response = await _userService.getUserEventHistory(currentUser.id);

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _events = response.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Greška pri učitavanju historije';
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

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy.').format(date);
  }

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'sport':
        return Icons.sports_soccer;
      case 'kultura':
        return Icons.palette;
      case 'edukacija':
        return Icons.school;
      case 'zdravlje':
        return Icons.favorite;
      case 'muzika':
        return Icons.music_note;
      case 'tehnologija':
        return Icons.computer;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        onFavoriteTap: () {},
        onProfileTap: () {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Historija',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTab('Svi', 0),
                const SizedBox(width: 12),
                _buildTab('Ovaj mjesec', 1),
                const SizedBox(width: 12),
                _buildTab('Ova godina', 2),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavUser(currentIndex: 2),
    );
  }

  Widget _buildContent() {
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
              onPressed: _loadHistory,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nemate historiju događaja',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return _buildEventCard(
            event.name,
            event.formattedPrice,
            _formatDate(event.startDate),
            event.location ?? 'Nije određeno',
            event.participantsCount.toString(),
            _getCategoryIcon(event.categoryName),
            event.status == EventStatus.completed,
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String price,
    String date,
    String location,
    String participants,
    IconData icon,
    bool isCompleted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.orange, size: 24),
              ),
              if (isCompleted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(price, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                    const Spacer(),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Prisustvovao',
                          style: TextStyle(color: Colors.green, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(participants, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(location, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
