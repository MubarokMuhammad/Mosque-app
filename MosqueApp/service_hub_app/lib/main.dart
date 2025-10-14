import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'config/firebase_config.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/organization_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/event_provider.dart';
import 'models/event_model.dart';
import 'models/announcement_model.dart';
import 'models/organization_model.dart';
import 'services/local_notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/events/create_event_screen.dart';
import 'screens/events/event_detail_screen.dart';
import 'screens/organizations/create_organization_screen.dart';
import 'screens/organizations/organization_detail_screen.dart';
import 'screens/announcements/create_announcement_screen.dart';
import 'screens/announcements/announcement_detail_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/settings_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );

  // Initialize local notifications
  await LocalNotificationService().initialize();

  runApp(const ServiceHubApp());
}

class ServiceHubApp extends StatelessWidget {
  const ServiceHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/main': (context) => const MainScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/create-event': (context) => const CreateEventScreen(),
          '/create-organization': (context) => const CreateOrganizationScreen(),
          '/create-announcement': (context) => const CreateAnnouncementScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/event-detail':
              final event = settings.arguments as EventModel;
              return MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              );
            case '/organization-detail':
              final organizationId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) =>
                    OrganizationDetailScreen(organizationId: organizationId),
              );
            case '/announcement-detail':
              final announcement = settings.arguments as AnnouncementModel;
              return MaterialPageRoute(
                builder: (context) =>
                    AnnouncementDetailScreen(announcement: announcement),
              );
            default:
              return null;
          }
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}
