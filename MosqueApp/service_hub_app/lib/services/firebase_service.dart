import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';
import '../models/announcement_model.dart';
import '../models/event_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'mosqueapp_users';
  static const String organizationsCollection = 'organizations';
  static const String announcementsCollection = 'announcements';
  static const String eventsCollection = 'events';
  static const String reportsCollection = 'reports';
  static const String organizationVerificationCollection =
      'mosqueapp_verify_organization';

  // Authentication
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user document
        await createUserDocument(
          userId: result.user!.uid,
          email: email,
          name: name,
          phone: phone,
          userType: userType,
          profileImageUrl:
              null, // No profile image for email/password registration
        );
      }

      return result;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Ensure Google account is fully disconnected so account chooser appears next time
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Sign in with Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      bool isNewUser = false;
      if (result.user != null) {
        // Check if user document exists, if not create one
        UserModel? existingUser = await getUserDocument(result.user!.uid);
        if (existingUser == null) {
          isNewUser = true;
          await createUserDocument(
            userId: result.user!.uid,
            email: result.user!.email ?? '',
            name: result.user!.displayName ?? 'Google User',
            phone: '', // Google doesn't provide phone number by default
            userType: UserType
                .regular, // Default to regular user, will be updated later
            profileImageUrl:
                result.user!.photoURL, // Get profile photo from Google
          );
        }
      }

      return {
        'userCredential': result,
        'isNewUser': isNewUser,
      };
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign in with Apple
  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential result = await _auth.signInWithCredential(oauthCredential);

      bool isNewUser = false;
      if (result.user != null) {
        // Check if user document exists, if not create one
        UserModel? existingUser = await getUserDocument(result.user!.uid);
        if (existingUser == null) {
          isNewUser = true;
          String name = '';
          if (appleCredential.givenName != null &&
              appleCredential.familyName != null) {
            name = '${appleCredential.givenName} ${appleCredential.familyName}';
          } else {
            name = result.user!.displayName ?? 'Apple User';
          }

          await createUserDocument(
            userId: result.user!.uid,
            email: result.user!.email ?? appleCredential.email ?? '',
            name: name,
            phone: '', // Apple doesn't provide phone number
            userType: UserType
                .regular, // Default to regular user, will be updated later
            profileImageUrl: result
                .user!.photoURL, // Get profile photo from Apple (if available)
          );
        }
      }

      return {
        'userCredential': result,
        'isNewUser': isNewUser,
      };
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    }
  }

  // Create user document
  static Future<void> createUserDocument({
    required String userId,
    required String email,
    required String name,
    required String phone,
    required UserType userType,
    String? profileImageUrl,
  }) async {
    final user = UserModel(
      id: userId,
      email: email,
      name: name,
      phone: phone,
      userType: userType,
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection(usersCollection).doc(userId).set({
      ...user.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user document
  static Future<UserModel?> getUserDocument(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(usersCollection).doc(userId).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  // Update user document
  static Future<void> updateUserDocument(
      String userId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _firestore.collection(usersCollection).doc(userId).update(data);
  }

  // Organization methods
  static Future<String?> createOrganization(
      OrganizationModel organization) async {
    try {
      DocumentReference doc = await _firestore
          .collection(organizationsCollection)
          .add(organization.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating organization: $e');
      return null;
    }
  }

  static Future<OrganizationModel?> getOrganization(
      String organizationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .get();

      if (doc.exists) {
        return OrganizationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting organization: $e');
      return null;
    }
  }

  static Stream<List<OrganizationModel>> getOrganizations({
    OrganizationCategory? category,
    String? searchQuery,
  }) {
    Query query = _firestore
        .collection(organizationsCollection)
        .where('isActive', isEqualTo: true);

    if (category != null) {
      query = query.where('category',
          isEqualTo: category.toString().split('.').last);
    }

    return query.snapshots().map((snapshot) {
      List<OrganizationModel> organizations = snapshot.docs
          .map((doc) => OrganizationModel.fromFirestore(doc))
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        organizations = organizations
            .where((org) =>
                org.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                org.description
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();
      }

      return organizations;
    });
  }

  // Announcement methods
  static Future<String?> createAnnouncement(
      AnnouncementModel announcement) async {
    try {
      DocumentReference doc = await _firestore
          .collection(announcementsCollection)
          .add(announcement.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating announcement: $e');
      return null;
    }
  }

  static Stream<List<AnnouncementModel>> getAnnouncements({
    String? organizationId,
    AnnouncementCategory? category,
  }) {
    Query query = _firestore
        .collection(announcementsCollection)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true);

    if (organizationId != null) {
      query = query.where('organizationId', isEqualTo: organizationId);
    }

    if (category != null) {
      query = query.where('category',
          isEqualTo: category.toString().split('.').last);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => AnnouncementModel.fromFirestore(doc))
        .toList());
  }

  // Event methods
  static Future<String?> createEvent(EventModel event) async {
    try {
      DocumentReference doc = await _firestore
          .collection(eventsCollection)
          .add(event.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  static Stream<List<EventModel>> getEvents({
    String? organizationId,
    EventCategory? category,
    bool upcomingOnly = false,
  }) {
    Query query = _firestore
        .collection(eventsCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('startDateTime', descending: false);

    if (organizationId != null) {
      query = query.where('organizationId', isEqualTo: organizationId);
    }

    if (category != null) {
      query = query.where('category',
          isEqualTo: category.toString().split('.').last);
    }

    if (upcomingOnly) {
      query = query.where('startDateTime', isGreaterThan: Timestamp.now());
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // Report content
  static Future<void> reportContent({
    required String contentId,
    required String contentType, // 'announcement', 'event', 'organization'
    required String reportedBy,
    required String reason,
  }) async {
    await _firestore.collection(reportsCollection).add({
      'contentId': contentId,
      'contentType': contentType,
      'reportedBy': reportedBy,
      'reason': reason,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'status': 'pending',
    });
  }

  // File upload
  static Future<String?> uploadFile(String path, Uint8List bytes) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putData(bytes);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Additional Event methods
  static Future<List<EventModel>> getUserEvents(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(eventsCollection)
          .where('createdBy', isEqualTo: userId)
          .orderBy('startDateTime', descending: false)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user events: $e');
      return [];
    }
  }

  static Future<List<EventModel>> getUserAttendingEvents(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(eventsCollection)
          .where('attendees', arrayContains: {'userId': userId})
          .orderBy('startDateTime', descending: false)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user attending events: $e');
      return [];
    }
  }

  static Future<void> updateEvent(
      String eventId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection(eventsCollection)
          .doc(eventId)
          .update(updates);
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(eventsCollection).doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      throw e;
    }
  }

  static Future<void> addEventAttendee(String eventId, String userId) async {
    try {
      DocumentReference eventRef =
          _firestore.collection(eventsCollection).doc(eventId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) {
          throw Exception('Event not found');
        }

        List<dynamic> attendees =
            (eventDoc.data() as Map<String, dynamic>?)!['attendees'] ?? [];

        // Check if user is already attending
        bool alreadyAttending =
            attendees.any((attendee) => attendee['userId'] == userId);

        if (!alreadyAttending) {
          attendees.add({
            'userId': userId,
            'userName': '', // This should be filled with actual user name
            'registeredAt': Timestamp.now(),
            'emailReminder': false,
            'smsReminder': false,
            'notifyMosque': false,
          });

          transaction.update(eventRef, {'attendees': attendees});
        }
      });
    } catch (e) {
      print('Error adding event attendee: $e');
      throw e;
    }
  }

  static Future<void> unregisterFromEvent(String eventId, String userId) async {
    try {
      DocumentReference eventRef =
          _firestore.collection(eventsCollection).doc(eventId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) {
          throw Exception('Event not found');
        }

        List<dynamic> attendees =
            (eventDoc.data() as Map<String, dynamic>?)!['attendees'] ?? [];

        // Remove user from attendees
        attendees.removeWhere((attendee) => attendee['userId'] == userId);

        transaction.update(eventRef, {'attendees': attendees});
      });
    } catch (e) {
      print('Error unregistering from event: $e');
      throw e;
    }
  }

  static Future<void> confirmEventAttendance(
      String eventId, String userId) async {
    try {
      // This is a placeholder - implement based on your attendance confirmation logic
      await _firestore.collection(eventsCollection).doc(eventId).update({
        'confirmedAttendees': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error confirming event attendance: $e');
      throw e;
    }
  }

  // Additional Organization methods
  static Future<List<OrganizationModel>> getUserOrganizations(
      String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(organizationsCollection)
          .where('adminIds', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => OrganizationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user organizations: $e');
      return [];
    }
  }

  static Future<List<OrganizationModel>> getOrganizationsByCategory(
      String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(organizationsCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => OrganizationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting organizations by category: $e');
      return [];
    }
  }

  static Future<void> updateOrganization(
      String organizationId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .update(updates);
    } catch (e) {
      print('Error updating organization: $e');
      throw e;
    }
  }

  static Future<void> addOrganizationMember(
      String organizationId, String userId) async {
    try {
      await _firestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error adding organization member: $e');
      throw e;
    }
  }

  static Future<void> removeOrganizationMember(
      String organizationId, String userId) async {
    try {
      await _firestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error removing organization member: $e');
      throw e;
    }
  }

  // Organization Verification Methods
  static Future<void> submitOrganizationVerification({
    required String userId,
    required String organizationName,
    required String organizationDescription,
    required String contactEmail,
    String? website,
    required Map<String, dynamic> userDetails,
    String? contactPhone,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _firestore
          .collection(organizationVerificationCollection)
          .doc(userId)
          .set({
        'userId': userId,
        'organizationName': organizationName,
        'organizationDescription': organizationDescription,
        'contactEmail': contactEmail,
        'website': website ?? '',
        'verifyStatus': 'pending',
        'userDetails': userDetails,
        'submittedAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        // New fields for phone/address and coordinates
        'contactPhone': contactPhone ?? '',
        'address': fullAddress ?? '',
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Error submitting organization verification: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>?> getOrganizationVerificationStatus(
      String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(organizationVerificationCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting organization verification status: $e');
      throw e;
    }
  }

  static Future<void> updateOrganizationVerificationStatus({
    required String userId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection(organizationVerificationCollection)
          .doc(userId)
          .update({
        'verifyStatus': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // If accepted, update user type in users collection
      if (status == 'accepted') {
        await _firestore.collection(usersCollection).doc(userId).update({
          'userType': 'Organization',
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      print('Error updating organization verification status: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>>
      getAllOrganizationVerifications() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(organizationVerificationCollection)
          .orderBy('submittedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting all organization verifications: $e');
      throw e;
    }
  }

  static Future<void> deleteOrganizationVerification(String userId) async {
    try {
      await _firestore
          .collection(organizationVerificationCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      print('Error deleting organization verification: $e');
      throw e;
    }
  }
}
