import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_config.dart';
import '../../services/local_notification_service.dart';
import '../../services/favorites_service.dart';
import '../../services/mosque_subscription_service.dart';
import '../../models/announcement.dart';
import '../../widgets/announcement_modal.dart';
import '../announcements/announcement_event_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MosqueDetailScreen extends StatefulWidget {
  final String mosqueName;
  final String mosqueAddress;
  final String? mosqueDescription;

  const MosqueDetailScreen({
    super.key,
    required this.mosqueName,
    required this.mosqueAddress,
    this.mosqueDescription,
  });

  @override
  State<MosqueDetailScreen> createState() => _MosqueDetailScreenState();
}

class _MosqueDetailScreenState extends State<MosqueDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  bool isSubscribed = false;
  List<Announcement> announcements = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSubscriptionStatus();
    _loadFavoriteStatus();
    _loadDummyAnnouncements();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _loadDummyAnnouncements() {
    announcements = [
      Announcement(
        id: '1',
        title: 'Eid al-Adha Prayer Times',
        description:
            'Join us for the Eid al-Adha prayers. First prayer at 7:00 AM, second prayer at 9:00 AM.',
        fullContent:
            'We invite all community members to join us for the blessed Eid al-Adha prayers. The first prayer will be held at 7:00 AM and the second prayer at 9:00 AM. Please arrive 15 minutes early for preparation. After the prayers, we will have a community breakfast in the main hall. All families are welcome to participate in this joyous celebration.',
        date: 'June 28, 2024',
        type: AnnouncementType.event,
        color: Colors.orange,
        icon: Icons.access_time,
        location:
            'Islamic Center of Greater Cincinnati, 8092 Plantation Dr, Cincinnati, OH 45236',
        eventTime: '7:00 AM - 11:00 AM',
        organizer: 'Islamic Center of Greater Cincinnati',
        tags: ['Prayer', 'Eid', 'Community'],
      ),
      Announcement(
        id: '2',
        title: 'Weekly Quran Circle',
        description:
            'Our weekly Quran circle for brothers will be held this Friday after Isha prayer.',
        fullContent:
            'Join us every Friday after Isha prayer for our weekly Quran study circle. This week we will be discussing Surah Al-Kahf and its lessons for modern life. The session is open to all brothers in the community. Light refreshments will be provided.',
        date: 'June 21, 2024',
        type: AnnouncementType.shortAnnouncement,
        color: Color(AppConfig.primaryTealColor),
        icon: Icons.book,
        location: 'Main Prayer Hall',
        organizer: 'Brother Ahmed Hassan',
        tags: ['Quran', 'Study', 'Weekly'],
      ),
      Announcement(
        id: '3',
        title: 'Youth Group Hiking Adventure',
        description:
            'The youth group will be going for a hike and picnic this Saturday. Please register by Thursday.',
        fullContent:
            'Join our youth group for an exciting hiking adventure at Red River Gorge, Kentucky! We will depart from the mosque at 8:00 AM and return by 6:00 PM. The hike includes beautiful scenic views, team building activities, and a community picnic lunch. This event is open to youth ages 13-25. Registration fee is \$25 per person which includes transportation, lunch, and activities. Please bring comfortable hiking shoes, water bottle, and a positive attitude!',
        date: 'June 22, 2024',
        type: AnnouncementType.event,
        color: Colors.lightBlue,
        icon: Icons.group,
        location: 'Red River Gorge, Kentucky (Departure from mosque)',
        eventTime: '8:00 AM - 6:00 PM',
        organizer: 'Youth Committee',
        tags: ['Youth', 'Outdoor', 'Adventure', 'Community'],
      ),
      Announcement(
        id: '4',
        title: 'Ramadan Iftar Schedule',
        description:
            'Community Iftar will be held every Friday during Ramadan in the main hall.',
        fullContent:
            'During the blessed month of Ramadan, we will be hosting community Iftar every Friday in the main hall. Iftar will begin at sunset prayer time. All community members and their families are welcome to join us for this spiritual gathering. Please bring a dish to share if possible. We will also have Tarawih prayers immediately after Iftar.',
        date: 'March 15, 2024',
        type: AnnouncementType.shortAnnouncement,
        color: Colors.purple,
        icon: Icons.restaurant,
        location: 'Main Hall',
        organizer: 'Community Affairs Committee',
        tags: ['Ramadan', 'Iftar', 'Community'],
      ),
      Announcement(
        id: '5',
        title: 'Islamic Finance Workshop',
        description:
            'Learn about Islamic banking and investment principles in this comprehensive workshop.',
        fullContent:
            'Join us for a comprehensive workshop on Islamic Finance principles and practices. This educational session will cover Islamic banking, halal investment options, avoiding riba (interest), and practical financial planning according to Islamic guidelines. The workshop will be conducted by Dr. Sarah Ahmed, a certified Islamic finance expert from the University of Chicago. Light lunch will be provided. Registration is required as seating is limited to 50 participants.',
        date: 'July 5, 2024',
        type: AnnouncementType.event,
        color: Colors.green,
        icon: Icons.account_balance,
        location: 'Conference Room, Islamic Center of Greater Cincinnati',
        eventTime: '10:00 AM - 3:00 PM',
        organizer: 'Educational Committee',
        tags: ['Education', 'Finance', 'Workshop', 'Islamic Banking'],
      ),
    ];
  }

  Future<void> _shareMosque() async {
    try {
      final String shareText = '''
🕌 ${widget.mosqueName}

📍 Address: ${widget.mosqueAddress}

${widget.mosqueDescription ?? 'A vibrant community center dedicated to serving the spiritual, educational, and social needs of the Muslim community.'}

Discover more mosques and stay updated with community events through our app!
''';

      await Share.share(
        shareText,
        subject: 'Check out ${widget.mosqueName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share at this time. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    final isSubscribed = await MosqueSubscriptionService.isSubscribedToMosque(
      mosqueName: widget.mosqueName,
    );
    setState(() {
      this.isSubscribed = isSubscribed;
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await FavoritesService.isFavorite(
      mosqueName: widget.mosqueName,
      mosqueAddress: widget.mosqueAddress,
    );
    setState(() {
      isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      // Remove from favorites
      final success = await FavoritesService.removeFromFavorites(
        mosqueName: widget.mosqueName,
        mosqueAddress: widget.mosqueAddress,
      );
      if (success) {
        setState(() {
          isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Add to favorites
      final success = await FavoritesService.addToFavorites(
        mosqueName: widget.mosqueName,
        mosqueAddress: widget.mosqueAddress,
        mosqueDescription: widget.mosqueDescription,
      );
      if (success) {
        setState(() {
          isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleSubscription() async {
    if (isSubscribed) {
      // Unsubscribe
      final success = await MosqueSubscriptionService.unsubscribeFromMosque(
        mosqueName: widget.mosqueName,
      );
      if (success) {
        setState(() {
          isSubscribed = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unsubscribed from mosque notifications'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Subscribe
      final success = await MosqueSubscriptionService.subscribeToMosque(
        mosqueName: widget.mosqueName,
        mosqueAddress: widget.mosqueAddress,
        mosqueDescription: widget.mosqueDescription,
      );
      if (success) {
        setState(() {
          isSubscribed = true;
        });
        _showSubscriptionSuccessMessage();
        // Show push notification
        await _showSubscriptionPushNotification();
      }
    }
  }

  void _showSubscriptionSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You will now be notified of new events by ${widget.mosqueName}.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(AppConfig.primaryTealColor),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showSubscriptionPushNotification() async {
    try {
      await LocalNotificationService().showCustomNotification(
        title: 'Subscription Confirmed',
        body: 'You will now be notified of new events by ${widget.mosqueName}.',
        payload: 'mosque_subscription:${widget.mosqueName}',
      );
    } catch (e) {
      print('Error showing push notification: $e');
    }
  }

  void _handleAnnouncementTap(Announcement announcement) {
    if (announcement.isShortAnnouncement) {
      AnnouncementModal.show(context, announcement);
    } else if (announcement.isEvent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AnnouncementEventDetailScreen(event: announcement),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMosqueInfo(),
                _buildSubscribeSection(),
                _buildTabSection(),
                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Color(AppConfig.primaryTealColor),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareMosque,
        ),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.mosqueName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(AppConfig.primaryTealColor),
                Color(AppConfig.secondaryTealColor),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Mosque illustration
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: _buildMosqueIllustration(),
                ),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(AppConfig.primaryTealColor).withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMosqueIllustration() {
    return Container(
      width: 200,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main dome
          Positioned(
            bottom: 40,
            child: Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
            ),
          ),
          // Minaret
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 20,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Minaret top
          Positioned(
            right: 15,
            bottom: 110,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Crescent moon
          Positioned(
            right: 22,
            bottom: 135,
            child: Icon(
              Icons.brightness_2,
              color: Colors.amber,
              size: 16,
            ),
          ),
          // Palm trees
          Positioned(
            left: 10,
            bottom: 20,
            child: Icon(
              Icons.nature,
              color: Colors.green.withOpacity(0.8),
              size: 30,
            ),
          ),
          Positioned(
            right: 50,
            bottom: 20,
            child: Icon(
              Icons.nature,
              color: Colors.green.withOpacity(0.8),
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosqueInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mosqueName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mosqueAddress,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: _shareMosque,
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  if (isSubscribed)
                    IconButton(
                      icon: Icon(
                        Icons.notifications_active,
                        color: Color(AppConfig.primaryTealColor),
                      ),
                      onPressed: _toggleSubscription,
                      tooltip: 'Subscribed to notifications',
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.mosqueDescription ??
                'Al-Noor Mosque is a vibrant community center dedicated to serving the spiritual, educational, and social needs of the Muslim community in Anytown.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeSection() {
    // Only show the subscribe section if user is not subscribed
    if (isSubscribed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Color(AppConfig.primaryTealColor),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stay Updated',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get notified about new events and announcements',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConfig.primaryTealColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Subscribe for Updates',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: _showAnnouncementCategoryFilter,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: Color(AppConfig.primaryTealColor),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...announcements
            .map((announcement) => _buildAnnouncementCard(announcement)),
      ],
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleAnnouncementTap(announcement),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: announcement.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  announcement.icon,
                  color: announcement.color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (announcement.isEvent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: announcement.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'EVENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: announcement.color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          announcement.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (announcement.location != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              announcement.location!.split(',').first,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                announcement.isEvent
                    ? Icons.arrow_forward_ios
                    : Icons.info_outline,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    if (_tabController == null) {
      return const SizedBox
          .shrink(); // Return empty widget if controller not initialized
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Tab Bar with Shadow and Gradient
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: TabBar(
              controller: _tabController!,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppConfig.primaryTealColor),
                    Color(AppConfig.primaryTealColor).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(AppConfig.primaryTealColor).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('Announcements'),
                    ],
                  ),
                ),
                Tab(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('Events'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Enhanced Tab Content with Better Styling
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 580,
              child: TabBarView(
                controller: _tabController!,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildAnnouncementsTab(),
                  _buildEventsTab(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsTab() {
    final query = FirebaseFirestore.instance
        .collection('mosqueapp_announcements')
        .where('organizationName', isEqualTo: widget.mosqueName)
        .where('organizationAddress', isEqualTo: widget.mosqueAddress);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load',
            subtitle: 'Unable to load announcements right now.',
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.campaign_outlined,
            title: 'No Announcements',
            subtitle: 'There are no announcements available at this time.',
          );
        }

        final announcementsList = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String title = (data['title'] ?? '').toString();
          final String description = (data['description'] ?? '').toString();
          final String fullContent = (data['content'] ?? data['fullContent'] ?? description).toString();
          final String date = (data['publishedAt'] is Timestamp)
              ? ((data['publishedAt'] as Timestamp).toDate().toLocal().toString().split(' ').first)
              : (data['updatedAt'] is Timestamp)
                  ? ((data['updatedAt'] as Timestamp).toDate().toLocal().toString().split(' ').first)
                  : (data['date'] ?? '').toString();

          return Announcement(
            id: doc.id,
            title: title,
            description: description,
            fullContent: fullContent,
            date: date,
            type: AnnouncementType.shortAnnouncement,
            color: Color(AppConfig.primaryTealColor),
            icon: Icons.campaign_rounded,
            location: data['location']?.toString(),
            organizer: data['organizationName']?.toString(),
            tags: (data['tags'] as List?)?.map((e) => e.toString()).toList(),
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          physics: const BouncingScrollPhysics(),
          itemCount: announcementsList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == announcementsList.length - 1 ? 0 : 16,
              ),
              child: _buildAnnouncementCard(announcementsList[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsTab() {
    final query = FirebaseFirestore.instance
        .collection('mosqueapp_events')
        .where('organization.organizationName', isEqualTo: widget.mosqueName)
        .where('organization.address', isEqualTo: widget.mosqueAddress);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat',
            subtitle: 'Tidak dapat memuat data acara saat ini.',
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_note_outlined,
            title: 'Belum Ada Acara',
            subtitle: 'Saat ini belum ada acara yang akan datang.',
          );
        }

        final eventsList = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String title = (data['title'] ?? '').toString();
          final String description = (data['description'] ?? '').toString();
          final String fullContent = (data['content'] ?? data['fullContent'] ?? description).toString();

          // Determine date string from event 'date' or fallback timestamps
          String dateStr;
          if (data['date'] is Timestamp) {
            dateStr = (data['date'] as Timestamp)
                .toDate()
                .toLocal()
                .toString()
                .split(' ')
                .first;
          } else if (data['updatedAt'] is Timestamp) {
            dateStr = (data['updatedAt'] as Timestamp)
                .toDate()
                .toLocal()
                .toString()
                .split(' ')
                .first;
          } else if (data['createdAt'] is Timestamp) {
            dateStr = (data['createdAt'] as Timestamp)
                .toDate()
                .toLocal()
                .toString()
                .split(' ')
                .first;
          } else {
            dateStr = (data['date'] ?? '').toString();
          }

          // Build optional event time from stored hour/minute if available
          String? eventTime;
          if (data['time'] is Map<String, dynamic>) {
            final t = data['time'] as Map<String, dynamic>;
            final int? h = (t['hour'] as num?)?.toInt();
            final int? m = (t['minute'] as num?)?.toInt();
            if (h != null && m != null) {
              final mm = m.toString().padLeft(2, '0');
              eventTime = '$h:$mm';
            }
          }

          return Announcement(
            id: doc.id,
            title: title,
            description: description,
            fullContent: fullContent,
            date: dateStr,
            type: AnnouncementType.event,
            color: Color(AppConfig.primaryTealColor),
            icon: Icons.event_note_rounded,
            location: (data['location'] ?? data['organization']?['address'])?.toString(),
            eventTime: eventTime,
            organizer: (data['organization']?['organizationName'] ?? data['organizationName'])?.toString(),
            tags: (data['tags'] as List?)?.map((e) => e.toString()).toList(),
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          physics: const BouncingScrollPhysics(),
          itemCount: eventsList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == eventsList.length - 1 ? 0 : 16,
              ),
              child: _buildAnnouncementCard(eventsList[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                height: 1.4,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnouncementCategoryFilterBottomSheet(),
    );
  }
}

class AnnouncementCategoryFilterBottomSheet extends StatefulWidget {
  @override
  _AnnouncementCategoryFilterBottomSheetState createState() =>
      _AnnouncementCategoryFilterBottomSheetState();
}

class _AnnouncementCategoryFilterBottomSheetState
    extends State<AnnouncementCategoryFilterBottomSheet> {
  String selectedCategory = 'All Categories';

  // Dynamic categories that would be added by mosques
  final List<Map<String, dynamic>> dynamicCategories = [
    {
      'title': 'All Categories',
      'subtitle': 'Show all announcements and events',
      'icon': Icons.all_inclusive,
      'count': 15,
      'color': Color(AppConfig.primaryTealColor),
    },
    {
      'title': 'Prayer Times',
      'subtitle': 'Daily prayer schedules and updates',
      'icon': Icons.access_time,
      'count': 5,
      'color': Colors.blue,
    },
    {
      'title': 'Community Events',
      'subtitle': 'Social gatherings and community activities',
      'icon': Icons.groups,
      'count': 3,
      'color': Colors.green,
    },
    {
      'title': 'Educational Programs',
      'subtitle': 'Islamic studies and learning sessions',
      'icon': Icons.school,
      'count': 4,
      'color': Colors.orange,
    },
    {
      'title': 'Charity & Donations',
      'subtitle': 'Fundraising and charitable activities',
      'icon': Icons.volunteer_activism,
      'count': 2,
      'color': Colors.purple,
    },
    {
      'title': 'Youth Activities',
      'subtitle': 'Programs designed for young Muslims',
      'icon': Icons.sports_soccer,
      'count': 1,
      'color': Colors.indigo,
    },
    // Example of dynamic category added by mosque
    {
      'title': 'XOP Events',
      'subtitle': 'Special XOP category events',
      'icon': Icons.star,
      'count': 0,
      'color': Colors.amber,
    },
    {
      'title': 'Ramadan Special',
      'subtitle': 'Ramadan-specific programs and events',
      'icon': Icons.nightlight_round,
      'count': 0,
      'color': Colors.deepPurple,
    },
    {
      'title': 'Friday Khutbah',
      'subtitle': 'Weekly Friday sermon topics',
      'icon': Icons.mic,
      'count': 0,
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.65, // 65% of screen height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dynamic categories from mosque settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search categories...',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Categories list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: dynamicCategories.length,
              itemBuilder: (context, index) {
                final category = dynamicCategories[index];
                final isSelected = selectedCategory == category['title'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['title'];
                    });

                    // Close bottom sheet after selection
                    Navigator.pop(context);

                    // Show snackbar with selected category
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Category filter applied: ${category['title']}'),
                        backgroundColor: Color(AppConfig.primaryTealColor),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(AppConfig.primaryTealColor).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Color(AppConfig.primaryTealColor)
                            : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category['color']
                                : category['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category['icon'],
                            color:
                                isSelected ? Colors.white : category['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Color(AppConfig.primaryTealColor)
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category['subtitle'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(AppConfig.primaryTealColor)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${category['count']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            if (category['count'] == 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom action area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'All Categories';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Clear Filter',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Filter applied: $selectedCategory'),
                          backgroundColor: Color(AppConfig.primaryTealColor),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppConfig.primaryTealColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Apply Filter',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
