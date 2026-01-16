import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for managing user favorites (clubs and events)
/// Stores favorites locally using SharedPreferences
class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  static const String _favoriteClubsKey = 'favorite_clubs';
  static const String _favoriteEventsKey = 'favorite_events';

  // In-memory cache
  List<Organization>? _cachedFavoriteClubs;
  List<Event>? _cachedFavoriteEvents;

  /// Get all favorite clubs
  Future<List<Organization>> getFavoriteClubs() async {
    if (_cachedFavoriteClubs != null) {
      return _cachedFavoriteClubs!;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoriteClubsKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedFavoriteClubs = [];
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedFavoriteClubs = jsonList
          .map((item) => Organization.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedFavoriteClubs!;
    } catch (e) {
      _cachedFavoriteClubs = [];
      return [];
    }
  }

  /// Get all favorite events
  Future<List<Event>> getFavoriteEvents() async {
    if (_cachedFavoriteEvents != null) {
      return _cachedFavoriteEvents!;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoriteEventsKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedFavoriteEvents = [];
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedFavoriteEvents = jsonList
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedFavoriteEvents!;
    } catch (e) {
      _cachedFavoriteEvents = [];
      return [];
    }
  }

  /// Check if a club is in favorites
  Future<bool> isClubFavorite(String clubId) async {
    final clubs = await getFavoriteClubs();
    return clubs.any((club) => club.id == clubId);
  }

  /// Check if an event is in favorites
  Future<bool> isEventFavorite(String eventId) async {
    final events = await getFavoriteEvents();
    return events.any((event) => event.id == eventId);
  }

  /// Add a club to favorites
  Future<void> addClubToFavorites(Organization club) async {
    final clubs = await getFavoriteClubs();

    // Check if already exists
    if (clubs.any((c) => c.id == club.id)) {
      return;
    }

    clubs.add(club);
    _cachedFavoriteClubs = clubs;
    await _saveClubs(clubs);
  }

  /// Remove a club from favorites
  Future<void> removeClubFromFavorites(String clubId) async {
    final clubs = await getFavoriteClubs();
    clubs.removeWhere((club) => club.id == clubId);
    _cachedFavoriteClubs = clubs;
    await _saveClubs(clubs);
  }

  /// Toggle club favorite status
  Future<bool> toggleClubFavorite(Organization club) async {
    final isFavorite = await isClubFavorite(club.id);

    if (isFavorite) {
      await removeClubFromFavorites(club.id);
      return false;
    } else {
      await addClubToFavorites(club);
      return true;
    }
  }

  /// Add an event to favorites
  Future<void> addEventToFavorites(Event event) async {
    final events = await getFavoriteEvents();

    // Check if already exists
    if (events.any((e) => e.id == event.id)) {
      return;
    }

    events.add(event);
    _cachedFavoriteEvents = events;
    await _saveEvents(events);
  }

  /// Remove an event from favorites
  Future<void> removeEventFromFavorites(String eventId) async {
    final events = await getFavoriteEvents();
    events.removeWhere((event) => event.id == eventId);
    _cachedFavoriteEvents = events;
    await _saveEvents(events);
  }

  /// Toggle event favorite status
  Future<bool> toggleEventFavorite(Event event) async {
    final isFavorite = await isEventFavorite(event.id);

    if (isFavorite) {
      await removeEventFromFavorites(event.id);
      return false;
    } else {
      await addEventToFavorites(event);
      return true;
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoriteClubsKey);
    await prefs.remove(_favoriteEventsKey);
    _cachedFavoriteClubs = [];
    _cachedFavoriteEvents = [];
  }

  /// Save clubs to SharedPreferences
  Future<void> _saveClubs(List<Organization> clubs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(clubs.map((c) => c.toJson()).toList());
    await prefs.setString(_favoriteClubsKey, jsonString);
  }

  /// Save events to SharedPreferences
  Future<void> _saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_favoriteEventsKey, jsonString);
  }

  /// Get favorite clubs count
  Future<int> getFavoriteClubsCount() async {
    final clubs = await getFavoriteClubs();
    return clubs.length;
  }

  /// Get favorite events count
  Future<int> getFavoriteEventsCount() async {
    final events = await getFavoriteEvents();
    return events.length;
  }
}
