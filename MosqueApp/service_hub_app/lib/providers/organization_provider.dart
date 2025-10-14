import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/organization_model.dart';
import '../services/firebase_service.dart';

class OrganizationProvider with ChangeNotifier {
  List<OrganizationModel> _organizations = [];
  List<OrganizationModel> _myOrganizations = [];
  OrganizationModel? _selectedOrganization;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<OrganizationModel> get organizations => _organizations;
  List<OrganizationModel> get myOrganizations => _myOrganizations;
  OrganizationModel? get selectedOrganization => _selectedOrganization;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all organizations
  Future<void> loadOrganizations() async {
    try {
      _setLoading(true);
      _clearError();

      FirebaseService.getOrganizations().listen((organizations) {
        _organizations = organizations;
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load organizations by category
  Future<void> loadOrganizationsByCategory(String category) async {
    try {
      _setLoading(true);
      _clearError();

      _organizations = await FirebaseService.getOrganizationsByCategory(category);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load user's organizations
  Future<void> loadMyOrganizations(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _myOrganizations = await FirebaseService.getUserOrganizations(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create organization
  Future<bool> createOrganization({
    required String name,
    required String description,
    required String category,
    required String email,
    required String phone,
    required String address,
    required String legalProof,
    required String adminId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      OrganizationModel organization = OrganizationModel(
        id: '',
        name: name,
        description: description,
        category: OrganizationCategory.values.firstWhere(
          (e) => e.toString().split('.').last == category.toLowerCase(),
          orElse: () => OrganizationCategory.other,
        ),
        email: email,
        phone: phone,
        address: address,
        location: {
          'lat': latitude ?? 0.0,
          'lng': longitude ?? 0.0,
        },
        legalProof: legalProof,
        directContactName: '',
        directContactPhone: '',
        adminIds: [adminId],
        memberIds: [],
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String? organizationId = await FirebaseService.createOrganization(organization);
      
      if (organizationId != null) {
        organization = organization.copyWith(
          name: organizationId, // This should be handled differently - the ID is set in FirebaseService
        );
        _myOrganizations.add(organization);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create organization');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update organization
  Future<bool> updateOrganization(String organizationId, Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.updateOrganization(organizationId, updates);
      
      // Update local data
      int index = _organizations.indexWhere((org) => org.id == organizationId);
      if (index != -1) {
        _organizations[index] = _organizations[index].copyWith(
          name: updates['name'],
          description: updates['description'],
          category: updates['category'],
          email: updates['email'],
          phone: updates['phone'],
          address: updates['address'],
          updatedAt: DateTime.now(),
        );
      }

      int myIndex = _myOrganizations.indexWhere((org) => org.id == organizationId);
      if (myIndex != -1) {
        _myOrganizations[myIndex] = _myOrganizations[myIndex].copyWith(
          name: updates['name'],
          description: updates['description'],
          category: updates['category'],
          email: updates['email'],
          phone: updates['phone'],
          address: updates['address'],
          updatedAt: DateTime.now(),
        );
      }

      if (_selectedOrganization?.id == organizationId) {
        _selectedOrganization = _selectedOrganization!.copyWith(
          name: updates['name'],
          description: updates['description'],
          category: updates['category'],
          email: updates['email'],
          phone: updates['phone'],
          address: updates['address'],
          updatedAt: DateTime.now(),
        );
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

  // Add member to organization
  Future<bool> addMember(String organizationId, String userId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.addOrganizationMember(organizationId, userId);
      
      // Update local data
      _updateOrganizationMembers(organizationId, userId, true);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove member from organization
  Future<bool> removeMember(String organizationId, String userId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.removeOrganizationMember(organizationId, userId);
      
      // Update local data
      _updateOrganizationMembers(organizationId, userId, false);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Report organization
  Future<bool> reportOrganization(String organizationId, String userId, String reason) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.reportContent(
        contentId: organizationId,
        contentType: 'organization',
        reportedBy: userId,
        reason: reason,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search organizations
  List<OrganizationModel> searchOrganizations(String query) {
    if (query.isEmpty) return _organizations;
    
    return _organizations.where((org) =>
      org.name.toLowerCase().contains(query.toLowerCase()) ||
      org.description.toLowerCase().contains(query.toLowerCase()) ||
      org.category.toString().split('.').last.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Filter organizations by distance (requires user location)
  List<OrganizationModel> getOrganizationsByDistance({
    required double userLatitude,
    required double userLongitude,
    double maxDistanceKm = 50.0,
  }) {
    return _organizations.where((org) {
      if (org.location['lat'] == null || org.location['lng'] == null) return false;
      
      double distance = _calculateDistance(
        userLatitude,
        userLongitude,
        org.location['lat'].toDouble(),
        org.location['lng'].toDouble(),
      );
      
      return distance <= maxDistanceKm;
    }).toList()
      ..sort((a, b) {
        double distanceA = _calculateDistance(
          userLatitude,
          userLongitude,
          a.location['lat'].toDouble(),
          a.location['lng'].toDouble(),
        );
        double distanceB = _calculateDistance(
          userLatitude,
          userLongitude,
          b.location['lat'].toDouble(),
          b.location['lng'].toDouble(),
        );
        return distanceA.compareTo(distanceB);
      });
  }

  // Get organization by ID
  OrganizationModel? getOrganizationById(String id) {
    try {
      return _organizations.firstWhere((org) => org.id == id);
    } catch (e) {
      return null;
    }
  }

  // Set selected organization
  void setSelectedOrganization(OrganizationModel? organization) {
    _selectedOrganization = organization;
    notifyListeners();
  }

  // Helper methods
  void _updateOrganizationMembers(String organizationId, String userId, bool add) {
    // Update in organizations list
    int index = _organizations.indexWhere((org) => org.id == organizationId);
    if (index != -1) {
      List<String> members = List.from(_organizations[index].memberIds);
      if (add && !members.contains(userId)) {
        members.add(userId);
      } else if (!add) {
        members.remove(userId);
      }
      _organizations[index] = _organizations[index].copyWith(memberIds: members);
    }

    // Update in my organizations list
    int myIndex = _myOrganizations.indexWhere((org) => org.id == organizationId);
    if (myIndex != -1) {
      List<String> members = List.from(_myOrganizations[myIndex].memberIds);
      if (add && !members.contains(userId)) {
        members.add(userId);
      } else if (!add) {
        members.remove(userId);
      }
      _myOrganizations[myIndex] = _myOrganizations[myIndex].copyWith(memberIds: members);
    }

    // Update selected organization
    if (_selectedOrganization?.id == organizationId) {
      List<String> members = List.from(_selectedOrganization!.memberIds);
      if (add && !members.contains(userId)) {
        members.add(userId);
      } else if (!add) {
        members.remove(userId);
      }
      _selectedOrganization = _selectedOrganization!.copyWith(memberIds: members);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
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