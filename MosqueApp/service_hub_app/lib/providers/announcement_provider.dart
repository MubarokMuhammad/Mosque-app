import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';
import '../services/local_notification_service.dart';

class AnnouncementProvider with ChangeNotifier {
  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> _myAnnouncements = [];
  AnnouncementModel? _selectedAnnouncement;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'all';

  // Getters
  List<AnnouncementModel> get announcements => _getFilteredAnnouncements();
  List<AnnouncementModel> get myAnnouncements => _myAnnouncements;
  AnnouncementModel? get selectedAnnouncement => _selectedAnnouncement;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // Load all announcements
  Future<void> loadAnnouncements({
    String? organizationId,
    AnnouncementCategory? category,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      FirebaseService.getAnnouncements(
        organizationId: organizationId,
        category: category,
      ).listen((announcements) {
        _announcements = announcements;
        // Sort by boosted first, then by creation date
        _announcements.sort((a, b) {
          if (a.isCurrentlyBoosted && !b.isCurrentlyBoosted) return -1;
          if (!a.isCurrentlyBoosted && b.isCurrentlyBoosted) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load announcements by organization
  Future<void> loadAnnouncementsByOrganization(String organizationId) async {
    try {
      _setLoading(true);
      _clearError();

      FirebaseService.getAnnouncements(organizationId: organizationId).listen((announcements) {
        _announcements = announcements;
        _announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load user's announcements
  Future<void> loadMyAnnouncements(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement getUserAnnouncements in FirebaseService
      // For now, filter from all announcements
      FirebaseService.getAnnouncements().listen((announcements) {
        _myAnnouncements = announcements.where((a) => a.createdBy == userId).toList();
        _myAnnouncements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Create announcement
  Future<bool> createAnnouncement({
    required String title,
    required String description,
    required AnnouncementCategory category,
    required String organizationId,
    required String organizationName,
    required String createdBy,
    DateTime? expiresAt,
    List<String>? imageUrls,
    bool emailNotification = false,
    bool smsNotification = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      AnnouncementModel announcement = AnnouncementModel(
        id: '',
        title: title,
        description: description,
        category: category,
        organizationId: organizationId,
        organizationName: organizationName,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: expiresAt,
        status: AnnouncementStatus.active,
        imageUrls: imageUrls ?? [],
        isBoosted: false,
        boostedUntil: null,
        boostPrice: 0.0,
        emailNotification: emailNotification,
        smsNotification: smsNotification,
        viewCount: 0,
        reportedBy: [],
        metadata: {},
      );

      String? announcementId = await FirebaseService.createAnnouncement(announcement);
      
      if (announcementId != null) {
        // Create a new announcement with the generated ID
        final updatedAnnouncement = AnnouncementModel(
          id: announcementId,
          title: announcement.title,
          description: announcement.description,
          category: announcement.category,
          organizationId: announcement.organizationId,
          organizationName: announcement.organizationName,
          createdBy: announcement.createdBy,
          createdAt: announcement.createdAt,
          updatedAt: announcement.updatedAt,
          expiresAt: announcement.expiresAt,
          status: announcement.status,
          imageUrls: announcement.imageUrls,
          isBoosted: announcement.isBoosted,
          boostedUntil: announcement.boostedUntil,
          boostPrice: announcement.boostPrice,
          emailNotification: announcement.emailNotification,
          smsNotification: announcement.smsNotification,
          viewCount: announcement.viewCount,
          reportedBy: announcement.reportedBy,
          metadata: announcement.metadata,
        );
        
        _announcements.insert(0, updatedAnnouncement);
        _myAnnouncements.insert(0, updatedAnnouncement);
        
        // Send local notification for new announcement
        await LocalNotificationService().sendAnnouncementNotification(updatedAnnouncement);
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create announcement');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update announcement
  Future<bool> updateAnnouncement(String announcementId, Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement updateAnnouncement in FirebaseService
      // await FirebaseService.updateAnnouncement(announcementId, updates);
      
      // Update local data
      _updateLocalAnnouncement(announcementId, updates);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete announcement
  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement deleteAnnouncement in FirebaseService
      // await FirebaseService.deleteAnnouncement(announcementId);
      
      // Remove from local data
      _announcements.removeWhere((ann) => ann.id == announcementId);
      _myAnnouncements.removeWhere((ann) => ann.id == announcementId);
      
      if (_selectedAnnouncement?.id == announcementId) {
        _selectedAnnouncement = null;
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

  // Boost announcement
  Future<bool> boostAnnouncement({
    required String announcementId,
    required int durationDays,
    required double price,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      DateTime boostedUntil = DateTime.now().add(Duration(days: durationDays));
      
      Map<String, dynamic> updates = {
        'isBoosted': true,
        'boostedUntil': boostedUntil.toIso8601String(),
        'boostPrice': price,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // TODO: Implement updateAnnouncement in FirebaseService
      // await FirebaseService.updateAnnouncement(announcementId, updates);
      
      // Update local data
      _updateLocalAnnouncement(announcementId, updates);
      
      // Re-sort announcements to put boosted ones first
      _announcements.sort((a, b) {
        if (a.isCurrentlyBoosted && !b.isCurrentlyBoosted) return -1;
        if (!a.isCurrentlyBoosted && b.isCurrentlyBoosted) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Report announcement
  Future<bool> reportAnnouncement(String announcementId, String userId, String reason) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement reportContent in FirebaseService
      // await FirebaseService.reportContent(
      //   contentId: announcementId,
      //   contentType: 'announcement',
      //   reportedBy: userId,
      //   reason: reason,
      // );

      // Update local data to add user to reported list
      int index = _announcements.indexWhere((ann) => ann.id == announcementId);
      if (index != -1) {
        List<String> reportedBy = List.from(_announcements[index].reportedBy);
        if (!reportedBy.contains(userId)) {
          reportedBy.add(userId);
          _announcements[index] = _announcements[index].copyWith(reportedBy: reportedBy);
        }
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

  // Increment view count
  Future<void> incrementViewCount(String announcementId) async {
    try {
      // TODO: Implement incrementAnnouncementViews in FirebaseService
      // await FirebaseService.incrementAnnouncementViews(announcementId);
      
      // Update local data
      int index = _announcements.indexWhere((ann) => ann.id == announcementId);
      if (index != -1) {
        _announcements[index] = _announcements[index].copyWith(
          viewCount: _announcements[index].viewCount + 1,
        );
      }

      int myIndex = _myAnnouncements.indexWhere((ann) => ann.id == announcementId);
      if (myIndex != -1) {
        _myAnnouncements[myIndex] = _myAnnouncements[myIndex].copyWith(
          viewCount: _myAnnouncements[myIndex].viewCount + 1,
        );
      }

      if (_selectedAnnouncement?.id == announcementId) {
        _selectedAnnouncement = _selectedAnnouncement!.copyWith(
          viewCount: _selectedAnnouncement!.viewCount + 1,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Search announcements
  List<AnnouncementModel> searchAnnouncements(String query) {
    List<AnnouncementModel> filtered = _getFilteredAnnouncements();
    
    if (query.isEmpty) return filtered;
    
    return filtered.where((ann) =>
      ann.title.toLowerCase().contains(query.toLowerCase()) ||
      ann.description.toLowerCase().contains(query.toLowerCase()) ||
      ann.organizationName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Get filtered announcements based on category
  List<AnnouncementModel> _getFilteredAnnouncements() {
    if (_selectedCategory == 'all') {
      return _announcements.where((ann) => 
        ann.status == AnnouncementStatus.active && !ann.isExpired
      ).toList();
    }
    
    return _announcements.where((ann) => 
      ann.status == AnnouncementStatus.active && 
      !ann.isExpired &&
      ann.category.toString().split('.').last == _selectedCategory
    ).toList();
  }

  // Get announcement by ID
  AnnouncementModel? getAnnouncementById(String id) {
    try {
      return _announcements.firstWhere((ann) => ann.id == id);
    } catch (e) {
      return null;
    }
  }

  // Set selected announcement
  void setSelectedAnnouncement(AnnouncementModel? announcement) {
    _selectedAnnouncement = announcement;
    notifyListeners();
  }

  // Get boost pricing based on demand
  double getBoostPrice(int durationDays) {
    // Dynamic pricing based on current boosted announcements count
    int boostedCount = _announcements.where((ann) => ann.isCurrentlyBoosted).length;
    double basePrice = 5.0; // Base price per day
    double demandMultiplier = 1.0 + (boostedCount * 0.1); // 10% increase per boosted announcement
    
    return basePrice * durationDays * demandMultiplier;
  }

  // Helper methods
  void _updateLocalAnnouncement(String announcementId, Map<String, dynamic> updates) {
    // Update in announcements list
    int index = _announcements.indexWhere((ann) => ann.id == announcementId);
    if (index != -1) {
      _announcements[index] = _updateAnnouncementWithMap(_announcements[index], updates);
    }

    // Update in my announcements list
    int myIndex = _myAnnouncements.indexWhere((ann) => ann.id == announcementId);
    if (myIndex != -1) {
      _myAnnouncements[myIndex] = _updateAnnouncementWithMap(_myAnnouncements[myIndex], updates);
    }

    // Update selected announcement
    if (_selectedAnnouncement?.id == announcementId) {
      _selectedAnnouncement = _updateAnnouncementWithMap(_selectedAnnouncement!, updates);
    }
  }

  AnnouncementModel _updateAnnouncementWithMap(AnnouncementModel announcement, Map<String, dynamic> updates) {
    return announcement.copyWith(
      title: updates['title'],
      description: updates['description'],
      category: updates['category'] != null ? 
        AnnouncementCategory.values.firstWhere((c) => c.toString() == updates['category']) : null,
      expiresAt: updates['expiresAt'] != null ? DateTime.parse(updates['expiresAt']) : null,
      status: updates['status'] != null ?
        AnnouncementStatus.values.firstWhere((s) => s.toString() == updates['status']) : null,
      isBoosted: updates['isBoosted'],
      boostedUntil: updates['boostedUntil'] != null ? DateTime.parse(updates['boostedUntil']) : null,
      boostPrice: updates['boostPrice']?.toDouble(),
      emailNotification: updates['emailNotification'],
      smsNotification: updates['smsNotification'],
      updatedAt: DateTime.now(),
    );
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