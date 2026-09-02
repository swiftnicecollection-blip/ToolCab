import 'dart:convert';

import '../../../../core/services/storage_service.dart';

/// Model representing a calendar event.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
    this.description = '',
    this.startTime,
    this.endTime,
    this.location = '',
    this.colorValue = 0xFF3B82F6,
    this.updatedAt,
  });

  /// Creates an event from a JSON map.
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      location: (json['location'] as String?) ?? '',
      colorValue: (json['colorValue'] as int?) ?? 0xFF3B82F6,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Unique event ID.
  final String id;

  /// Event title.
  final String title;

  /// Event description.
  final String description;

  /// Event date.
  final DateTime date;

  /// Start time (optional).
  final DateTime? startTime;

  /// End time (optional).
  final DateTime? endTime;

  /// Event location.
  final String location;

  /// Color value for the event.
  final int colorValue;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  /// Creates a copy with updated fields.
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the event to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Repository for calendar events using Hive local storage.
class CalendarRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for calendar events.
  static const String _eventsKey = 'calendar_events';

  /// Saves a calendar event.
  Future<void> saveEvent(CalendarEvent event) async {
    final List<Map<String, dynamic>> events = await _readEvents();
    final int index = events.indexWhere(
      (Map<String, dynamic> e) => e['id'] == event.id,
    );
    if (index >= 0) {
      events[index] = event.toJson();
    } else {
      events.insert(0, event.toJson());
    }
    await _writeEvents(events);
  }

  /// Returns all calendar events.
  Future<List<CalendarEvent>> getEvents() async {
    final List<Map<String, dynamic>> events = await _readEvents();
    return events.map(CalendarEvent.fromJson).toList();
  }

  /// Returns events for a specific date.
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final List<CalendarEvent> allEvents = await getEvents();
    return allEvents
        .where((CalendarEvent e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,)
        .toList();
  }

  /// Deletes a calendar event by ID.
  Future<void> deleteEvent(String id) async {
    final List<Map<String, dynamic>> events = await _readEvents();
    events.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeEvents(events);
  }

  /// Clears all calendar events.
  Future<void> clearEvents() async {
    await _storageService.history.delete(_eventsKey);
  }

  /// Reads events from storage.
  Future<List<Map<String, dynamic>>> _readEvents() async {
    final dynamic raw = _storageService.history.get(_eventsKey);
    if (raw == null) {
      return <Map<String, dynamic>>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw as String) as List<dynamic>;
      return decoded.map((dynamic e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  /// Writes events to storage.
  Future<void> _writeEvents(List<Map<String, dynamic>> events) async {
    await _storageService.history.put(_eventsKey, jsonEncode(events));
  }
}
