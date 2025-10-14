import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/announcement_model.dart';
import '../../models/user_model.dart';
import 'announcement_detail_screen.dart';
import 'create_announcement_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AnnouncementCategory? _selectedCategory;
  bool _showOnlyBoosted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnnouncementProvider>(context, listen: false).loadAnnouncements();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildAnnouncementsList()),
        ],
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser?.userType == UserType.organization) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateAnnouncementScreen(),
                  ),
                );
              },
              backgroundColor: Color(AppConfig.primaryTealColor),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search announcements...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
          ),
        ),
        onChanged: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Boosted'),
            selected: _showOnlyBoosted,
            onSelected: (selected) {
              setState(() {
                _showOnlyBoosted = selected;
              });
              _performSearch();
            },
            selectedColor: Color(AppConfig.primaryTealColor).withOpacity(0.2),
            checkmarkColor: Color(AppConfig.primaryTealColor),
          ),
          const SizedBox(width: 8),
          ...AnnouncementCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getCategoryName(category)),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                  _performSearch();
                },
                selectedColor: Color(AppConfig.primaryTealColor).withOpacity(0.2),
                checkmarkColor: Color(AppConfig.primaryTealColor),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Consumer<AnnouncementProvider>(
      builder: (context, announcementProvider, child) {
        if (announcementProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (announcementProvider.announcements.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => announcementProvider.loadAnnouncements(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            itemCount: announcementProvider.announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcementProvider.announcements[index];
              return _buildAnnouncementCard(announcement);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No announcements found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new announcements',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(announcement: announcement),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (announcement.isCurrentlyBoosted) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'BOOSTED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getCategoryName(announcement.category),
                                style: TextStyle(
                                  color: Color(AppConfig.primaryTealColor),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          announcement.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          announcement.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (announcement.imageUrls.isNotEmpty)
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(announcement.imageUrls.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    announcement.organizationName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(announcement.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (announcement.expiresAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: announcement.isExpired ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement.isExpired
                          ? 'Expired'
                          : 'Expires ${_formatDate(announcement.expiresAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: announcement.isExpired ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch() {
    setState(() {
      // Trigger rebuild to filter announcements
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Announcements'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show only boosted'),
              value: _showOnlyBoosted,
              onChanged: (value) {
                setState(() {
                  _showOnlyBoosted = value ?? false;
                });
              },
              activeColor: Color(AppConfig.primaryTealColor),
            ),
            const Divider(),
            const Text('Category:'),
            ...AnnouncementCategory.values.map((category) {
              return RadioListTile<AnnouncementCategory?>(
                title: Text(_getCategoryName(category)),
                value: category,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                activeColor: Color(AppConfig.primaryTealColor),
              );
            }),
            RadioListTile<AnnouncementCategory?>(
              title: const Text('All Categories'),
              value: null,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = null;
                });
              },
              activeColor: Color(AppConfig.primaryTealColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSearch();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.general:
        return 'General';
      case AnnouncementCategory.event:
        return 'Event';
      case AnnouncementCategory.prayer:
        return 'Prayer';
      case AnnouncementCategory.education:
        return 'Education';
      case AnnouncementCategory.charity:
        return 'Charity';
      case AnnouncementCategory.community:
        return 'Community';
      case AnnouncementCategory.emergency:
        return 'Emergency';
      case AnnouncementCategory.other:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}