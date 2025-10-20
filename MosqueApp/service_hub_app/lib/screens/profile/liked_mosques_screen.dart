import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/favorites_service.dart';
import '../mosques/mosque_detail_screen.dart';

class LikedMosquesScreen extends StatefulWidget {
  const LikedMosquesScreen({Key? key}) : super(key: key);

  @override
  State<LikedMosquesScreen> createState() => _LikedMosquesScreenState();
}

class _LikedMosquesScreenState extends State<LikedMosquesScreen> {
  List<Map<String, dynamic>> favoriteMosques = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteMosques();
  }

  Future<void> _loadFavoriteMosques() async {
    setState(() {
      isLoading = true;
    });

    final favorites = await FavoritesService.getFavoriteMosques();
    setState(() {
      favoriteMosques = favorites;
      isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(Map<String, dynamic> mosque) async {
    final success = await FavoritesService.removeFromFavorites(
      mosqueName: mosque['name'],
      mosqueAddress: mosque['address'],
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadFavoriteMosques(); // Reload the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Mosques'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteMosques.isEmpty
              ? _buildEmptyState()
              : _buildMosquesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppConfig.primaryTealColor).withOpacity(0.1),
                    Color(AppConfig.secondaryTealColor).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_border,
                size: 64,
                color: Color(AppConfig.primaryTealColor),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Liked Mosques',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t liked any mosques yet. Start exploring and tap the heart icon on mosques you like!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosquesList() {
    return RefreshIndicator(
      onRefresh: _loadFavoriteMosques,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteMosques.length,
        itemBuilder: (context, index) {
          final mosque = favoriteMosques[index];
          return _buildMosqueCard(mosque);
        },
      ),
    );
  }

  Widget _buildMosqueCard(Map<String, dynamic> mosque) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MosqueDetailScreen(
                  mosqueName: mosque['name'],
                  mosqueAddress: mosque['address'],
                  mosqueDescription: mosque['description'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Mosque Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(AppConfig.primaryTealColor),
                        Color(AppConfig.secondaryTealColor),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Mosque Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mosque['address'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (mosque['description'] != null && mosque['description'].isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          mosque['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Added ${_formatDate(mosque['dateAdded'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                // Remove Button
                IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () => _showRemoveDialog(mosque),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(Map<String, dynamic> mosque) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Favorites'),
          content: Text('Are you sure you want to remove "${mosque['name']}" from your favorites?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFromFavorites(mosque);
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'today';
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      }
    } catch (e) {
      return 'recently';
    }
  }
}