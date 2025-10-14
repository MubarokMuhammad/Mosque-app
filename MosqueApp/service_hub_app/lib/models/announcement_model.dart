import 'package:cloud_firestore/cloud_firestore.dart';

enum AnnouncementCategory {
  general,
  event,
  prayer,
  education,
  charity,
  community,
  emergency,
  other
}

enum AnnouncementStatus {
  active,
  expired,
  cancelled,
  draft
}

class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final AnnouncementCategory category;
  final String organizationId;
  final String organizationName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final AnnouncementStatus status;
  final List<String> imageUrls;
  final bool isBoosted;
  final DateTime? boostedUntil;
  final double? boostPrice;
  final bool emailNotification;
  final bool smsNotification;
  final int viewCount;
  final List<String> reportedBy;
  final Map<String, dynamic>? metadata;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.organizationId,
    required this.organizationName,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.status = AnnouncementStatus.active,
    this.imageUrls = const [],
    this.isBoosted = false,
    this.boostedUntil,
    this.boostPrice,
    this.emailNotification = false,
    this.smsNotification = false,
    this.viewCount = 0,
    this.reportedBy = const [],
    this.metadata,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: AnnouncementCategory.values.firstWhere(
        (e) => e.toString() == 'AnnouncementCategory.${data['category']}',
        orElse: () => AnnouncementCategory.general,
      ),
      organizationId: data['organizationId'] ?? '',
      organizationName: data['organizationName'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
      status: AnnouncementStatus.values.firstWhere(
        (e) => e.toString() == 'AnnouncementStatus.${data['status']}',
        orElse: () => AnnouncementStatus.active,
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      isBoosted: data['isBoosted'] ?? false,
      boostedUntil: data['boostedUntil'] != null 
          ? (data['boostedUntil'] as Timestamp).toDate() 
          : null,
      boostPrice: data['boostPrice']?.toDouble(),
      emailNotification: data['emailNotification'] ?? false,
      smsNotification: data['smsNotification'] ?? false,
      viewCount: data['viewCount'] ?? 0,
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
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'status': status.toString().split('.').last,
      'imageUrls': imageUrls,
      'isBoosted': isBoosted,
      'boostedUntil': boostedUntil != null ? Timestamp.fromDate(boostedUntil!) : null,
      'boostPrice': boostPrice,
      'emailNotification': emailNotification,
      'smsNotification': smsNotification,
      'viewCount': viewCount,
      'reportedBy': reportedBy,
      'metadata': metadata,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isCurrentlyBoosted {
    if (!isBoosted || boostedUntil == null) return false;
    return DateTime.now().isBefore(boostedUntil!);
  }

  AnnouncementModel copyWith({
    String? title,
    String? description,
    AnnouncementCategory? category,
    String? organizationId,
    String? organizationName,
    String? createdBy,
    DateTime? updatedAt,
    DateTime? expiresAt,
    AnnouncementStatus? status,
    List<String>? imageUrls,
    bool? isBoosted,
    DateTime? boostedUntil,
    double? boostPrice,
    bool? emailNotification,
    bool? smsNotification,
    int? viewCount,
    List<String>? reportedBy,
    Map<String, dynamic>? metadata,
  }) {
    return AnnouncementModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      isBoosted: isBoosted ?? this.isBoosted,
      boostedUntil: boostedUntil ?? this.boostedUntil,
      boostPrice: boostPrice ?? this.boostPrice,
      emailNotification: emailNotification ?? this.emailNotification,
      smsNotification: smsNotification ?? this.smsNotification,
      viewCount: viewCount ?? this.viewCount,
      reportedBy: reportedBy ?? this.reportedBy,
      metadata: metadata ?? this.metadata,
    );
  }
}