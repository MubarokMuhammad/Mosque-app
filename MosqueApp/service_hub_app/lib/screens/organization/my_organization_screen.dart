import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import 'create_event_screen.dart';
import 'manage_members_screen.dart';
import 'announcements_screen.dart';
import 'analytics_screen.dart';
import 'org_settings_screen.dart';

class MyOrganizationScreen extends StatefulWidget {
  const MyOrganizationScreen({Key? key}) : super(key: key);

  @override
  State<MyOrganizationScreen> createState() => _MyOrganizationScreenState();
}

class _MyOrganizationScreenState extends State<MyOrganizationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _organizationStats = [
    {
      'title': 'Total Events',
      'value': '24',
      'icon': Icons.event,
      'color': Colors.blue
    },
    {
      'title': 'Active Members',
      'value': '156',
      'icon': Icons.people,
      'color': Colors.green
    },
    {
      'title': 'This Month',
      'value': '8',
      'icon': Icons.calendar_month,
      'color': Colors.orange
    },
    {
      'title': 'Announcements',
      'value': '12',
      'icon': Icons.campaign,
      'color': Colors.purple
    },
  ];

  final List<Map<String, dynamic>> _recentEvents = [
    {
      'title': 'Friday Prayer',
      'date': 'March 15, 2024',
      'time': '13:00',
      'attendees': 45,
      'status': 'active',
      'type': 'prayer',
    },
    {
      'title': 'Quran Study Circle',
      'date': 'March 18, 2024',
      'time': '19:30',
      'attendees': 20,
      'status': 'active',
      'type': 'study',
    },
    {
      'title': 'Community Iftar',
      'date': 'March 22, 2024',
      'time': '18:45',
      'attendees': 120,
      'status': 'draft',
      'type': 'community',
    },
  ];

  final List<Map<String, dynamic>> _managementOptions = [
    {
      'title': 'Create Event',
      'subtitle': 'Organize new mosque events',
      'icon': Icons.add_circle,
      'action': 'create_event',
      'color': Colors.blue,
    },
    {
      'title': 'Manage Members',
      'subtitle': 'View and manage organization members',
      'icon': Icons.people_alt,
      'action': 'manage_members',
      'color': Colors.green,
    },
    {
      'title': 'Announcements',
      'subtitle': 'Create and manage announcements',
      'icon': Icons.campaign,
      'action': 'announcements',
      'color': Colors.orange,
    },
    {
      'title': 'Event Analytics',
      'subtitle': 'View event performance and statistics',
      'icon': Icons.analytics,
      'action': 'analytics',
      'color': Colors.purple,
    },
    {
      'title': 'Organization Settings',
      'subtitle': 'Manage organization profile and settings',
      'icon': Icons.settings,
      'action': 'org_settings',
      'color': Colors.grey,
    },
    {
      'title': 'Logout',
      'subtitle': 'Sign out of your account',
      'icon': Icons.logout,
      'action': 'logout',
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildEventsTab(),
                      _buildManagementTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create event screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
        },
        backgroundColor: Color(AppConfig.primaryTealColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(AppConfig.primaryTealColor),
                Color(AppConfig.primaryTealColor).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(AppConfig.primaryTealColor).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Al Mubarok Foundation',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Organization',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 5),
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(AppConfig.primaryTealColor),
                  Color(AppConfig.primaryTealColor).withOpacity(0.85),
                  Color(AppConfig.primaryTealColor).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(AppConfig.primaryTealColor).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Color(AppConfig.primaryTealColor).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            indicatorPadding: const EdgeInsets.all(2),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[700],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
            dividerColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
            tabs: [
              Tab(
                height: 44,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard_rounded, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Overview',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Tab(
                height: 44,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_rounded, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Events',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Tab(
                height: 44,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_rounded, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Manage',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: Color(AppConfig.primaryTealColor),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _recentEvents.length,
              itemBuilder: (context, index) {
                return _buildEventCard(_recentEvents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Color(AppConfig.primaryTealColor),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Management Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _managementOptions.length,
              itemBuilder: (context, index) {
                return _buildManagementOptionCard(_managementOptions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3, // Increased from 1.2 to 1.3 to give more width
      ),
      itemCount: _organizationStats.length,
      itemBuilder: (context, index) {
        final stat = _organizationStats[index];
        return Container(
          padding: const EdgeInsets.all(12), // Reduced from 16 to 12
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                decoration: BoxDecoration(
                  color: stat['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stat['icon'],
                  color: stat['color'],
                  size: 22, // Reduced from 24 to 22
                ),
              ),
              const SizedBox(height: 8), // Reduced from 12 to 8
              Flexible(
                // Wrapped with Flexible to prevent overflow
                child: Text(
                  stat['value'],
                  style: const TextStyle(
                    fontSize: 20, // Reduced from 24 to 20
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2), // Reduced from 4 to 2
              Flexible(
                // Wrapped with Flexible to prevent overflow
                child: Text(
                  stat['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, // Reduced from 12 to 11
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Added maxLines to prevent overflow
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: Color(AppConfig.primaryTealColor),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem('New event created', 'Community Iftar',
                  '2 hours ago', Icons.event),
              _buildActivityItem('Member joined', 'Ahmad Hassan', '5 hours ago',
                  Icons.person_add),
              _buildActivityItem('Announcement posted', 'Prayer time update',
                  '1 day ago', Icons.campaign),
              _buildActivityItem('Event completed', 'Friday Prayer',
                  '2 days ago', Icons.check_circle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String action, String detail, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(AppConfig.primaryTealColor),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getEventTypeColor(event['type']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getEventTypeIcon(event['type']),
                color: _getEventTypeColor(event['type']),
                size: 24,
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
                          event['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildEventStatusBadge(event['status']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event['date']} • ${event['time']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event['attendees']} attendees',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(AppConfig.primaryTealColor),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOptionCard(Map<String, dynamic> option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleManagementAction(option['action']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: option['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option['icon'],
                  color: option['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option['subtitle'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'active':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        text = 'Active';
        break;
      case 'draft':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Draft';
        break;
      case 'completed':
        backgroundColor = Color(AppConfig.primaryTealColor).withOpacity(0.1);
        textColor = Color(AppConfig.primaryTealColor);
        text = 'Completed';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'prayer':
        return Color(AppConfig.primaryTealColor);
      case 'study':
        return Colors.blue;
      case 'community':
        return Colors.green;
      case 'celebration':
        return Colors.purple;
      case 'lecture':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type) {
      case 'prayer':
        return Icons.mosque;
      case 'study':
        return Icons.book;
      case 'community':
        return Icons.people;
      case 'celebration':
        return Icons.celebration;
      case 'lecture':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  void _handleManagementAction(String action) {
    switch (action) {
      case 'create_event':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateEventScreen()),
        );
        break;
      case 'manage_members':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageMembersScreen()),
        );
        break;
      case 'announcements':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
        );
        break;
      case 'analytics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
        );
        break;
      case 'org_settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrgSettingsScreen()),
        );
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() {
    // Clear any stored user data or tokens here
    // For example: SharedPreferences, secure storage, etc.
    
    // Navigate to login screen and clear navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }
}
