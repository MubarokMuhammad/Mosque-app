import 'package:cloud_firestore/cloud_firestore.dart';

enum OrganizationCategory {
  mosque,
  community,
  charity,
  education,
  healthcare,
  other
}

class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final OrganizationCategory category;
  final String email;
  final String phone;
  final String address;
  final Map<String, dynamic> location; // lat, lng
  final String legalProof;
  final String directContactName;
  final String directContactPhone;
  final List<String> adminIds;
  final List<String> memberIds;
  final String? logoUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? settings;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.email,
    required this.phone,
    required this.address,
    required this.location,
    required this.legalProof,
    required this.directContactName,
    required this.directContactPhone,
    this.adminIds = const [],
    this.memberIds = const [],
    this.logoUrl,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.settings,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrganizationModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: OrganizationCategory.values.firstWhere(
        (e) => e.toString() == 'OrganizationCategory.${data['category']}',
        orElse: () => OrganizationCategory.other,
      ),
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      location: Map<String, dynamic>.from(data['location'] ?? {}),
      legalProof: data['legalProof'] ?? '',
      directContactName: data['directContactName'] ?? '',
      directContactPhone: data['directContactPhone'] ?? '',
      adminIds: List<String>.from(data['adminIds'] ?? []),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      logoUrl: data['logoUrl'],
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      settings: data['settings'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category.toString().split('.').last,
      'email': email,
      'phone': phone,
      'address': address,
      'location': location,
      'legalProof': legalProof,
      'directContactName': directContactName,
      'directContactPhone': directContactPhone,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'logoUrl': logoUrl,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'settings': settings,
    };
  }

  OrganizationModel copyWith({
    String? name,
    String? description,
    OrganizationCategory? category,
    String? email,
    String? phone,
    String? address,
    Map<String, dynamic>? location,
    String? legalProof,
    String? directContactName,
    String? directContactPhone,
    List<String>? adminIds,
    List<String>? memberIds,
    String? logoUrl,
    bool? isVerified,
    bool? isActive,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) {
    return OrganizationModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      location: location ?? this.location,
      legalProof: legalProof ?? this.legalProof,
      directContactName: directContactName ?? this.directContactName,
      directContactPhone: directContactPhone ?? this.directContactPhone,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      logoUrl: logoUrl ?? this.logoUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }
}