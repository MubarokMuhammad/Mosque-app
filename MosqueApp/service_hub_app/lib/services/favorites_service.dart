import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'favorite_mosques';

  // Get all favorite mosques
  static Future<List<Map<String, dynamic>>> getFavoriteMosques() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson == null) {
        return [];
      }
      
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting favorite mosques: $e');
      return [];
    }
  }

  // Add mosque to favorites
  static Future<bool> addToFavorites({
    required String mosqueName,
    required String mosqueAddress,
    String? mosqueDescription,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteMosques();
      
      // Check if mosque is already in favorites
      final isAlreadyFavorite = favorites.any((mosque) => 
          mosque['name'] == mosqueName && mosque['address'] == mosqueAddress);
      
      if (isAlreadyFavorite) {
        return false; // Already in favorites
      }
      
      // Add new favorite
      final newFavorite = {
        'name': mosqueName,
        'address': mosqueAddress,
        'description': mosqueDescription ?? '',
        'dateAdded': DateTime.now().toIso8601String(),
      };
      
      favorites.add(newFavorite);
      
      // Save to SharedPreferences
      final favoritesJson = json.encode(favorites);
      await prefs.setString(_favoritesKey, favoritesJson);
      
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove mosque from favorites
  static Future<bool> removeFromFavorites({
    required String mosqueName,
    required String mosqueAddress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteMosques();
      
      // Remove the mosque from favorites
      favorites.removeWhere((mosque) => 
          mosque['name'] == mosqueName && mosque['address'] == mosqueAddress);
      
      // Save updated list to SharedPreferences
      final favoritesJson = json.encode(favorites);
      await prefs.setString(_favoritesKey, favoritesJson);
      
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Check if mosque is in favorites
  static Future<bool> isFavorite({
    required String mosqueName,
    required String mosqueAddress,
  }) async {
    try {
      final favorites = await getFavoriteMosques();
      return favorites.any((mosque) => 
          mosque['name'] == mosqueName && mosque['address'] == mosqueAddress);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Clear all favorites
  static Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  // Get favorites count
  static Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavoriteMosques();
      return favorites.length;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }
}