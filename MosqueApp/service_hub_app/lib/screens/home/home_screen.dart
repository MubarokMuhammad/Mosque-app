import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' show Location, locationFromAddress;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_config.dart';
import '../../widgets/event_detail_bottom_sheet.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
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
  String _selectedRadius = '10 miles';
  String _selectedContentFilter = 'All Mosques';
  String _currentLocationText = 'Detecting location...';
  bool _isLoadingLocation = false;
  bool _hasShownLocationPermission = false;
  Map<String, bool> _subscriptionStatus = {};
  // Cache for geocoded addresses of public mosques to avoid repeated lookups
  final Map<String, Location> _publicMosqueGeocodeCache = {};

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatuses();
    // Show location permission popup and initialize location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowLocationPermissionDialog();
      // Load initial data after the first frame is built
      _loadInitialData();
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
    // Show dialog whenever location service or permission is not active
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final hasPermission =
        await LocationService.instance.hasLocationPermission();

    if (!serviceEnabled || !hasPermission) {
      _showLocationPermissionDialog();
    } else {
      _initializeLocation();
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(AppConfig.primaryTealColor),
                        Color(AppConfig.primaryTealColor).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Enable Location',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Find nearby mosques and get personalized prayer times for your location.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Features
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureItem(
                              Icons.mosque_rounded,
                              'Nearby\nMosques',
                            ),
                          ),
                          Expanded(
                            child: _buildFeatureItem(
                              Icons.schedule_rounded,
                              'Prayer\nTimes',
                            ),
                          ),
                          Expanded(
                            child: _buildFeatureItem(
                              Icons.event_rounded,
                              'Local\nEvents',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _currentLocationText = 'Location disabled';
                                });
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _initializeLocation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color(AppConfig.primaryTealColor),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Enable Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
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
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: Color(AppConfig.primaryTealColor),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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

  // Forward geocode a textual address and cache the result to reduce network calls
  Future<Location?> _geocodeAddressCached(String address) async {
    try {
      final key = address.trim().toLowerCase();
      if (_publicMosqueGeocodeCache.containsKey(key)) {
        return _publicMosqueGeocodeCache[key];
      }
      final results = await locationFromAddress(address);
      if (results.isNotEmpty) {
        final loc = results.first;
        _publicMosqueGeocodeCache[key] = loc;
        return loc;
      }
      return null;
    } catch (e) {
      debugPrint('Geocoding failed for "$address": $e');
      return null;
    }
  }

  Future<void> _checkNewSocialUser() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print(
        'Checking new social user: ${authProvider.isNewSocialUser}'); // Debug log

    // All new users are now regular users by default
    // Organization status can be requested through Settings
    if (authProvider.isNewSocialUser) {
      // Clear the new social user flag without showing dialog
      authProvider.clearNewSocialUserFlag();
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

      // Check organization verification status
      await _checkOrganizationVerificationStatus();

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

  Future<void> _checkOrganizationVerificationStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.userModel != null) {
        print(
            'DEBUG: Before refresh - userType: ${authProvider.userModel?.userType}, isOrganization: ${authProvider.isOrganization}');

        // First refresh user data from Firestore to get latest userType
        await authProvider.refreshUserData();

        print(
            'DEBUG: After refresh - userType: ${authProvider.userModel?.userType}, isOrganization: ${authProvider.isOrganization}');

        final verificationData =
            await FirebaseService.getOrganizationVerificationStatus(
                authProvider.userModel!.id);

        String? status = verificationData != null
            ? verificationData['verifyStatus']?.toString()
            : null;
        final normalizedStatus = status?.toLowerCase();
        print('DEBUG: Verification status: ${status ?? 'null'}');

        // Source of truth: if userType in users doc is already organization, don't override
        if (authProvider.isOrganization) {
          print(
              'DEBUG: User already organization in users doc; skipping overrides.');
        } else {
          // Only upgrade to organization when verification status accepted; do not force false
          if (normalizedStatus == 'accepted') {
            await authProvider.setIsOrganization(true);
            print(
                'DEBUG: Upgraded user to organization based on verification.');
          } else {
            print(
                'DEBUG: Verification not accepted or missing; keeping current userType.');
          }
        }

        print(
            'DEBUG: Final - userType: ${authProvider.userModel?.userType}, isOrganization: ${authProvider.isOrganization}');

        // Force rebuild of the UI to ensure bottom navigation updates
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error checking organization verification status: $e');
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
          onChanged: (value) {
            setState(() {
              // Trigger rebuild when search text changes
            });
          },
          decoration: InputDecoration(
            hintText: 'Search for mosques',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500]),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        // Trigger rebuild when search is cleared
                      });
                    },
                  )
                : null,
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
                              _selectedRadius = '10 miles';
                            });
                            setState(() {
                              _selectedCountry = 'Country';
                              _selectedState = 'State/Province';
                              _selectedCity = 'City';
                              _selectedEvent = 'Event';
                              _selectedRadius = '10 miles';
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
                        // City Filter (Highest Priority)
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
                            // Major US Cities
                            'New York City',
                            'Los Angeles',
                            'Chicago',
                            'Houston',
                            'Phoenix',
                            'Philadelphia',
                            'San Antonio',
                            'San Diego',
                            'Dallas',
                            'San Jose',
                            'Austin',
                            'Jacksonville',
                            'Fort Worth',
                            'Columbus',
                            'Charlotte',
                            'San Francisco',
                            'Indianapolis',
                            'Seattle',
                            'Denver',
                            'Washington DC',
                            'Boston',
                            'El Paso',
                            'Nashville',
                            'Detroit',
                            'Oklahoma City',
                            'Portland',
                            'Las Vegas',
                            'Memphis',
                            'Louisville',
                            'Baltimore',
                            'Milwaukee',
                            'Albuquerque',
                            'Tucson',
                            'Fresno',
                            'Sacramento',
                            'Kansas City',
                            'Mesa',
                            'Atlanta',
                            'Colorado Springs',
                            'Raleigh',
                            'Omaha',
                            'Miami',
                            'Long Beach',
                            'Virginia Beach',
                            'Oakland',
                            'Minneapolis',
                            'Tulsa',
                            'Tampa',
                            'Arlington',
                            'New Orleans',
                            // Major Canadian Cities
                            'Toronto',
                            'Montreal',
                            'Vancouver',
                            'Calgary',
                            'Edmonton',
                            'Ottawa',
                            'Winnipeg',
                            'Quebec City',
                            'Hamilton',
                            'Kitchener',
                            'London',
                            'Victoria',
                            'Halifax',
                            'Oshawa',
                            'Windsor',
                            'Saskatoon',
                            'St. Catharines',
                            'Regina',
                            'Sherbrooke',
                            'Kelowna',
                            'Barrie',
                            'Abbotsford',
                            'Kingston',
                            'Sudbury',
                            'Saguenay'
                          ],
                          (value) {
                            setModalState(() => _selectedCity = value!);
                            setState(() => _selectedCity = value!);
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
                            // US States (alphabetical)
                            'Alabama',
                            'Alaska',
                            'Arizona',
                            'Arkansas',
                            'California',
                            'Colorado',
                            'Connecticut',
                            'Delaware',
                            'Florida',
                            'Georgia',
                            'Hawaii',
                            'Idaho',
                            'Illinois',
                            'Indiana',
                            'Iowa',
                            'Kansas',
                            'Kentucky',
                            'Louisiana',
                            'Maine',
                            'Maryland',
                            'Massachusetts',
                            'Michigan',
                            'Minnesota',
                            'Mississippi',
                            'Missouri',
                            'Montana',
                            'Nebraska',
                            'Nevada',
                            'New Hampshire',
                            'New Jersey',
                            'New Mexico',
                            'New York',
                            'North Carolina',
                            'North Dakota',
                            'Ohio',
                            'Oklahoma',
                            'Oregon',
                            'Pennsylvania',
                            'Rhode Island',
                            'South Carolina',
                            'South Dakota',
                            'Tennessee',
                            'Texas',
                            'Utah',
                            'Vermont',
                            'Virginia',
                            'Washington',
                            'West Virginia',
                            'Wisconsin',
                            'Wyoming',
                            'Washington DC',
                            // Canadian Provinces and Territories
                            'Alberta',
                            'British Columbia',
                            'Manitoba',
                            'New Brunswick',
                            'Newfoundland and Labrador',
                            'Northwest Territories',
                            'Nova Scotia',
                            'Nunavut',
                            'Ontario',
                            'Prince Edward Island',
                            'Quebec',
                            'Saskatchewan',
                            'Yukon'
                          ],
                          (value) {
                            setModalState(() => _selectedState = value!);
                            setState(() => _selectedState = value!);
                          },
                        ),

                        const SizedBox(height: 20),

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

                        // Search Radius Filter
                        const Text(
                          'Search Radius',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBottomSheetDropdown(
                          _selectedRadius,
                          [
                            '5 miles',
                            '10 miles',
                            '15 miles',
                            '20 miles',
                            '25 miles',
                            '30 miles',
                            '50 miles'
                          ],
                          (value) {
                            setModalState(() => _selectedRadius = value!);
                            setState(() => _selectedRadius = value!);
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mosqueapp_events')
                .orderBy('createdAt', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error loading events',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No events available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              final events = snapshot.data!.docs
                  .where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == 'published';
                  })
                  .take(5)
                  .toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final eventData =
                      events[index].data() as Map<String, dynamic>;
                  final eventTitle = eventData['title'] ?? 'Untitled Event';
                  
                  // Handle Timestamp to String conversion for date
                  String eventDate = 'Untitled date Event';
                  final dateData = eventData['date'];
                  if (dateData is Timestamp) {
                    final dateTime = dateData.toDate();
                    final months = [
                      'January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'
                    ];
                    final days = [
                      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
                    ];
                    
                    final dayName = days[dateTime.weekday % 7];
                    final day = dateTime.day;
                    final month = months[dateTime.month - 1];
                    final year = dateTime.year;
                    
                    // Add time if available
                    final timeData = eventData['time'] as Map<String, dynamic>?;
                    if (timeData != null) {
                      final hour = timeData['hour'] ?? 0;
                      final minute = timeData['minute'] ?? 0;
                      final formattedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                      eventDate = '$dayName, $day $month $year at $formattedTime';
                    } else {
                      eventDate = '$dayName, $day $month $year';
                    }
                  } else if (dateData is String) {
                    eventDate = dateData;
                  }
                  
                  final organizationName = eventData['organization']
                          ?['organizationName'] ??
                      'Unknown Mosque';

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < events.length - 1 ? 16 : 0,
                    ),
                    child: _buildTopEventCard(
                        eventTitle, organizationName, eventDate, events[index].id, eventData),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTopEventCard(String title, String mosque, String date, String eventId, Map<String, dynamic> eventData) {
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
          date: date,
          description: getEventDescription(title),
          imageAsset: getImageAsset(title),
          likes: 0,
          attending: 0,
          eventId: eventId,
          eventData: eventData,
          organization: eventData['organization'] as Map<String, dynamic>?,
          organizationName: mosque,
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
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('mosqueapp_organizations')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading mosques: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No mosques found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            // Get current location
            final currentPosition = LocationService.instance.currentPosition;
            if (currentPosition == null) {
              return const Center(
                child: Text(
                  'Location not available. Please enable location services.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            // Apply Content Filter via real-time Firestore (events/announcements)
            if (_selectedContentFilter != 'All Mosques') {
              // Announcements mode
              if (_selectedContentFilter == 'All Announcements') {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('mosqueapp_announcements')
                      .where('status', isEqualTo: 'published')
                      .snapshots(),
                  builder: (context, annSnapshot) {
                    if (annSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (annSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading announcements: ${annSnapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final annDocs = annSnapshot.data?.docs ?? [];
                    final Set<String> annOrgIds = {};
                    final Set<String> annAddresses = {};

                    for (final a in annDocs) {
                      final aData = a.data() as Map<String, dynamic>;
                      final orgId = (aData['organizationId'] ?? '').toString();
                      if (orgId.isNotEmpty) annOrgIds.add(orgId);
                      final addr = (aData['organizationAddress'] ?? '')
                          .toString()
                          .toLowerCase()
                          .trim();
                      if (addr.isNotEmpty) annAddresses.add(addr);
                    }

                    final filteredMosques = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['latitude'] == null ||
                          data['longitude'] == null) {
                        return false;
                      }

                      final distance =
                          LocationService.instance.calculateDistance(
                        currentPosition.latitude,
                        currentPosition.longitude,
                        data['latitude'].toDouble(),
                        data['longitude'].toDouble(),
                      );
                      if (distance > 30.0) return false;

                      if (_searchController.text.isNotEmpty) {
                        final searchTerm = _searchController.text.toLowerCase();
                        final mosqueName =
                            (data['name'] ?? data['organizationName'] ?? '')
                                .toString()
                                .toLowerCase();
                        final mosqueAddress =
                            (data['address'] ?? '').toString().toLowerCase();
                        final mosqueDescription = (data['description'] ??
                                data['organizationDescription'] ??
                                '')
                            .toString()
                            .toLowerCase();
                        if (!mosqueName.contains(searchTerm) &&
                            !mosqueAddress.contains(searchTerm) &&
                            !mosqueDescription.contains(searchTerm)) {
                          return false;
                        }
                      }

                      final addressLower =
                          (data['address'] ?? '').toString().toLowerCase();
                      if (_selectedCountry != 'Country' &&
                          !addressLower
                              .contains(_selectedCountry.toLowerCase())) {
                        return false;
                      }
                      if (_selectedState != 'State/Province' &&
                          !addressLower
                              .contains(_selectedState.toLowerCase())) {
                        return false;
                      }
                      if (_selectedCity != 'City' &&
                          !addressLower.contains(_selectedCity.toLowerCase())) {
                        return false;
                      }

                      final orgIdDoc = doc.id;
                      final orgAddrLower = addressLower.trim();
                      final matchesAnn = annOrgIds.contains(orgIdDoc) ||
                          (orgAddrLower.isNotEmpty &&
                              annAddresses.contains(orgAddrLower));
                      if (!matchesAnn) return false;
                      return true;
                    }).toList();

                    if (filteredMosques.isEmpty) {
                      return Center(
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? 'No mosques found matching "${_searchController.text}"'
                              : 'No mosques found within 30km radius',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...filteredMosques.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final mosqueName = data['name'] ??
                              data['organizationName'] ??
                              'Unknown Mosque';
                          final mosqueAddress =
                              data['address'] ?? 'Address not available';
                          final mosqueDesc = data['description'] ??
                              data['organizationDescription'] ??
                              'Unknown Mosque';
                          final distance =
                              LocationService.instance.calculateDistance(
                            currentPosition.latitude,
                            currentPosition.longitude,
                            data['latitude'].toDouble(),
                            data['longitude'].toDouble(),
                          );
                          return _buildMosqueCard(
                              mosqueName, mosqueAddress, mosqueDesc, false,
                              distance: distance);
                        }).toList(),
                        // Public (Unregistered) mosques within 10km, greyed out with label
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('mosqueapp_subscribe_mosques')
                              .where('isActive', isEqualTo: true)
                              .limit(200)
                              .get(),
                          builder: (context, subSnapshot) {
                            if (subSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            if (subSnapshot.hasError) {
                              return const SizedBox.shrink();
                            }

                            final subDocs = subSnapshot.data?.docs ?? [];
                            if (subDocs.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            // Build a set of registered mosque keys to exclude (name+address)
                            final Set<String> registeredKeys = filteredMosques
                                .map((d) {
                                  final dd = d.data() as Map<String, dynamic>;
                                  final name = (dd['name'] ??
                                          dd['organizationName'] ??
                                          '')
                                      .toString()
                                      .trim()
                                      .toLowerCase();
                                  final addr = (dd['address'] ?? '')
                                      .toString()
                                      .trim()
                                      .toLowerCase();
                                  return '$name|$addr';
                                })
                                .toSet();

                            // Deduplicate public mosques by name+address
                            final Map<String, Map<String, dynamic>> publicMap = {};
                            for (final s in subDocs) {
                              final sd = s.data() as Map<String, dynamic>;
                              final name = (sd['mosqueName'] ?? '')
                                  .toString()
                                  .trim();
                              final addr = (sd['mosqueAddress'] ?? '')
                                  .toString()
                                  .trim();
                              if (name.isEmpty || addr.isEmpty) continue;
                              final key = '${name.toLowerCase()}|${addr.toLowerCase()}';
                              if (registeredKeys.contains(key)) continue; // exclude registered
                              // Keep the first occurrence; prefer ones with description
                              if (!publicMap.containsKey(key) ||
                                  (sd['mosqueDescription'] ?? '') != '') {
                                publicMap[key] = sd;
                              }
                            }

                            if (publicMap.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            // Compute distance via cached geocoding and filter within 10km
                            final List<Widget> publicCards = [];
                            for (final entry in publicMap.entries) {
                              final sd = entry.value;
                              final name = sd['mosqueName']?.toString() ?? 'Unknown Mosque';
                              final addr = sd['mosqueAddress']?.toString() ?? 'Address not available';
                              final desc = sd['mosqueDescription']?.toString() ?? 'General Mosque';
                              publicCards.add(FutureBuilder<Location?>(
                                future: _geocodeAddressCached(addr),
                                builder: (context, geoSnapshot) {
                                  if (geoSnapshot.connectionState == ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  }
                                  final loc = geoSnapshot.data;
                                  if (loc == null) {
                                    // Skip if unable to geocode (no coordinates)
                                    return const SizedBox.shrink();
                                  }
                                  final dist = LocationService.instance.calculateDistance(
                                    currentPosition.latitude,
                                    currentPosition.longitude,
                                    loc.latitude,
                                    loc.longitude,
                                  );
                                  if (dist > 30.0) {
                                    return const SizedBox.shrink();
                                  }
                                  return _buildMosqueCard(
                                    name,
                                    addr,
                                    desc,
                                    false,
                                    distance: dist,
                                    unregistered: true,
                                  );
                                },
                              ));
                            }

                            // If there are no nearby public mosques, hide section
                            if (publicCards.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(children: publicCards);
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                );
              }

              // Events mode
              List<String>? eventCategoryKeys;
              bool matchYouthText = false;
              switch (_selectedContentFilter) {
                case 'All Events':
                  eventCategoryKeys = null; // no category filter
                  break;
                case 'Spiritual Events':
                  eventCategoryKeys = ['prayer', 'religious'];
                  break;
                case 'Youth Events':
                  eventCategoryKeys = null;
                  matchYouthText = true;
                  break;
                case 'Educational Programs':
                  eventCategoryKeys = ['education'];
                  break;
                case 'Community Service':
                  eventCategoryKeys = ['charity', 'community'];
                  break;
                default:
                  eventCategoryKeys = null;
              }

              final eventsCollection =
                  FirebaseFirestore.instance.collection('mosqueapp_events');
              final eventsStream = (eventCategoryKeys == null)
                  ? eventsCollection
                      .where('status', isEqualTo: 'published')
                      .snapshots()
                  : eventsCollection
                      .where('category', whereIn: eventCategoryKeys)
                      .snapshots();

              return StreamBuilder<QuerySnapshot>(
                stream: eventsStream,
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (eventSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading events: ${eventSnapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  var eventDocs = eventSnapshot.data?.docs ?? [];

                  // Optionally filter by 'published' if category-only stream is used
                  eventDocs = eventDocs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? '').toString();
                    return status.isEmpty || status == 'published';
                  }).toList();

                  if (matchYouthText) {
                    eventDocs = eventDocs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final t = (data['title'] ?? '').toString().toLowerCase();
                      final desc =
                          (data['description'] ?? '').toString().toLowerCase();
                      return t.contains('youth') || desc.contains('youth');
                    }).toList();
                  }

                  // Build sets to link organizations
                  final Set<String> eventOrgIds = {};
                  final Set<String> eventAddresses = {};
                  final Set<String> eventCoords = {};

                  for (final e in eventDocs) {
                    final eData = e.data() as Map<String, dynamic>;
                    final orgId = (eData['organizationId'] ??
                            eData['organization']?['id'] ??
                            '')
                        .toString();
                    if (orgId.isNotEmpty) eventOrgIds.add(orgId);
                    final addr = (eData['organization']?['address'] ??
                            eData['location'] ??
                            '')
                        .toString()
                        .toLowerCase()
                        .trim();
                    if (addr.isNotEmpty) eventAddresses.add(addr);
                    final elat = (eData['organization']?['latitude'] as num?)
                        ?.toDouble();
                    final elng = (eData['organization']?['longitude'] as num?)
                        ?.toDouble();
                    if (elat != null && elng != null) {
                      eventCoords.add(
                          '${elat.toStringAsFixed(5)}_${elng.toStringAsFixed(5)}');
                    }
                  }

                  final filteredMosques = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['latitude'] == null || data['longitude'] == null) {
                      return false;
                    }

                    final distance = LocationService.instance.calculateDistance(
                      currentPosition.latitude,
                      currentPosition.longitude,
                      data['latitude'].toDouble(),
                      data['longitude'].toDouble(),
                    );
                    if (distance > 30.0) return false;

                    if (_searchController.text.isNotEmpty) {
                      final searchTerm = _searchController.text.toLowerCase();
                      final mosqueName =
                          (data['name'] ?? data['organizationName'] ?? '')
                              .toString()
                              .toLowerCase();
                      final mosqueAddress =
                          (data['address'] ?? '').toString().toLowerCase();
                      final mosqueDescription = (data['description'] ??
                              data['organizationDescription'] ??
                              '')
                          .toString()
                          .toLowerCase();
                      if (!mosqueName.contains(searchTerm) &&
                          !mosqueAddress.contains(searchTerm) &&
                          !mosqueDescription.contains(searchTerm)) {
                        return false;
                      }
                    }

                    final addressLower =
                        (data['address'] ?? '').toString().toLowerCase();
                    if (_selectedCountry != 'Country' &&
                        !addressLower
                            .contains(_selectedCountry.toLowerCase())) {
                      return false;
                    }
                    if (_selectedState != 'State/Province' &&
                        !addressLower.contains(_selectedState.toLowerCase())) {
                      return false;
                    }
                    if (_selectedCity != 'City' &&
                        !addressLower.contains(_selectedCity.toLowerCase())) {
                      return false;
                    }

                    final orgIdDoc = doc.id;
                    final orgAddrLower = addressLower.trim();
                    final oLat = (data['latitude'] as num?)?.toDouble();
                    final oLng = (data['longitude'] as num?)?.toDouble();
                    final orgCoordKey = (oLat != null && oLng != null)
                        ? '${oLat.toStringAsFixed(5)}_${oLng.toStringAsFixed(5)}'
                        : '';

                    final matchesEvent = (eventOrgIds.contains(orgIdDoc)) ||
                        (orgCoordKey.isNotEmpty &&
                            eventCoords.contains(orgCoordKey)) ||
                        (orgAddrLower.isNotEmpty &&
                            eventAddresses.contains(orgAddrLower));
                    if (!matchesEvent) return false;
                    return true;
                  }).toList();

                  if (filteredMosques.isEmpty) {
                    return Center(
                      child: Text(
                        _searchController.text.isNotEmpty
                            ? 'No mosques found matching "${_searchController.text}"'
                            : 'No mosques found within 30km radius',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ...filteredMosques.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final mosqueName = data['name'] ??
                            data['organizationName'] ??
                            'Unknown Mosque';
                        final mosqueAddress =
                            data['address'] ?? 'Address not available';
                        final mosqueDesc = data['description'] ??
                            data['organizationDescription'] ??
                            'Unknown Mosque';

                        final distance =
                            LocationService.instance.calculateDistance(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          data['latitude'].toDouble(),
                          data['longitude'].toDouble(),
                        );
                        return _buildMosqueCard(
                            mosqueName, mosqueAddress, mosqueDesc, false,
                            distance: distance);
                      }).toList(),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              );
            }

            // If Event Type dropdown is selected, filter organizations by specific events
            if (_selectedEvent != 'Event') {
              List<String> eventCategoryKeys = [];
              switch (_selectedEvent) {
                case 'Jumah Prayer':
                case 'Tarawih':
                case 'Eid Prayer':
                  eventCategoryKeys = ['prayer', 'religious'];
                  break;
                default:
                  eventCategoryKeys = [];
              }

              if (eventCategoryKeys.isEmpty) {
                return const SizedBox.shrink();
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mosqueapp_events')
                    .where('category', whereIn: eventCategoryKeys)
                    .snapshots(),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (eventSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading events: ${eventSnapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final eventDocs = eventSnapshot.data?.docs ?? [];

                  final Set<String> eventOrgIds = {};
                  final Set<String> eventAddresses = {};
                  final Set<String> eventCoords = {};

                  for (final e in eventDocs) {
                    final eData = e.data() as Map<String, dynamic>;
                    final orgId = (eData['organizationId'] ??
                            eData['organization']?['id'] ??
                            '')
                        .toString();
                    if (orgId.isNotEmpty) eventOrgIds.add(orgId);
                    final addr = (eData['organization']?['address'] ??
                            eData['location'] ??
                            '')
                        .toString()
                        .toLowerCase()
                        .trim();
                    if (addr.isNotEmpty) eventAddresses.add(addr);
                    final elat = (eData['organization']?['latitude'] as num?)
                        ?.toDouble();
                    final elng = (eData['organization']?['longitude'] as num?)
                        ?.toDouble();
                    if (elat != null && elng != null) {
                      eventCoords.add(
                          '${elat.toStringAsFixed(5)}_${elng.toStringAsFixed(5)}');
                    }
                  }

                  final filteredMosques = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['latitude'] == null || data['longitude'] == null) {
                      return false;
                    }

                    final distance = LocationService.instance.calculateDistance(
                      currentPosition.latitude,
                      currentPosition.longitude,
                      data['latitude'].toDouble(),
                      data['longitude'].toDouble(),
                    );
                    if (distance > 30.0) return false;

                    if (_searchController.text.isNotEmpty) {
                      final searchTerm = _searchController.text.toLowerCase();
                      final mosqueName =
                          (data['name'] ?? data['organizationName'] ?? '')
                              .toString()
                              .toLowerCase();
                      final mosqueAddress =
                          (data['address'] ?? '').toString().toLowerCase();
                      final mosqueDescription = (data['description'] ??
                              data['organizationDescription'] ??
                              '')
                          .toString()
                          .toLowerCase();
                      if (!mosqueName.contains(searchTerm) &&
                          !mosqueAddress.contains(searchTerm) &&
                          !mosqueDescription.contains(searchTerm)) {
                        return false;
                      }
                    }

                    final addressLower =
                        (data['address'] ?? '').toString().toLowerCase();
                    if (_selectedCountry != 'Country' &&
                        !addressLower
                            .contains(_selectedCountry.toLowerCase())) {
                      return false;
                    }
                    if (_selectedState != 'State/Province' &&
                        !addressLower.contains(_selectedState.toLowerCase())) {
                      return false;
                    }
                    if (_selectedCity != 'City' &&
                        !addressLower.contains(_selectedCity.toLowerCase())) {
                      return false;
                    }

                    final orgIdDoc = doc.id;
                    final orgAddrLower = addressLower.trim();
                    final oLat = (data['latitude'] as num?)?.toDouble();
                    final oLng = (data['longitude'] as num?)?.toDouble();
                    final orgCoordKey = (oLat != null && oLng != null)
                        ? '${oLat.toStringAsFixed(5)}_${oLng.toStringAsFixed(5)}'
                        : '';

                    final matchesEvent = (eventOrgIds.contains(orgIdDoc)) ||
                        (orgCoordKey.isNotEmpty &&
                            eventCoords.contains(orgCoordKey)) ||
                        (orgAddrLower.isNotEmpty &&
                            eventAddresses.contains(orgAddrLower));
                    if (!matchesEvent) return false;
                    return true;
                  }).toList();

                  if (filteredMosques.isEmpty) {
                    return Center(
                      child: Text(
                        _searchController.text.isNotEmpty
                            ? 'No mosques found matching "${_searchController.text}"'
                            : 'No mosques found within 30km radius',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ...filteredMosques.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final mosqueName = data['name'] ??
                            data['organizationName'] ??
                            'Unknown Mosque';
                        final mosqueAddress =
                            data['address'] ?? 'Address not available';
                        final mosqueDesc = data['description'] ??
                            data['organizationDescription'] ??
                            'Unknown Mosque';
                        final distance =
                            LocationService.instance.calculateDistance(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          data['latitude'].toDouble(),
                          data['longitude'].toDouble(),
                        );
                        return _buildMosqueCard(
                            mosqueName, mosqueAddress, mosqueDesc, false,
                            distance: distance);
                      }).toList(),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              );
            }

            // Default: filter mosques within 30km radius and by search term + location filters
            final nearbyMosques = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              // Check if latitude and longitude exist
              if (data['latitude'] == null || data['longitude'] == null) {
                return false;
              }

              final distance = LocationService.instance.calculateDistance(
                currentPosition.latitude,
                currentPosition.longitude,
                data['latitude'].toDouble(),
                data['longitude'].toDouble(),
              );

              // Filter by distance (30km radius)
              if (distance > 30.0) {
                return false;
              }

              // Filter by search term
              if (_searchController.text.isNotEmpty) {
                final searchTerm = _searchController.text.toLowerCase();
                final mosqueName =
                    (data['name'] ?? data['organizationName'] ?? '')
                        .toString()
                        .toLowerCase();
                final mosqueAddress =
                    (data['address'] ?? '').toString().toLowerCase();
                final mosqueDescription = (data['description'] ??
                        data['organizationDescription'] ??
                        '')
                    .toString()
                    .toLowerCase();

                if (!mosqueName.contains(searchTerm) &&
                    !mosqueAddress.contains(searchTerm) &&
                    !mosqueDescription.contains(searchTerm)) {
                  return false;
                }
              }

              // Location filters
              final addressLower =
                  (data['address'] ?? '').toString().toLowerCase();

              if (_selectedCountry != 'Country' &&
                  !addressLower.contains(_selectedCountry.toLowerCase())) {
                return false;
              }

              if (_selectedState != 'State/Province' &&
                  !addressLower.contains(_selectedState.toLowerCase())) {
                return false;
              }

              if (_selectedCity != 'City' &&
                  !addressLower.contains(_selectedCity.toLowerCase())) {
                return false;
              }

              return true;
            }).toList();

            if (nearbyMosques.isEmpty) {
              return Center(
                child: Text(
                  _searchController.text.isNotEmpty
                      ? 'No mosques found matching "${_searchController.text}"'
                      : 'No mosques found within 30km radius',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: [
                ...nearbyMosques.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final mosqueName = data['name'] ??
                      data['organizationName'] ??
                      'Unknown Mosque';
                  final mosqueAddress =
                      data['address'] ?? 'Address not available';
                  final mosqueDesc = data['description'] ??
                      data['organizationDescription'] ??
                      'Unknown Mosque';
                  // Calculate distance for this mosque
                  final distance = LocationService.instance.calculateDistance(
                    currentPosition.latitude,
                    currentPosition.longitude,
                    data['latitude'].toDouble(),
                    data['longitude'].toDouble(),
                  );

                  return _buildMosqueCard(
                      mosqueName, mosqueAddress, mosqueDesc, false,
                      distance: distance);
                }).toList(),
                // Tambahkan masjid umum (tidak terdaftar) dalam radius 30km
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('mosqueapp_subscribe_mosques')
                      .where('isActive', isEqualTo: true)
                      .limit(200)
                      .get(),
                  builder: (context, subSnapshot) {
                    if (subSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (subSnapshot.hasError) {
                      return const SizedBox.shrink();
                    }

                    final subDocs = subSnapshot.data?.docs ?? [];
                    if (subDocs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Buat set untuk menghindari duplikasi (exclude yang sudah terdaftar)
                    final Set<String> registeredKeys = nearbyMosques
                        .map((d) {
                          final dd = d.data() as Map<String, dynamic>;
                          final name = (dd['name'] ?? dd['organizationName'] ?? '')
                              .toString()
                              .trim()
                              .toLowerCase();
                          final addr = (dd['address'] ?? '')
                              .toString()
                              .trim()
                              .toLowerCase();
                          return '$name|$addr';
                        })
                        .toSet();

                    // Deduplikasi masjid umum berdasarkan name+address
                    final Map<String, Map<String, dynamic>> publicMap = {};
                    for (final s in subDocs) {
                      final sd = s.data() as Map<String, dynamic>;
                      final name = (sd['mosqueName'] ?? '')
                          .toString()
                          .trim();
                      final addr = (sd['mosqueAddress'] ?? '')
                          .toString()
                          .trim();
                      if (name.isEmpty || addr.isEmpty) continue;
                      final key = '${name.toLowerCase()}|${addr.toLowerCase()}';
                      if (registeredKeys.contains(key)) continue; // exclude yg sudah terdaftar
                      if (!publicMap.containsKey(key) ||
                          (sd['mosqueDescription'] ?? '') != '') {
                        publicMap[key] = sd;
                      }
                    }

                    if (publicMap.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Hitung jarak via geocoding (cache) dan filter radius 30km
                    final List<Widget> publicCards = [];
                    for (final entry in publicMap.entries) {
                      final sd = entry.value;
                      final name = sd['mosqueName']?.toString() ?? 'Unknown Mosque';
                      final addr = sd['mosqueAddress']?.toString() ?? 'Address not available';
                      final desc = sd['mosqueDescription']?.toString() ?? 'General Mosque';

                      publicCards.add(FutureBuilder<Location?>(
                        future: _geocodeAddressCached(addr),
                        builder: (context, geoSnapshot) {
                          if (geoSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }
                          final loc = geoSnapshot.data;
                          if (loc == null) {
                            return const SizedBox.shrink();
                          }
                          final dist = LocationService.instance.calculateDistance(
                            currentPosition.latitude,
                            currentPosition.longitude,
                            loc.latitude,
                            loc.longitude,
                          );
                          if (dist > 30.0) {
                            return const SizedBox.shrink();
                          }
                          return _buildMosqueCard(
                            name,
                            addr,
                            desc,
                            false,
                            distance: dist,
                            unregistered: true,
                          );
                        },
                      ));
                    }

                    if (publicCards.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(children: publicCards);
                  },
                ),
                const SizedBox(
                    height: 100), // Extra space for bottom navigation
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMosqueCard(
      String name, String address, String description, bool hasNotification,
      {double? distance, bool unregistered = false}) {
    bool isSubscribed = _subscriptionStatus[name] ?? false;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MosqueDetailScreen(
              mosqueName: name,
              mosqueAddress: address,
              mosqueDescription: description,
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
          color: unregistered ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(unregistered ? 0.05 : 0.1),
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
                color: unregistered
                    ? Colors.grey[400]
                    : Color(AppConfig.primaryTealColor),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                unregistered ? Colors.grey[700] : Colors.black87,
                          ),
                        ),
                      ),
                      if (!unregistered && isSubscribed)
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
                      if (unregistered)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Belum Terdaftar',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      color: unregistered ? Colors.grey[600] : Colors.grey[600],
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
                        distance != null
                            ? '${distance.toStringAsFixed(1)} km away'
                            : 'Distance unknown',
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
        authProvider.ensureUserDocListening();
        print(
            'DEBUG: Building bottom nav - isOrganization: ${authProvider.isOrganization}, userType: ${authProvider.userModel?.userType}');

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

  void _showContentFilterBottomSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContentFilterBottomSheet(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedContentFilter = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filter applied: $result'),
          backgroundColor: Color(AppConfig.primaryTealColor),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
    },
    {
      'title': 'All Events',
      'subtitle': 'Browse upcoming events',
      'icon': Icons.event,
    },
    {
      'title': 'All Announcements',
      'subtitle': 'Latest community updates',
      'icon': Icons.campaign,
    },
    {
      'title': 'Spiritual Events',
      'subtitle': 'Prayer sessions & religious gatherings',
      'icon': Icons.auto_awesome,
    },
    {
      'title': 'Youth Events',
      'subtitle': 'Activities for young community members',
      'icon': Icons.groups,
    },
    {
      'title': 'Educational Programs',
      'subtitle': 'Learning sessions & workshops',
      'icon': Icons.school,
    },
    {
      'title': 'Community Service',
      'subtitle': 'Volunteer opportunities & charity work',
      'icon': Icons.volunteer_activism,
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

                    // Close bottom sheet and return selection
                    Navigator.pop(context, option['title']);
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
                        const SizedBox.shrink(),
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
