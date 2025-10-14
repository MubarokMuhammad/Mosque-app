import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/firebase_service.dart';
import '../services/local_notification_service.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> _events = [];
  List<EventModel> _myEvents = [];
  List<EventModel> _attendingEvents = [];
  EventModel? _selectedEvent;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'all';

  // Getters
  List<EventModel> get events => _getFilteredEvents();
  List<EventModel> get myEvents => _myEvents;
  List<EventModel> get attendingEvents => _attendingEvents;
  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // Load all events
  Future<void> loadEvents() async {
    try {
      _setLoading(true);
      _clearError();

      FirebaseService.getEvents().listen((events) {
        _events = events;
        _events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load events by organization
  Future<void> loadEventsByOrganization(String organizationId) async {
    try {
      _setLoading(true);
      _clearError();

      FirebaseService.getEvents(organizationId: organizationId).listen((events) {
        _events = events;
        _events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load user's created events
  Future<void> loadMyEvents(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _myEvents = await FirebaseService.getUserEvents(userId);
      _myEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load events user is attending
  Future<void> loadAttendingEvents(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _attendingEvents = await FirebaseService.getUserAttendingEvents(userId);
      _attendingEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create event
  Future<bool> createEvent({
    required String title,
    required String description,
    required String category,
    required String organizationId,
    required String organizationName,
    required String createdBy,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String location,
    double? latitude,
    double? longitude,
    int? maxAttendees,
    bool requiresRegistration = false,
    bool isPublic = true,
    List<String>? imageUrls,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Convert category string to EventCategory enum
      EventCategory eventCategory;
      try {
        eventCategory = EventCategory.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == category.toLowerCase(),
          orElse: () => EventCategory.other,
        );
      } catch (e) {
        eventCategory = EventCategory.other;
      }

      // Create coordinates map if latitude and longitude are provided
      Map<String, dynamic>? coordinates;
      if (latitude != null && longitude != null) {
        coordinates = {
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      EventModel event = EventModel(
        id: '',
        title: title,
        description: description,
        category: eventCategory,
        organizationId: organizationId,
        organizationName: organizationName,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: location,
        coordinates: coordinates,
        status: EventStatus.upcoming,
        imageUrls: imageUrls ?? [],
        attendees: [],
        maxAttendees: maxAttendees ?? 0,
        requiresRegistration: requiresRegistration,
        isPublic: isPublic,
      );

      String? eventId = await FirebaseService.createEvent(event);
      
      if (eventId != null) {
        event = event.copyWith();
        _events.add(event);
        _myEvents.add(event);
        _events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
        _myEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create event');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update event
  Future<bool> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.updateEvent(eventId, updates);
      
      // Update local data
      _updateLocalEvent(eventId, updates);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.deleteEvent(eventId);
      
      // Remove from local data
      _events.removeWhere((event) => event.id == eventId);
      _myEvents.removeWhere((event) => event.id == eventId);
      _attendingEvents.removeWhere((event) => event.id == eventId);
      
      if (_selectedEvent?.id == eventId) {
        _selectedEvent = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register for event
  Future<bool> registerForEvent(String eventId, String userId) async {
    try {
      _setLoading(true);
      _clearError();

      EventModel? event = getEventById(eventId);
      if (event == null) {
        _setError('Event not found');
        return false;
      }

      if (event.isFull) {
        _setError('Event is full');
        return false;
      }

      if (event.attendees.any((attendee) => attendee.userId == userId)) {
        _setError('Already registered for this event');
        return false;
      }

      await FirebaseService.addEventAttendee(eventId, userId);
      
      // Update local data
      _updateEventAttendees(eventId, userId, true);
      
      // Add to attending events
      EventModel? updatedEvent = _events.firstWhere((e) => e.id == eventId);
      if (updatedEvent != null && !_attendingEvents.any((e) => e.id == eventId)) {
        _attendingEvents.add(updatedEvent);
      }

      // Schedule event reminder notification
      if (event != null) {
        await LocalNotificationService().scheduleEventReminder(event);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Unregister from event
  Future<bool> unregisterFromEvent(String eventId, String userId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.unregisterFromEvent(eventId, userId);
      
      // Update local data
      _updateEventAttendees(eventId, userId, false);
      
      // Remove from attending events
      _attendingEvents.removeWhere((event) => event.id == eventId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Confirm attendance
  Future<bool> confirmAttendance(String eventId, String userId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.confirmEventAttendance(eventId, userId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel event
  Future<bool> cancelEvent(String eventId, String reason) async {
    try {
      _setLoading(true);
      _clearError();

      Map<String, dynamic> updates = {
        'status': EventStatus.cancelled.toString(),
        'updatedAt': DateTime.now().toIso8601String(),
        'metadata.cancellationReason': reason,
      };

      await FirebaseService.updateEvent(eventId, updates);
      
      // Update local data
      _updateLocalEvent(eventId, updates);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search events
  List<EventModel> searchEvents(String query) {
    List<EventModel> filtered = _getFilteredEvents();
    
    if (query.isEmpty) return filtered;
    
    return filtered.where((event) =>
      event.title.toLowerCase().contains(query.toLowerCase()) ||
      event.description.toLowerCase().contains(query.toLowerCase()) ||
      event.organizationName.toLowerCase().contains(query.toLowerCase()) ||
      event.location.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get upcoming events
  List<EventModel> getUpcomingEvents() {
    return _events.where((event) => event.isUpcoming).toList();
  }

  // Get ongoing events
  List<EventModel> getOngoingEvents() {
    return _events.where((event) => event.isOngoing).toList();
  }

  // Get events by date range
  List<EventModel> getEventsByDateRange(DateTime start, DateTime end) {
    return _events.where((event) =>
      event.startDateTime.isAfter(start) && event.startDateTime.isBefore(end)
    ).toList();
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Get filtered events based on category
  List<EventModel> _getFilteredEvents() {
    List<EventModel> activeEvents = _events.where((event) => 
      event.status != EventStatus.cancelled && event.isPublic
    ).toList();

    if (_selectedCategory == 'all') {
      return activeEvents;
    }
    
    return activeEvents.where((event) => 
      event.category.toString().split('.').last.toLowerCase() == _selectedCategory.toLowerCase()
    ).toList();
  }

  // Get event by ID
  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Set selected event
  void setSelectedEvent(EventModel? event) {
    _selectedEvent = event;
    notifyListeners();
  }

  // Check if user is registered for event
  bool isUserRegistered(String eventId, String userId) {
    EventModel? event = getEventById(eventId);
    return event?.attendees.any((attendee) => attendee.userId == userId) ?? false;
  }

  // Helper methods
  void _updateLocalEvent(String eventId, Map<String, dynamic> updates) {
    // Update in events list
    int index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _events[index] = _updateEventWithMap(_events[index], updates);
    }

    // Update in my events list
    int myIndex = _myEvents.indexWhere((event) => event.id == eventId);
    if (myIndex != -1) {
      _myEvents[myIndex] = _updateEventWithMap(_myEvents[myIndex], updates);
    }

    // Update in attending events list
    int attendingIndex = _attendingEvents.indexWhere((event) => event.id == eventId);
    if (attendingIndex != -1) {
      _attendingEvents[attendingIndex] = _updateEventWithMap(_attendingEvents[attendingIndex], updates);
    }

    // Update selected event
    if (_selectedEvent?.id == eventId) {
      _selectedEvent = _updateEventWithMap(_selectedEvent!, updates);
    }
  }

  EventModel _updateEventWithMap(EventModel event, Map<String, dynamic> updates) {
    return event.copyWith(
      title: updates['title'],
      description: updates['description'],
      category: updates['category'],
      startDateTime: updates['startDateTime'] != null ? DateTime.parse(updates['startDateTime']) : null,
      endDateTime: updates['endDateTime'] != null ? DateTime.parse(updates['endDateTime']) : null,
      location: updates['location'],
      coordinates: updates['coordinates'] ?? {
        'lat': updates['latitude']?.toDouble() ?? 0.0,
        'lng': updates['longitude']?.toDouble() ?? 0.0,
      },
      status: updates['status'] != null ?
        EventStatus.values.firstWhere((s) => s.toString() == updates['status']) : null,
      maxAttendees: updates['maxAttendees'],
      requiresRegistration: updates['requiresRegistration'],
      isPublic: updates['isPublic'],
      updatedAt: DateTime.now(),
    );
  }

  void _updateEventAttendees(String eventId, String userId, bool add) {
    // Update in events list
    int index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      List<EventAttendee> attendees = List.from(_events[index].attendees);
      if (add && !attendees.any((a) => a.userId == userId)) {
        attendees.add(EventAttendee(
          userId: userId,
          userName: 'User', // TODO: Get actual username
          registeredAt: DateTime.now(),
        ));
      } else if (!add) {
        attendees.removeWhere((a) => a.userId == userId);
      }
      _events[index] = _events[index].copyWith(attendees: attendees);
      
      // Add to attending events if registering
      if (add && !_attendingEvents.any((e) => e.id == eventId)) {
        _attendingEvents.add(_events[index]);
        _attendingEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      }
    }

    // Update in my events list
    int myIndex = _myEvents.indexWhere((event) => event.id == eventId);
    if (myIndex != -1) {
      List<EventAttendee> attendees = List.from(_myEvents[myIndex].attendees);
      if (add && !attendees.any((a) => a.userId == userId)) {
        attendees.add(EventAttendee(
          userId: userId,
          userName: 'User', // TODO: Get actual username
          registeredAt: DateTime.now(),
        ));
      } else if (!add) {
        attendees.removeWhere((a) => a.userId == userId);
      }
      _myEvents[myIndex] = _myEvents[myIndex].copyWith(attendees: attendees);
    }

    // Update selected event
    if (_selectedEvent?.id == eventId) {
      List<EventAttendee> attendees = List.from(_selectedEvent!.attendees);
      if (add && !attendees.any((a) => a.userId == userId)) {
        attendees.add(EventAttendee(
          userId: userId,
          userName: 'User', // TODO: Get actual username
          registeredAt: DateTime.now(),
        ));
      } else if (!add) {
        attendees.removeWhere((a) => a.userId == userId);
      }
      _selectedEvent = _selectedEvent!.copyWith(attendees: attendees);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}