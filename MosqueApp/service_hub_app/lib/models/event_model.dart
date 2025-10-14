import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled
}

enum EventCategory {
  prayer,
  education,
  community,
  charity,
  celebration,
  meeting,
  other
}

class EventAttendee {
  final String userId;
  final String userName;
  final DateTime registeredAt;
  final bool emailReminder;
  final bool smsReminder;
  final bool notifyMosque;

  EventAttendee({
    required this.userId,
    required this.userName,
    required this.registeredAt,
    this.emailReminder = false,
    this.smsReminder = false,
    this.notifyMosque = false,
  });

  factory EventAttendee.fromMap(Map<String, dynamic> data) {
    return EventAttendee(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      emailReminder: data['emailReminder'] ?? false,
      smsReminder: data['smsReminder'] ?? false,
      notifyMosque: data['notifyMosque'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'emailReminder': emailReminder,
      'smsReminder': smsReminder,
      'notifyMosque': notifyMosque,
    };
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final String organizationId;
  final String organizationName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String location;
  final Map<String, dynamic>? coordinates;
  final EventStatus status;
  final List<String> imageUrls;
  final int maxAttendees;
  final List<EventAttendee> attendees;
  final bool requiresRegistration;
  final bool isPublic;
  final List<String> reportedBy;
  final Map<String, dynamic>? metadata;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.organizationId,
    required this.organizationName,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,
    this.coordinates,
    this.status = EventStatus.upcoming,
    this.imageUrls = const [],
    this.maxAttendees = 0, // 0 means unlimited
    this.attendees = const [],
    this.requiresRegistration = false,
    this.isPublic = true,
    this.reportedBy = const [],
    this.metadata,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: EventCategory.values.firstWhere(
        (e) => e.toString() == 'EventCategory.${data['category']}',
        orElse: () => EventCategory.other,
      ),
      organizationId: data['organizationId'] ?? '',
      organizationName: data['organizationName'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      startDateTime: (data['startDateTime'] as Timestamp).toDate(),
      endDateTime: (data['endDateTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      coordinates: data['coordinates'],
      status: EventStatus.values.firstWhere(
        (e) => e.toString() == 'EventStatus.${data['status']}',
        orElse: () => EventStatus.upcoming,
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      maxAttendees: data['maxAttendees'] ?? 0,
      attendees: (data['attendees'] as List<dynamic>?)
          ?.map((e) => EventAttendee.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      requiresRegistration: data['requiresRegistration'] ?? false,
      isPublic: data['isPublic'] ?? true,
      reportedBy: List<String>.from(data['reportedBy'] ?? []),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'location': location,
      'coordinates': coordinates,
      'status': status.toString().split('.').last,
      'imageUrls': imageUrls,
      'maxAttendees': maxAttendees,
      'attendees': attendees.map((e) => e.toMap()).toList(),
      'requiresRegistration': requiresRegistration,
      'isPublic': isPublic,
      'reportedBy': reportedBy,
      'metadata': metadata,
    };
  }

  bool get isFull {
    if (maxAttendees == 0) return false; // Unlimited
    return attendees.length >= maxAttendees;
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDateTime);
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  bool get isCompleted {
    return DateTime.now().isAfter(endDateTime);
  }

  EventModel copyWith({
    String? title,
    String? description,
    EventCategory? category,
    String? organizationId,
    String? organizationName,
    String? createdBy,
    DateTime? updatedAt,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    Map<String, dynamic>? coordinates,
    EventStatus? status,
    List<String>? imageUrls,
    int? maxAttendees,
    List<EventAttendee>? attendees,
    bool? requiresRegistration,
    bool? isPublic,
    List<String>? reportedBy,
    Map<String, dynamic>? metadata,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      attendees: attendees ?? this.attendees,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      isPublic: isPublic ?? this.isPublic,
      reportedBy: reportedBy ?? this.reportedBy,
      metadata: metadata ?? this.metadata,
    );
  }
}