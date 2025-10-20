import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MosqueSubscriptionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String subscriptionsCollection = 'mosqueapp_subscribe_mosques';

  /// Subscribe to a mosque
  static Future<bool> subscribeToMosque({
    required String mosqueName,
    required String mosqueAddress,
    String? mosqueDescription,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final subscriptionData = {
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'Unknown User',
        'mosqueName': mosqueName,
        'mosqueAddress': mosqueAddress,
        'mosqueDescription': mosqueDescription,
        'subscribedAt': Timestamp.fromDate(DateTime.now()),
        'isActive': true,
      };

      // Create a unique document ID based on user and mosque
      final docId = '${user.uid}_${mosqueName.replaceAll(' ', '_').toLowerCase()}';
      
      await _firestore
          .collection(subscriptionsCollection)
          .doc(docId)
          .set(subscriptionData);

      return true;
    } catch (e) {
      print('Error subscribing to mosque: $e');
      return false;
    }
  }

  /// Unsubscribe from a mosque
  static Future<bool> unsubscribeFromMosque({
    required String mosqueName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create the same document ID used when subscribing
      final docId = '${user.uid}_${mosqueName.replaceAll(' ', '_').toLowerCase()}';
      
      await _firestore
          .collection(subscriptionsCollection)
          .doc(docId)
          .delete();

      return true;
    } catch (e) {
      print('Error unsubscribing from mosque: $e');
      return false;
    }
  }

  /// Check if user is subscribed to a mosque
  static Future<bool> isSubscribedToMosque({
    required String mosqueName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Create the same document ID used when subscribing
      final docId = '${user.uid}_${mosqueName.replaceAll(' ', '_').toLowerCase()}';
      
      final doc = await _firestore
          .collection(subscriptionsCollection)
          .doc(docId)
          .get();

      return doc.exists && (doc.data()?['isActive'] ?? false);
    } catch (e) {
      print('Error checking mosque subscription: $e');
      return false;
    }
  }

  /// Get all subscribed mosques for current user
  static Future<List<Map<String, dynamic>>> getUserSubscribedMosques() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection(subscriptionsCollection)
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .orderBy('subscribedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting user subscribed mosques: $e');
      return [];
    }
  }

  /// Get all subscribers for a specific mosque (for organization use)
  static Future<List<Map<String, dynamic>>> getMosqueSubscribers({
    required String mosqueName,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(subscriptionsCollection)
          .where('mosqueName', isEqualTo: mosqueName)
          .where('isActive', isEqualTo: true)
          .orderBy('subscribedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting mosque subscribers: $e');
      return [];
    }
  }

  /// Get subscription count for a mosque
  static Future<int> getMosqueSubscriptionCount({
    required String mosqueName,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(subscriptionsCollection)
          .where('mosqueName', isEqualTo: mosqueName)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting mosque subscription count: $e');
      return 0;
    }
  }
}