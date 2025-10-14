import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { regular, organization }

class UserModel {
  final String id;
  final String email;
  final String phone;
  final String name;
  final UserType userType;
  final bool emailNotifications;
  final bool smsNotifications;
  final String? organizationId;
  final List<String> organizationMemberships;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? location;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.userType,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.organizationId,
    this.organizationMemberships = const [],
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.location,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      name: data['name'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${data['userType']}',
        orElse: () => UserType.regular,
      ),
      emailNotifications: data['emailNotifications'] ?? true,
      smsNotifications: data['smsNotifications'] ?? true,
      organizationId: data['organizationId'],
      organizationMemberships: List<String>.from(data['organizationMemberships'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
      location: data['location'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone': phone,
      'name': name,
      'userType': userType.toString().split('.').last,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'organizationId': organizationId,
      'organizationMemberships': organizationMemberships,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImageUrl': profileImageUrl,
      'location': location,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? email,
    String? phone,
    String? name,
    UserType? userType,
    bool? emailNotifications,
    bool? smsNotifications,
    String? organizationId,
    List<String>? organizationMemberships,
    DateTime? updatedAt,
    String? profileImageUrl,
    Map<String, dynamic>? location,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      organizationId: organizationId ?? this.organizationId,
      organizationMemberships: organizationMemberships ?? this.organizationMemberships,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
    );
  }
}