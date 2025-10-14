import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../widgets/event_detail_bottom_sheet.dart';
import '../../providers/auth_provider.dart';
import '../mosques/mosque_detail_screen.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/announcement_model.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../announcements/announcements_screen.dart';
import '../events/events_screen.dart';
import '../organizations/organizations_screen.dart';
import '../profile/profile_screen.dart';
import '../announcements/announcement_detail_screen.dart';
import '../events/event_detail_screen.dart';
import '../schedule/my_schedule_screen.dart';
import '../events/my_events_screen.dart';
import '../organization/my_organization_screen.dart';
import '../../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCountry = 'Country';
  String _selectedState = 'State/Province';
  String _selectedCity = 'City';
  String _selectedEvent = 'Event';
  String _currentLocationText = 'Detecting location...';
  bool _isLoadingLocation = false;
  bool _hasShownLocationPermission = false;
  Map<String, bool> _subscriptionStatus = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadSubscriptionStatuses();
    // Show location permission popup and initialize location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowLocationPermissionDialog();
    });
    // Delay checking for new social user to ensure AuthProvider is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkNewSocialUser();
    });
  }

  Future<void> _loadSubscriptionStatuses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, bool> statuses = {};

    // Load subscription status for each mosque
    List<String> mosqueNames = [
      'Al-Noor Mosque',
      'Masjid Al-Salam',
      'Masjid Al-Rahman'
    ];
    for (String mosqueName in mosqueNames) {
      String subscriptionKey = 'subscribed_$mosqueName';
      statuses[mosqueName] = prefs.getBool(subscriptionKey) ?? false;
    }

    setState(() {
      _subscriptionStatus = statuses;
    });
  }

  Future<void> _checkAndShowLocationPermissionDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownPermission =
        prefs.getBool('has_shown_location_permission') ?? false;

    if (!hasShownPermission) {
      await prefs.setBool('has_shown_location_permission', true);
      _showLocationPermissionDialog();
    } else {
      // If permission was already shown before, just initialize location
      _initializeLocation();
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(AppConfig.primaryTealColor),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Location Permission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'This app needs location access to automatically detect your current location and show nearby mosques and events.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentLocationText = 'Location not available';
                });
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConfig.primaryTealColor),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Allow',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _currentLocationText = 'Getting location...';
    });

    try {
      bool initialized = await LocationService.instance.initialize();
      if (initialized) {
        await LocationService.instance.getCurrentLocation();
        if (mounted) {
          setState(() {
            _currentLocationText =
                LocationService.instance.getCurrentLocationString();
            _isLoadingLocation = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentLocationText = 'Location not available';
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      print('Error initializing location: $e');
      if (mounted) {
        setState(() {
          _currentLocationText = 'Location error';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _currentLocationText = 'Refreshing location...';
    });

    try {
      await LocationService.instance.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentLocationText =
              LocationService.instance.getCurrentLocationString();
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error refreshing location: $e');
      if (mounted) {
        setState(() {
          _currentLocationText = 'Location error';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _checkNewSocialUser() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print(
        'Checking new social user: ${authProvider.isNewSocialUser}'); // Debug log

    if (authProvider.isNewSocialUser) {
      _showUserTypeSelectionDialog();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final announcementProvider =
          Provider.of<AnnouncementProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      // Load organizations first, then load announcements and events
      await organizationProvider.loadOrganizations();

      // Skip loading announcements and events to avoid Firestore index errors
      // These will be loaded when needed or after indexes are created
      // await Future.wait([
      //   announcementProvider.loadAnnouncements(),
      //   eventProvider.loadEvents(),
      // ]);

      print('Initial data loaded successfully');
    } catch (e) {
      print('Error loading initial data: $e');
      // Continue without showing error to user, as this is not critical for popup
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildMosquesTab(),
          const MyScheduleScreen(),
          // const MyEventsScreen(),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return authProvider.isOrganization
                  ? const MyOrganizationScreen()
                  : const ProfileScreen();
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMosquesTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildFiltersSection(),
            _buildTopEventsSection(),
            _buildAllMosquesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyScheduleTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'My Schedule',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Your prayer times and mosque schedules will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMyEventsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'My Events',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Events you\'ve registered for will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        'Mosques',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for mosques',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            // Location Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: Color(AppConfig.primaryTealColor),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Location Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentLocationText.isEmpty ||
                            _currentLocationText == 'Current Location'
                        ? 'Current Location'
                        : 'Your Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _isLoadingLocation
                      ? Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(AppConfig.primaryTealColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentLocationText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _currentLocationText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Refresh Icon
            GestureDetector(
              onTap: _isLoadingLocation ? null : _refreshLocation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isLoadingLocation
                      ? Colors.grey.withOpacity(0.1)
                      : Color(AppConfig.primaryTealColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh,
                  color: _isLoadingLocation
                      ? Colors.grey[400]
                      : Color(AppConfig.primaryTealColor),
                  size: 18,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Filter Icon
            GestureDetector(
              onTap: _showFilterBottomSheetLocation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Color(AppConfig.primaryTealColor),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheetLocation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
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
                        Icon(
                          Icons.filter_list,
                          color: Color(AppConfig.primaryTealColor),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Filter Options',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedCountry = 'Country';
                              _selectedState = 'State/Province';
                              _selectedCity = 'City';
                              _selectedEvent = 'Event';
                            });
                            setState(() {
                              _selectedCountry = 'Country';
                              _selectedState = 'State/Province';
                              _selectedCity = 'City';
                              _selectedEvent = 'Event';
                            });
                          },
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: Color(AppConfig.primaryTealColor),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country Filter
                        const Text(
                          'Country',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBottomSheetDropdown(
                          _selectedCountry,
                          ['Country', 'United States', 'Canada'],
                          (value) {
                            setModalState(() => _selectedCountry = value!);
                            setState(() => _selectedCountry = value!);
                          },
                        ),

                        const SizedBox(height: 20),

                        // State Filter
                        const Text(
                          'State/Province',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBottomSheetDropdown(
                          _selectedState,
                          [
                            'State/Province',
                            'California',
                            'New York',
                            'Texas',
                            'Florida',
                            'Ontario',
                            'Quebec',
                            'British Columbia',
                            'Alberta'
                          ],
                          (value) {
                            setModalState(() => _selectedState = value!);
                            setState(() => _selectedState = value!);
                          },
                        ),

                        const SizedBox(height: 20),

                        // City Filter
                        const Text(
                          'City',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBottomSheetDropdown(
                          _selectedCity,
                          [
                            'City',
                            'Los Angeles',
                            'New York City',
                            'Houston',
                            'Miami',
                            'Toronto',
                            'Montreal',
                            'Vancouver',
                            'Calgary'
                          ],
                          (value) {
                            setModalState(() => _selectedCity = value!);
                            setState(() => _selectedCity = value!);
                          },
                        ),

                        const SizedBox(height: 20),

                        // Event Filter
                        const Text(
                          'Event Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBottomSheetDropdown(
                          _selectedEvent,
                          ['Event', 'Jumah Prayer', 'Tarawih', 'Eid Prayer'],
                          (value) {
                            setModalState(() => _selectedEvent = value!);
                            setState(() => _selectedEvent = value!);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Apply Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Apply filters logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppConfig.primaryTealColor),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Color(AppConfig.primaryTealColor),
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color:
                      item == items.first ? Colors.grey[600] : Colors.black87,
                  fontWeight:
                      item == items.first ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTopEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Top Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildTopEventCard('Community Iftar', 'Al-Noor Mosque'),
              const SizedBox(width: 16),
              _buildTopEventCard('Eid Prayer', 'Masjid Al-Salam'),
              const SizedBox(width: 16),
              _buildTopEventCard('Quran Study', 'Islamic Center'),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTopEventCard(String title, String mosque) {
    // Map event titles to their corresponding SVG assets
    String getImageAsset(String eventTitle) {
      switch (eventTitle.toLowerCase()) {
        case 'community iftar':
          return 'assets/images/community_iftar.svg';
        case 'eid prayer':
          return 'assets/images/eid_prayer.svg';
        case 'quran study':
          return 'assets/images/quran_study.svg';
        default:
          return 'assets/images/community_iftar.svg';
      }
    }

    // Get event details based on title
    String getEventDescription(String eventTitle) {
      switch (eventTitle.toLowerCase()) {
        case 'community iftar':
          return 'Join us for the Community Iftar at the Grand Mosque. The event will feature special prayers, sermons, and community gatherings. We encourage all members to attend and celebrate this joyous occasion together.';
        case 'eid prayer':
          return 'Join us for the Eid al-Adha celebration at the Grand Mosque. The event will feature special prayers, sermons, and community gatherings. We encourage all members to attend and celebrate this joyous occasion together.';
        case 'quran study':
          return 'Join us for an enlightening Quran Study session at the Islamic Center. Learn and discuss the teachings of the Holy Quran with fellow community members in a peaceful and educational environment.';
        default:
          return 'Join us for this special event at our mosque. We encourage all members to attend and participate in this meaningful gathering.';
      }
    }

    String getEventDate(String eventTitle) {
      switch (eventTitle.toLowerCase()) {
        case 'community iftar':
          return 'March 15, 2024';
        case 'eid prayer':
          return 'July 20, 2024';
        case 'quran study':
          return 'Every Friday, 7:00 PM';
        default:
          return 'Coming Soon';
      }
    }

    return GestureDetector(
      onTap: () {
        showEventDetailBottomSheet(
          context: context,
          title: title,
          date: getEventDate(title),
          description: getEventDescription(title),
          imageAsset: getImageAsset(title),
          likes: 120,
          attending: 50,
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                height: 200,
                child: SvgPicture.asset(
                  getImageAsset(title),
                  fit: BoxFit.cover,
                  width: 280,
                  height: 200,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mosque,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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

  Widget _buildAllMosquesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Mosques',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: _showContentFilterBottomSheet,
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
        _buildMosqueCard('Al-Noor Mosque', '123 Main St, Anytown', true),
        _buildMosqueCard('Masjid Al-Salam', '456 Elm St, Anytown', false),
        _buildMosqueCard('Masjid Al-Rahman', '789 Oak St, Anytown', true),
        const SizedBox(height: 100), // Extra space for bottom navigation
      ],
    );
  }

  Widget _buildMosqueCard(String name, String address, bool hasNotification) {
    bool isSubscribed = _subscriptionStatus[name] ?? false;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MosqueDetailScreen(
              mosqueName: name,
              mosqueAddress: address,
            ),
          ),
        );
        // Reload subscription statuses when returning from detail screen
        _loadSubscriptionStatuses();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(AppConfig.primaryTealColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.mosque,
                color: Colors.white,
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
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isSubscribed)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(AppConfig.primaryTealColor)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: Color(AppConfig.primaryTealColor),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '2.5 km away',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      if (hasNotification)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'New Event',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            selectedItemColor: Color(AppConfig.primaryTealColor),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.mosque),
                label: 'Mosques',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'My Schedule',
              ),
              // const BottomNavigationBarItem(
              //   icon: Icon(Icons.event),
              //   label: 'My Events',
              // ),
              BottomNavigationBarItem(
                icon: Icon(authProvider.isOrganization
                    ? Icons.business
                    : Icons.person),
                label:
                    authProvider.isOrganization ? 'My Organization' : 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(AppConfig.primaryTealColor).withOpacity(0.1),
          child: Icon(
            Icons.campaign,
            color: Color(AppConfig.primaryTealColor),
          ),
        ),
        title: Text(
          announcement.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (announcement.createdBy != null)
              Text(
                'By: ${announcement.createdBy}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
          ],
        ),
        trailing: Text(
          _formatDate(announcement.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AnnouncementDetailScreen(announcement: announcement),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(AppConfig.primaryTealColor).withOpacity(0.1),
          child: Icon(
            Icons.event,
            color: Color(AppConfig.primaryTealColor),
          ),
        ),
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatDate(event.startDateTime)} • ${event.location}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: event.requiresRegistration
            ? Icon(
                Icons.how_to_reg,
                color: Color(AppConfig.primaryTealColor),
                size: 20,
              )
            : null,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
      ),
    );
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

  void _showUserTypeSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select Account Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please select the account type that suits your needs:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildUserTypeOption(
                title: 'Regular User',
                subtitle: 'For general users who want to use mosque services',
                icon: Icons.person,
                userType: UserType.regular,
              ),
              const SizedBox(height: 16),
              _buildUserTypeOption(
                title: 'Organization',
                subtitle: 'For organizations or mosque administrators',
                icon: Icons.business,
                userType: UserType.organization,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required UserType userType,
  }) {
    return InkWell(
      onTap: () => _selectUserType(userType),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(AppConfig.primaryTealColor).withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Color(AppConfig.primaryTealColor),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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

  Future<void> _selectUserType(UserType userType) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Navigator.of(context).pop(); // Close dialog

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    bool success = await authProvider.setUserType(userType);

    Navigator.of(context).pop(); // Close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Account type successfully set as ${userType == UserType.regular ? 'Regular User' : 'Organization'}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to set account type: ${authProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
      // Show dialog again if failed
      _showUserTypeSelectionDialog();
    }
  }

  void _showContentFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContentFilterBottomSheet(),
    );
  }
}

class ContentFilterBottomSheet extends StatefulWidget {
  @override
  _ContentFilterBottomSheetState createState() =>
      _ContentFilterBottomSheetState();
}

class _ContentFilterBottomSheetState extends State<ContentFilterBottomSheet> {
  String selectedFilter = 'All Mosques';

  final List<Map<String, dynamic>> filterOptions = [
    {
      'title': 'All Mosques',
      'subtitle': 'View all mosque locations',
      'icon': Icons.mosque,
      'count': 25,
    },
    {
      'title': 'All Events',
      'subtitle': 'Browse upcoming events',
      'icon': Icons.event,
      'count': 12,
    },
    {
      'title': 'All Announcements',
      'subtitle': 'Latest community updates',
      'icon': Icons.campaign,
      'count': 8,
    },
    {
      'title': 'Spiritual Events',
      'subtitle': 'Prayer sessions & religious gatherings',
      'icon': Icons.auto_awesome,
      'count': 5,
    },
    {
      'title': 'Youth Events',
      'subtitle': 'Activities for young community members',
      'icon': Icons.groups,
      'count': 3,
    },
    {
      'title': 'Educational Programs',
      'subtitle': 'Learning sessions & workshops',
      'icon': Icons.school,
      'count': 7,
    },
    {
      'title': 'Community Service',
      'subtitle': 'Volunteer opportunities & charity work',
      'icon': Icons.volunteer_activism,
      'count': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.65, // 25% of screen height
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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter options
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                final option = filterOptions[index];
                final isSelected = selectedFilter == option['title'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = option['title'];
                    });

                    // Close bottom sheet after selection
                    Navigator.pop(context);

                    // Show snackbar with selected filter
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filter applied: ${option['title']}'),
                        backgroundColor: Color(AppConfig.primaryTealColor),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(AppConfig.primaryTealColor).withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Color(AppConfig.primaryTealColor)
                            : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(AppConfig.primaryTealColor)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            option['icon'],
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Color(AppConfig.primaryTealColor)
                                      : Colors.black87,
                                ),
                              ),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(AppConfig.primaryTealColor)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${option['count']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
