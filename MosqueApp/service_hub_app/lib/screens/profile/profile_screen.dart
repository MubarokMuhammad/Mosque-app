import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../config/app_config.dart';
import '../../services/firebase_service.dart';
import '../../services/favorites_service.dart';
import '../../services/bookmarks_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'liked_mosques_screen.dart';
import '../announcements/bookmarked_events_screen.dart';
import 'subscribed_mosques_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/location_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _organizationNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  // Tambahan controller untuk phone dan address serta state lokasi
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  double? _currentLatitude;
  double? _currentLongitude;
  bool _isLoadingAddress = false;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _websiteController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (authProvider.userModel != null) {
      await orgProvider.loadMyOrganizations(authProvider.userModel!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(AppConfig.primaryTealColor),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userModel == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileInfo(authProvider),
                _buildMyOrganizations(),
                const SizedBox(height: 20),
                _buildMenuItems(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(AuthProvider authProvider) {
    final user = authProvider.userModel!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(AppConfig.primaryTealColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Color(AppConfig.primaryTealColor),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.userType == 'organization' ? 'Organization' : 'Regular User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOrganizations() {
    return Consumer<OrganizationProvider>(
      builder: (context, orgProvider, child) {
        if (orgProvider.myOrganizations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.business,
                    color: Color(AppConfig.primaryTealColor),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'My Organizations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...orgProvider.myOrganizations.map((org) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(AppConfig.primaryTealColor),
                      child: Text(
                        org.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(org.name),
                    subtitle: Text(org.description),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to organization details
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel!;
        final isRegularUser = user.userType == 'regular';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                Icons.edit,
                'Edit Profile',
                'Update your personal information',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.bookmark,
                'Bookmarked Events',
                'View your bookmarked events',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookmarkedEventsScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.notifications_active,
                'Subscribed Mosques',
                'View your subscribed mosques',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscribedMosquesScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.favorite,
                'Liked Mosques',
                'View your favorite mosques',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LikedMosquesScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.settings,
                'Settings',
                'App preferences and configurations',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              // Show organization verification option only for regular users
              if (user.userType != 'organization') ...[
                _buildDivider(),
                _buildMenuItem(
                  Icons.business_center,
                  'Apply for Organization Status',
                  'Request verification to become an organization',
                  () {
                    _showOrganizationBottomSheet();
                  },
                ),
              ],
              _buildDivider(),
              _buildMenuItem(
                Icons.help_outline,
                'Help & Support',
                'Get help and contact support',
                () {
                  _showHelpSupportBottomSheet();
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.logout,
                'Logout',
                'Sign out of your account',
                () {
                  _showLogoutDialog();
                },
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Color(AppConfig.primaryTealColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }

  // Skeleton placeholder for form field (no extra dependency)
  Widget _buildSkeletonField({double height = 56}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _prepareOrganizationForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _contactPhoneController.text = authProvider.userModel?.phone ?? '';
    // Fire-and-forget: do not block bottom sheet while fetching address
    _attemptAutoFillAddress();
  }

  Future<void> _attemptAutoFillAddress() async {
    setState(() {
      _isLoadingAddress = true;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final hasPermission =
          await LocationService.instance.hasLocationPermission();
      if (!serviceEnabled || !hasPermission) {
        setState(() {
          _isLoadingAddress = false;
        });
        return;
      }
      final position = await LocationService.instance.getCurrentLocation();
      if (position == null) {
        setState(() {
          _isLoadingAddress = false;
        });
        return;
      }
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String address = '';
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.name,
          p.thoroughfare,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ]
            .where((e) => e != null && (e as String).isNotEmpty)
            .map((e) => e as String)
            .toList();
        address = parts.join(', ');
      }
      setState(() {
        _addressController.text =
            address.isNotEmpty ? address : 'Current Location';
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _isLoadingAddress = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _onRefreshAddress() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final hasPermission =
        await LocationService.instance.hasLocationPermission();
    if (!serviceEnabled || !hasPermission) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Location'),
          content: const Text(
              'Please enable location services and grant permission to auto-fill your address.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await LocationService.instance.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return;
    }
    await _attemptAutoFillAddress();
  }

  void _showOrganizationBottomSheet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to apply for organization status'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user already has a pending or accepted application
    try {
      final verificationData =
          await FirebaseService.getOrganizationVerificationStatus(
              authProvider.userModel!.id);

      if (verificationData != null) {
        String status = verificationData['verifyStatus'] ?? 'pending';
        String message;

        switch (status) {
          case 'pending':
            message =
                'Your organization application is currently under review. Please wait for admin approval.';
            break;
          case 'accepted':
            message =
                'Your organization application has been approved! You now have organization privileges.';
            break;
          case 'declined':
            message =
                'Your organization application was declined. You can submit a new application.';
            break;
          default:
            message =
                'You have an existing application. Please contact support for more information.';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Application Status'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Only allow new application if previous was declined
        if (status != 'declined') {
          return;
        }
      }
    } catch (e) {
      print('Error checking verification status: $e');
    }

    // Prepare form values (phone and address)
    _prepareOrganizationForm();

    // Show the organization application form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: SafeArea(
          top: false,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
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
                    children: [
                      const Icon(Icons.business_center,
                          color: Color(AppConfig.primaryTealColor)),
                      const SizedBox(width: 12),
                      const Text(
                        'Apply for Organization Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: _buildOrganizationFormContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Organization Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please provide the following information to apply for organization status. All fields marked with * are required.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),

        // Organization Name
        const Text(
          'Organization Name *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _organizationNameController,
          decoration: InputDecoration(
            hintText: 'Enter your organization name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(AppConfig.primaryTealColor)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            prefixIcon: const Icon(Icons.business,
                color: Color(AppConfig.primaryTealColor)),
          ),
        ),
        const SizedBox(height: 20),

        // Organization Description
        const Text(
          'Organization Description *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your organization, its mission, and activities',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(AppConfig.primaryTealColor)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            prefixIcon: const Icon(Icons.description,
                color: Color(AppConfig.primaryTealColor)),
          ),
        ),
        const SizedBox(height: 20),

        // Contact Email
        const Text(
          'Contact Email *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contactEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter official contact email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(AppConfig.primaryTealColor)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            prefixIcon: const Icon(Icons.email,
                color: Color(AppConfig.primaryTealColor)),
          ),
        ),
        const SizedBox(height: 20),

        // Contact Phone
        const Text(
          'Contact Phone *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contactPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter contact phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(AppConfig.primaryTealColor)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            prefixIcon: const Icon(Icons.phone,
                color: Color(AppConfig.primaryTealColor)),
          ),
        ),
        const SizedBox(height: 20),

        // Address with refresh
        Row(
          children: [
            const Text(
              'Address *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            _isLoadingAddress
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(AppConfig.primaryTealColor),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _onRefreshAddress,
                    icon: const Icon(Icons.refresh,
                        color: Color(AppConfig.primaryTealColor)),
                  ),
          ],
        ),
        const SizedBox(height: 8),
        _isLoadingAddress
            ? Container(
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              )
            : TextField(
                controller: _addressController,
                readOnly: true,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Auto-filled from your current location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(AppConfig.primaryTealColor)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(AppConfig.primaryTealColor), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.location_on,
                      color: Color(AppConfig.primaryTealColor)),
                ),
              ),
        const SizedBox(height: 20),

        // Website (Optional)
        const Text(
          'Website (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _websiteController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'https://your-organization-website.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(AppConfig.primaryTealColor)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            prefixIcon: const Icon(Icons.language,
                color: Color(AppConfig.primaryTealColor)),
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              _submitOrganizationApplication();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConfig.primaryTealColor),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Submit Application',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _submitOrganizationApplication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validate required fields
    if (_organizationNameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _contactEmailController.text.trim().isEmpty ||
        _contactPhoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to submit application'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Prepare user details
      final userDetails = {
        'userId': authProvider.userModel!.id,
        'name': authProvider.userModel!.name,
        'email': authProvider.userModel!.email,
        'phone': authProvider.userModel!.phone,
        'userType': authProvider.userModel!.userType.toString(),
      };

      // Submit to Firestore
      await FirebaseService.submitOrganizationVerification(
        userId: authProvider.userModel!.id,
        organizationName: _organizationNameController.text.trim(),
        organizationDescription: _descriptionController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        userDetails: userDetails,
        contactPhone: _contactPhoneController.text.trim(),
        fullAddress: _addressController.text.trim(),
        latitude: _currentLatitude,
        longitude: _currentLongitude,
      );

      // Close loading indicator
      Navigator.pop(context);

      // Clear form
      _organizationNameController.clear();
      _descriptionController.clear();
      _contactEmailController.clear();
      _websiteController.clear();
      _contactPhoneController.clear();
      _addressController.clear();

      // Close bottom sheet
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Application Submitted'),
          content: const Text(
              'Your organization application has been successfully submitted and will be reviewed by our admin team. You will be notified once the review is complete.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading indicator if still open
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showHelpSupportBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: Navigator.of(context),
      ),
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(AppConfig.primaryTealColor).withOpacity(0.02),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar with animation
                Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Color(AppConfig.primaryTealColor)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Header with Islamic pattern and animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(AppConfig.primaryTealColor),
                                Color(AppConfig.secondaryTealColor),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(AppConfig.primaryTealColor)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Islamic geometric pattern overlay with rotation animation
                              Positioned(
                                top: -10,
                                right: -10,
                                child: Transform.rotate(
                                  angle: value * 0.5,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.mosque,
                                        color: Colors.white.withOpacity(0.3),
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Crescent moon decoration with fade animation
                              Positioned(
                                bottom: -5,
                                left: -5,
                                child: Opacity(
                                  opacity: value * 0.7,
                                  child: Icon(
                                    Icons.nightlight_round,
                                    color: Colors.white.withOpacity(0.2),
                                    size: 30,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.support_agent,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Help & Support',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Available 24/7 • بِسْمِ اللهِ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Contact options with enhanced design
                // Contact options with staggered animations
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: _buildEnhancedContactOption(
                          icon: Icons.email_outlined,
                          title: 'Email Support',
                          subtitle: 'support@ummahub.app',
                          description: 'Get detailed help via email',
                          color: const Color(0xFF4285F4),
                          onTap: () => _launchEmail('support@ummahub.app'),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: _buildEnhancedContactOption(
                          icon: Icons.phone_outlined,
                          title: 'Phone Support',
                          subtitle: '+1 (234) 567-890',
                          description: 'Speak directly with our team',
                          color: const Color(0xFF34A853),
                          onTap: () => _launchPhone('+1 (234) 567-890'),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Office Information with enhanced design and animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(AppConfig.primaryTealColor)
                                  .withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(AppConfig.primaryTealColor)
                                    .withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(AppConfig.primaryTealColor)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.location_city,
                                      color: Color(AppConfig.primaryTealColor),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Global Headquarters',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(left: 42),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New York, USA',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Serving the global Muslim community',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Additional help text with Islamic blessing
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(AppConfig.primaryTealColor)
                            .withOpacity(0.05),
                        Color(AppConfig.secondaryTealColor)
                            .withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(AppConfig.primaryTealColor)
                          .withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Color(AppConfig.primaryTealColor),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'May Allah bless you and guide you',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(AppConfig.primaryTealColor),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🤲',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'بَارَكَ اللهُ فِيكَ • Barakallahu feek',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(AppConfig.primaryTealColor)
                              .withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildEnhancedContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request - UmmaHub App',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open phone app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening phone: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                _logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
