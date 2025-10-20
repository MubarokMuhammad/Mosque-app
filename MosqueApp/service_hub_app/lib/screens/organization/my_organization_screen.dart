import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
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

  // Remove hardcoded stats - will be replaced with dynamic data
  // final List<Map<String, dynamic>> _organizationStats = [...];

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

        if (user == null) {
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
            ),
            child: const Center(
              child: Text(
                'Please login to view organization',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('mosqueapp_organizations')
              .where('adminIds', arrayContains: user.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
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
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
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
                ),
                child: const Center(
                  child: Text(
                    'Error loading organization data',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            // Get organization data
            String organizationName = 'No Organization Found';
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final orgData =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              // Try to get organizationName from different possible locations
              if (orgData['organizationName'] != null) {
                organizationName = orgData['organizationName'];
              } else if (orgData['name'] != null) {
                organizationName = orgData['name'];
              } else {
                organizationName = 'Unknown Organization';
              }
            }

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
                          organizationName,
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
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final userEmail = authProvider.firebaseUser?.email;

                if (userEmail == null) {
                  return _buildEmptyEventsState('User not authenticated');
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('mosqueapp_events')
                      .where('createdBy.userEmail', isEqualTo: userEmail)
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorEventsState('Error loading events');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingEventsState();
                    }

                    final events = snapshot.data?.docs ?? [];

                    if (events.isEmpty) {
                      return _buildEmptyEventsState('No events created yet');
                    }

                    // Sort events by createdAt manually to avoid composite index requirement
                    final sortedEvents = List.from(events);
                    sortedEvents.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['createdAt'] as Timestamp?;
                      final bTime = bData['createdAt'] as Timestamp?;

                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;

                      return bTime
                          .compareTo(aTime); // Descending order (newest first)
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: sortedEvents.length,
                      itemBuilder: (context, index) {
                        final eventData =
                            sortedEvents[index].data() as Map<String, dynamic>;
                        return _buildEventCardFromFirestore(eventData);
                      },
                    );
                  },
                );
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userEmail = authProvider.userModel?.email;

        if (userEmail == null) {
          return const Center(
            child: Text('User not logged in'),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('mosqueapp_events')
              .where('createdBy.userEmail', isEqualTo: userEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final events = snapshot.data?.docs ?? [];
            final totalEvents = events.length;

            // Calculate events this month
            final now = DateTime.now();
            final thisMonth = events.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = data['createdAt'] as Timestamp?;
              if (createdAt == null) return false;
              final eventDate = createdAt.toDate();
              return eventDate.year == now.year && eventDate.month == now.month;
            }).length;

            // Get announcements count from separate stream
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mosqueapp_announcements')
                  .where('authorEmail', isEqualTo: userEmail)
                  .snapshots(),
              builder: (context, announcementSnapshot) {
                int totalAnnouncements = 0;
                
                if (announcementSnapshot.hasData) {
                  totalAnnouncements = announcementSnapshot.data?.docs.length ?? 0;
                }

                // Get members count from organization data
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('mosqueapp_organizations')
                      .where('userDetails.email', isEqualTo: userEmail)
                      .limit(1)
                      .snapshots(),
                  builder: (context, orgSnapshot) {
                    // Get members count using organization data
                    return StreamBuilder<QuerySnapshot>(
                      stream: orgSnapshot.hasData && orgSnapshot.data!.docs.isNotEmpty
                          ? (() {
                              final orgData = orgSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                              final mosqueName = orgData['organizationName'];
                              final mosqueAddress = orgData['address'];
                              
                              if (mosqueName != null && mosqueAddress != null) {
                                return FirebaseFirestore.instance
                                    .collection('mosqueapp_subscribe_mosques')
                                    .where('mosqueName', isEqualTo: mosqueName)
                                    .where('mosqueAddress', isEqualTo: mosqueAddress)
                                    .snapshots();
                              }
                              return null;
                            })()
                          : null,
                      builder: (context, membersSnapshot) {
                        int totalMembers = 0;
                        
                        if (membersSnapshot?.hasData == true) {
                          // Count only active members with userName
                          totalMembers = membersSnapshot!.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['userName'] != null;
                          }).length;
                        }

                        final organizationStats = [
                          {
                            'title': 'Total Events',
                            'value': totalEvents.toString(),
                            'icon': Icons.event,
                            'color': Colors.blue
                          },
                          {
                            'title': 'Active Members',
                            'value': totalMembers.toString(),
                            'icon': Icons.people,
                            'color': Colors.green
                          },
                          {
                            'title': 'This Month',
                            'value': thisMonth.toString(),
                            'icon': Icons.calendar_month,
                            'color': Colors.orange
                          },
                          {
                            'title': 'Announcements',
                            'value': totalAnnouncements.toString(),
                            'icon': Icons.campaign,
                            'color': Colors.purple
                          },
                        ];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    1.3, // Increased from 1.2 to 1.3 to give more width
              ),
              itemCount: organizationStats.length,
              itemBuilder: (context, index) {
                final stat = organizationStats[index];
                final color = stat['color'] as Color;
                final icon = stat['icon'] as IconData;
                final value = stat['value'] as String;
                final title = stat['title'] as String;

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
                        padding:
                            const EdgeInsets.all(10), // Reduced from 12 to 10
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 22, // Reduced from 24 to 22
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced from 12 to 8
                      Flexible(
                        // Wrapped with Flexible to prevent overflow
                        child: Text(
                          value,
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
                          title,
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
                       },
                     );
                   },
                 );
               },
             );
          },
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
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.firebaseUser?.email == null) {
                return _buildEmptyActivityState(
                    'Please login to view activity');
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mosqueapp_events')
                    .where('createdBy.userEmail',
                        isEqualTo: authProvider.firebaseUser!.email)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingActivityState();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorActivityState(
                        'Error loading activity data');
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyActivityState('No recent activity found');
                  }

                  final events = snapshot.data!.docs;

                  // Sort events by createdAt manually to avoid composite index requirement
                  final sortedEvents = List.from(events);
                  sortedEvents.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;

                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;

                    return bTime
                        .compareTo(aTime); // Descending order (newest first)
                  });

                  return Column(
                    children: sortedEvents.map((doc) {
                      final eventData = doc.data() as Map<String, dynamic>;
                      return _buildActivityItemFromEvent(eventData);
                    }).toList(),
                  );
                },
              );
            },
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

  // Helper methods for activity states
  Widget _buildLoadingActivityState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(AppConfig.primaryTealColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading recent activity...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivityState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Activity will appear here when you create events',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorActivityState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItemFromEvent(Map<String, dynamic> eventData) {
    final title = eventData['title'] ?? 'Untitled Event';
    final status = eventData['status'] ?? 'draft';
    final createdAt = eventData['createdAt'] as Timestamp?;

    String timeAgo = 'Unknown time';
    if (createdAt != null) {
      final now = DateTime.now();
      final eventTime = createdAt.toDate();
      final difference = now.difference(eventTime);

      if (difference.inDays > 0) {
        timeAgo =
            '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        timeAgo =
            '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        timeAgo =
            '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    String action;
    IconData icon;
    Color iconColor = Color(AppConfig.primaryTealColor);

    switch (status.toLowerCase()) {
      case 'published':
        action = 'Event published';
        icon = Icons.publish_rounded;
        iconColor = Colors.green;
        break;
      case 'draft':
        action = 'Event saved as draft';
        icon = Icons.drafts_rounded;
        iconColor = Colors.orange;
        break;
      case 'completed':
        action = 'Event completed';
        icon = Icons.check_circle_rounded;
        iconColor = Colors.blue;
        break;
      default:
        action = 'Event created';
        icon = Icons.event_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeAgo,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for events states
  Widget _buildLoadingEventsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(AppConfig.primaryTealColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading events...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEventsState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first event to see it here',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConfig.primaryTealColor),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorEventsState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // Trigger rebuild to retry
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCardFromFirestore(Map<String, dynamic> eventData) {
    final title = eventData['title'] ?? 'Untitled Event';
    final category = eventData['category'] ?? 'General';
    final status = eventData['status'] ?? 'draft';
    final createdAt = eventData['createdAt'] as Timestamp?;
    final eventDate = eventData['date'] as Timestamp?;

    // Calculate time ago
    String timeAgo = 'Just created';
    if (createdAt != null) {
      final difference = DateTime.now().difference(createdAt.toDate());
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}m ago';
      }
    }

    // Format event date
    String eventDateStr = 'No date';
    if (eventDate != null) {
      final date = eventDate.toDate();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      eventDateStr = '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    // Status configuration
    final statusConfig = _getStatusConfig(status);

    return GestureDetector(
      onTap: () => _showEventDetailBottomSheet(eventData),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusConfig['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      statusConfig['icon'],
                      color: statusConfig['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusConfig['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusConfig['text'],
                      style: TextStyle(
                        fontSize: 11,
                        color: statusConfig['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    eventDateStr,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return {
          'color': Colors.green,
          'icon': Icons.publish_rounded,
          'text': 'Published'
        };
      case 'draft':
        return {
          'color': Colors.orange,
          'icon': Icons.edit_rounded,
          'text': 'Draft'
        };
      case 'completed':
        return {
          'color': Colors.blue,
          'icon': Icons.check_circle_rounded,
          'text': 'Completed'
        };
      default:
        return {
          'color': Color(AppConfig.primaryTealColor),
          'icon': Icons.event_rounded,
          'text': 'Active'
        };
    }
  }

  void _showEventDetailBottomSheet(Map<String, dynamic> eventData) {
    final title = eventData['title'] ?? 'Untitled Event';
    final description = eventData['description'] ?? 'No description available';
    final category = eventData['category'] ?? 'General';
    final location = eventData['location'] ?? 'No location specified';
    final status = eventData['status'] ?? 'draft';
    final createdAt = eventData['createdAt'] as Timestamp?;
    final eventDate = eventData['date'] as Timestamp?;
    final eventTime = eventData['time'] as Map<String, dynamic>?;
    final tags = eventData['tags'] as List<dynamic>? ?? [];
    final capacity = eventData['capacity'] as int?;
    final price = eventData['price'] as double?;
    final createdBy = eventData['createdBy'] as Map<String, dynamic>?;

    final statusConfig = _getStatusConfig(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
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
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusConfig['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      statusConfig['icon'],
                      color: statusConfig['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusConfig['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusConfig['text'],
                            style: TextStyle(
                              fontSize: 12,
                              color: statusConfig['color'],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (description.isNotEmpty &&
                        description != 'No description available') ...[
                      _buildDetailSection(
                        'Description',
                        Icons.description_outlined,
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Event Details
                    _buildDetailSection(
                      'Event Details',
                      Icons.info_outline_rounded,
                      Column(
                        children: [
                          _buildDetailRow(
                            Icons.category_outlined,
                            'Category',
                            category,
                          ),
                          if (eventDate != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.calendar_today_outlined,
                              'Date',
                              _formatEventDate(eventDate),
                            ),
                          ],
                          if (eventTime != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.access_time_rounded,
                              'Time',
                              _formatEventTime(eventTime),
                            ),
                          ],
                          if (location.isNotEmpty &&
                              location != 'No location specified') ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.location_on_outlined,
                              'Location',
                              location,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Event Settings
                    if (capacity != null || price != null) ...[
                      const SizedBox(height: 24),
                      _buildDetailSection(
                        'Event Settings',
                        Icons.settings_outlined,
                        Column(
                          children: [
                            if (capacity != null) ...[
                              _buildDetailRow(
                                Icons.people_outline_rounded,
                                'Capacity',
                                '$capacity attendees',
                              ),
                            ],
                            if (price != null) ...[
                              if (capacity != null) const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.attach_money_rounded,
                                'Price',
                                price == 0
                                    ? 'Free'
                                    : '\$${price.toStringAsFixed(2)}',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Tags
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildDetailSection(
                        'Tags',
                        Icons.tag_rounded,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                tag.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // Created Info
                    if (createdAt != null) ...[
                      const SizedBox(height: 24),
                      _buildDetailSection(
                        'Created',
                        Icons.history_rounded,
                        Column(
                          children: [
                            _buildDetailRow(
                              Icons.schedule_rounded,
                              'Created At',
                              _formatCreatedDate(createdAt),
                            ),
                            if (createdBy != null &&
                                createdBy['userName'] != null) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.person_outline_rounded,
                                'Created By',
                                createdBy['userName'].toString(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToEditEvent(eventData);
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit Event'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: Color(AppConfig.primaryTealColor),
                            width: 1.5),
                        foregroundColor: Color(AppConfig.primaryTealColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareEvent(eventData);
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConfig.primaryTealColor),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor:
                            Color(AppConfig.primaryTealColor).withOpacity(0.3),
                      ),
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

  Widget _buildDetailSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatEventDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatEventTime(Map<String, dynamic> timeData) {
    final hour = timeData['hour'] ?? 0;
    final minute = timeData['minute'] ?? 0;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatCreatedDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToEditEvent(Map<String, dynamic> eventData) {
    try {
      // For now, navigate to CreateEventScreen for creating a new event
      // In a full implementation, you would create an EditEventScreen or modify CreateEventScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateEventScreen(),
        ),
      ).then((result) {
        // Refresh the events list if event was updated
        if (result == true) {
          setState(() {
            // This will trigger a rebuild and refresh the StreamBuilder
          });
        }
      });

      // Show a temporary message about editing functionality
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                    'Edit functionality will be available soon. Creating new event instead.'),
              ],
            ),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Unable to open edit screen. Please try again.'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareEvent(Map<String, dynamic> eventData) async {
    try {
      final title = eventData['title'] ?? 'Untitled Event';
      final description = eventData['description'] ?? '';
      final category = eventData['category'] ?? 'General';
      final location = eventData['location'] ?? '';
      final status = eventData['status'] ?? 'draft';
      final eventDate = eventData['date'] as Timestamp?;
      final eventTime = eventData['time'] as Map<String, dynamic>?;
      final createdBy = eventData['createdBy'] as Map<String, dynamic>?;

      String dateTimeText = '';
      if (eventDate != null) {
        dateTimeText = '📅 ${_formatEventDate(eventDate)}';
        if (eventTime != null) {
          dateTimeText += ' at ${_formatEventTime(eventTime)}';
        }
      }

      final String shareText = '''
🎉 $title

${description.isNotEmpty ? '$description\n' : ''}📍 Location: ${location.isNotEmpty ? location : 'To be announced'}
🏷️ Category: $category
${dateTimeText.isNotEmpty ? '$dateTimeText\n' : ''}${status == 'published' ? '✅ Event is live and accepting registrations!' : '📝 Event details are being finalized'}

${createdBy != null && createdBy['organizationName'] != null ? 'Organized by: ${createdBy['organizationName']}\n' : ''}Join us for this amazing event! Download our app to stay updated with more community events and activities.

#CommunityEvent #${category.replaceAll(' ', '')}
''';

      await Share.share(
        shareText,
        subject: 'Join us: $title',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Event shared successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Unable to share event. Please try again.'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
