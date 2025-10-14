import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';
import 'home/home_screen.dart';
import 'events/events_screen.dart';
import 'organizations/organizations_screen.dart';
import 'announcements/announcements_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsScreen(),
    const OrganizationsScreen(),
    const AnnouncementsScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking authentication
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Redirect to login if not authenticated
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
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

  Widget? _buildFloatingActionButton() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Only show FAB for organization users and on specific screens
    if (authProvider.userModel?.userType != 'organization') {
      return null;
    }

    switch (_currentIndex) {
      case 1: // Events screen
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create-event');
          },
          backgroundColor: Color(AppConfig.primaryTealColor),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          tooltip: 'Create Event',
        );
      case 2: // Organizations screen
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create-organization');
          },
          backgroundColor: Color(AppConfig.primaryTealColor),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          tooltip: 'Create Organization',
        );
      case 3: // Announcements screen
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create-announcement');
          },
          backgroundColor: Color(AppConfig.primaryTealColor),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          tooltip: 'Create Announcement',
        );
      default:
        return null;
    }
  }
}

// Custom page route for smooth transitions
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AxisDirection direction;

  CustomPageRoute({
    required this.child,
    this.direction = AxisDirection.left,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: _getBeginOffset(),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  Offset _getBeginOffset() {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.right:
        return const Offset(-1, 0);
      case AxisDirection.left:
      default:
        return const Offset(1, 0);
    }
  }
}
