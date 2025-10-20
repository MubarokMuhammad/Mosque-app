import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isNewSocialUser = false;
  bool _isInitialized = false;
  bool _userDocListening = false;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  UserModel? get currentUser =>
      _userModel; // Add currentUser getter for compatibility
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null && _isInitialized;
  bool get isOrganization => _userModel?.userType == UserType.organization;
  bool get isNewSocialUser => _isNewSocialUser;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    // Wait for Firebase Auth to initialize and check for existing user
    _firebaseUser = FirebaseService.currentUser;

    if (_firebaseUser != null) {
      await _loadUserModel(_firebaseUser!.uid);
      _subscribeUserDoc(_firebaseUser!.uid);
    }

    _isInitialized = true;
    notifyListeners();

    // Listen to auth state changes after initialization
    FirebaseService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserModel(user.uid);
        _subscribeUserDoc(user.uid);
        _userDocListening = true;
      } else {
        _userDocSubscription?.cancel();
        _userDocListening = false;
        _userModel = null;
      }
      notifyListeners();
    });
  }

  // Load user model from Firestore
  Future<void> _loadUserModel(String userId) async {
    try {
      _userModel = await FirebaseService.getUserDocument(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading user model: $e');
    }
  }

  // Subscribe to user document snapshot for realtime updates
  void _subscribeUserDoc(String userId) {
    _userDocSubscription?.cancel();
    _userDocSubscription = FirebaseFirestore.instance
        .collection(FirebaseService.usersCollection)
        .doc(userId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        try {
          _userModel = UserModel.fromFirestore(doc);
          print('DEBUG: User doc snapshot userType: ${_userModel?.userType}');
          notifyListeners();
        } catch (e) {
          print('Error parsing user doc snapshot: $e');
        }
      }
    }, onError: (e) {
      print('Error listening to user doc snapshots: $e');
    });
  }

  // Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      await _loadUserModel(_firebaseUser!.uid);
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      UserCredential? result = await FirebaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: userType,
      );

      if (result != null) {
        return true;
      } else {
        _setError('Failed to create account');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      UserCredential? result = await FirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result != null) {
        return true;
      } else {
        _setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      _setError('Invalid email or password');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await FirebaseService.signOut();
      _userModel = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      var result = await FirebaseService.signInWithGoogle();

      if (result != null && result['userCredential'] != null) {
        _isNewSocialUser = result['isNewUser'] ?? false;
        return true;
      } else {
        _setError('Google sign-in was cancelled or failed');
        return false;
      }
    } catch (e) {
      _setError('Google sign-in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      var result = await FirebaseService.signInWithApple();

      if (result != null && result['userCredential'] != null) {
        _isNewSocialUser = result['isNewUser'] ?? false;
        return true;
      } else {
        _setError('Apple sign-in was cancelled or failed');
        return false;
      }
    } catch (e) {
      _setError('Apple sign-in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_firebaseUser == null || _userModel == null) return false;

    try {
      _setLoading(true);
      _clearError();

      if (updates.isNotEmpty) {
        await FirebaseService.updateUserDocument(_firebaseUser!.uid, updates);

        // Update local user model
        _userModel = _userModel!.copyWith(
          name: updates['name'],
          phone: updates['phone'],
          emailNotifications: updates['emailNotifications'],
          smsNotifications: updates['smsNotifications'],
          updatedAt: DateTime.now(),
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _setError('Failed to send reset email');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Join organization
  Future<bool> joinOrganization(String organizationId) async {
    if (_firebaseUser == null || _userModel == null) return false;

    try {
      _setLoading(true);
      _clearError();

      List<String> memberships = List.from(_userModel!.organizationMemberships);
      if (!memberships.contains(organizationId)) {
        memberships.add(organizationId);

        await FirebaseService.updateUserDocument(_firebaseUser!.uid, {
          'organizationMemberships': memberships,
        });

        _userModel = _userModel!.copyWith(
          organizationMemberships: memberships,
          updatedAt: DateTime.now(),
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Leave organization
  Future<bool> leaveOrganization(String organizationId) async {
    if (_firebaseUser == null || _userModel == null) return false;

    try {
      _setLoading(true);
      _clearError();

      List<String> memberships = List.from(_userModel!.organizationMemberships);
      memberships.remove(organizationId);

      await FirebaseService.updateUserDocument(_firebaseUser!.uid, {
        'organizationMemberships': memberships,
      });

      _userModel = _userModel!.copyWith(
        organizationMemberships: memberships,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
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

  // Set user type for new social users
  Future<bool> setUserType(UserType userType) async {
    if (_firebaseUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.updateUserDocument(_firebaseUser!.uid, {
        'userType': userType.toString().split('.').last,
      });

      // Reload user model
      await _loadUserModel(_firebaseUser!.uid);
      _isNewSocialUser = false;

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear new social user flag
  void clearNewSocialUserFlag() {
    _isNewSocialUser = false;
    notifyListeners();
  }

  // Set organization status based on verification
  Future<void> setIsOrganization(bool isOrganization) async {
    if (_userModel != null && _firebaseUser != null) {
      try {
        UserType newUserType =
            isOrganization ? UserType.organization : UserType.regular;

        // Update in Firestore
        await FirebaseService.updateUserDocument(_firebaseUser!.uid, {
          'userType': newUserType.toString().split('.').last,
        });

        // Update local model
        _userModel = UserModel(
          id: _userModel!.id,
          name: _userModel!.name,
          email: _userModel!.email,
          phone: _userModel!.phone,
          userType: newUserType,
          profileImageUrl: _userModel!.profileImageUrl,
          createdAt: _userModel!.createdAt,
          updatedAt: DateTime.now(),
        );

        notifyListeners();
      } catch (e) {
        print('Error updating organization status: $e');
      }
    }
  }

  void ensureUserDocListening() {
    if (!_userDocListening && _firebaseUser != null) {
      _userDocListening = true;
      _subscribeUserDoc(_firebaseUser!.uid);
    }
  }
}