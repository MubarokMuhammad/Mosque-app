import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement.dart';

class BookmarksService {
  static const String _bookmarksKey = 'bookmarked_events';

  // Get all bookmarked events
  static Future<List<Map<String, dynamic>>> getBookmarkedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
    
    return bookmarksJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
  }

  // Add event to bookmarks
  static Future<void> addBookmark(Announcement event) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarkedEvents();
    
    // Check if already bookmarked
    final isAlreadyBookmarked = bookmarks.any((bookmark) => bookmark['id'] == event.id);
    if (isAlreadyBookmarked) return;
    
    // Create bookmark data
    final bookmarkData = {
      'id': event.id,
      'title': event.title,
      'date': event.date,
      'fullContent': event.fullContent,
      'eventTime': event.eventTime,
      'location': event.location,
      'organizer': event.organizer,
      'tags': event.tags,
      'colorValue': event.color.value,
      'iconCodePoint': event.icon.codePoint,
      'dateAdded': DateTime.now().toIso8601String(),
    };
    
    bookmarks.add(bookmarkData);
    
    // Save to SharedPreferences
    final bookmarksJson = bookmarks.map((bookmark) => jsonEncode(bookmark)).toList();
    await prefs.setStringList(_bookmarksKey, bookmarksJson);
  }

  // Remove event from bookmarks
  static Future<void> removeBookmark(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarkedEvents();
    
    bookmarks.removeWhere((bookmark) => bookmark['id'] == eventId);
    
    // Save updated list
    final bookmarksJson = bookmarks.map((bookmark) => jsonEncode(bookmark)).toList();
    await prefs.setStringList(_bookmarksKey, bookmarksJson);
  }

  // Check if event is bookmarked
  static Future<bool> isBookmarked(String eventId) async {
    final bookmarks = await getBookmarkedEvents();
    return bookmarks.any((bookmark) => bookmark['id'] == eventId);
  }

  // Clear all bookmarks
  static Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarksKey);
  }

  // Get bookmarks count
  static Future<int> getBookmarksCount() async {
    final bookmarks = await getBookmarkedEvents();
    return bookmarks.length;
  }
}