import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _eventReminders = true;
  bool _organizationUpdates = true;
  bool _systemNotifications = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            children: [
              _buildNotificationSettings(),
              _buildAppearanceSettings(),
              _buildPrivacySettings(),
              _buildAccountSettings(authProvider),
              _buildAboutSettings(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive push notifications'),
          value: _notificationsEnabled,
          activeColor: Color(AppConfig.primaryTealColor),
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              if (!value) {
                _eventReminders = false;
                _organizationUpdates = false;
                _systemNotifications = false;
              }
            });
          },
        ),
        SwitchListTile(
          title: const Text('Event Reminders'),
          subtitle: const Text('Get notified about upcoming events'),
          value: _eventReminders,
          activeColor: Color(AppConfig.primaryTealColor),
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() {
                    _eventReminders = value;
                  });
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Organization Updates'),
          subtitle: const Text('Updates from organizations you follow'),
          value: _organizationUpdates,
          activeColor: Color(AppConfig.primaryTealColor),
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() {
                    _organizationUpdates = value;
                  });
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('System Notifications'),
          subtitle: const Text('App updates and system messages'),
          value: _systemNotifications,
          activeColor: Color(AppConfig.primaryTealColor),
          onChanged: _notificationsEnabled
              ? (value) {
                  setState(() {
                    _systemNotifications = value;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return _buildSettingsSection(
      title: 'Appearance',
      icon: Icons.palette,
      children: [
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(_selectedTheme),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(),
        ),
        // ListTile(
        //   title: const Text('Language'),
        //   subtitle: Text(_selectedLanguage),
        //   trailing: const Icon(Icons.chevron_right),
        //   onTap: () => _showLanguageDialog(),
        // ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsSection(
      title: 'Privacy & Security',
      icon: Icons.security,
      children: [
        ListTile(
          title: const Text('Privacy Policy'),
          subtitle: const Text('View our privacy policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPrivacyPolicy(),
        ),
        ListTile(
          title: const Text('Terms of Service'),
          subtitle: const Text('View terms and conditions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showTermsOfService(),
        ),
        // ListTile(
        //   title: const Text('Data & Storage'),
        //   subtitle: const Text('Manage your data preferences'),
        //   trailing: const Icon(Icons.chevron_right),
        //   onTap: () => _showDataSettings(),
        // ),
      ],
    );
  }

  Widget _buildAccountSettings(AuthProvider authProvider) {
    return _buildSettingsSection(
      title: 'Account',
      icon: Icons.account_circle,
      children: [
        ListTile(
          title: const Text('Change Password'),
          subtitle: const Text('Update your account password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showChangePasswordDialog(),
        ),
        ListTile(
          title: const Text('Delete Account'),
          subtitle: const Text('Permanently delete your account'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeleteAccountDialog(authProvider),
        ),
      ],
    );
  }

  Widget _buildAboutSettings() {
    return _buildSettingsSection(
      title: 'About',
      icon: Icons.info,
      children: [
        ListTile(
          title: const Text('App Version'),
          subtitle: Text('Version ${AppConfig.appVersion}'),
        ),
        ListTile(
          title: const Text('Contact Support'),
          subtitle: const Text('Get help and support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showHelpSupportBottomSheet(),
        ),
        ListTile(
          title: const Text('Rate App'),
          subtitle: const Text('Rate us on the app store'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _rateApp(),
        ),
        ListTile(
          title: const Text('Share App'),
          subtitle: const Text('Share with friends and family'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _shareApp(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Color(AppConfig.primaryTealColor),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'Light',
              groupValue: _selectedTheme,
              activeColor: Color(AppConfig.primaryTealColor),
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'Dark',
              groupValue: _selectedTheme,
              activeColor: Color(AppConfig.primaryTealColor),
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'System',
              groupValue: _selectedTheme,
              activeColor: Color(AppConfig.primaryTealColor),
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Arabic', 'French', 'Spanish'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              activeColor: Color(AppConfig.primaryTealColor),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PrivacyPolicyScreen(),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TermsOfServiceScreen(),
      ),
    );
  }

  void _showDataSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data & Storage'),
        content: const Text(
          'Manage your data preferences, cache settings, and storage options.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // TODO: Implement password change
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConfig.primaryTealColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Account deletion requested. Please contact support.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'For support, please email us at support@servicehub.com or call +1-234-567-8900.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateApp() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      
      if (await inAppReview.isAvailable()) {
        // Request the in-app review
        await inAppReview.requestReview();
      } else {
        // Fallback to opening the app store
        await inAppReview.openStoreListing(
          appStoreId: 'your-app-store-id', // Replace with actual App Store ID
          microsoftStoreId: 'your-microsoft-store-id', // Replace with actual Microsoft Store ID if needed
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for rating our app!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open app store. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareApp() async {
    try {
      const String appName = 'Mosque Service Hub';
      const String appDescription = 'Discover and connect with mosque services in your community. Find prayer times, events, and more!';
      const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.yourcompany.servicehubapp'; // Replace with actual Play Store URL
      const String appStoreUrl = 'https://apps.apple.com/app/idYOUR_APP_ID'; // Replace with actual App Store URL
      
      final String shareText = '''
🕌 $appName

$appDescription

📱 Download now:
Android: $playStoreUrl
iOS: $appStoreUrl

#MosqueApp #IslamicServices #Community
      '''.trim();
      
      await Share.share(
        shareText,
        subject: 'Check out $appName!',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for sharing our app!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share app. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                        Color(AppConfig.primaryTealColor).withOpacity(0.05),
                        Color(AppConfig.secondaryTealColor).withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
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
}

class _PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Mosque Service Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(AppConfig.primaryTealColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Introduction',
              'Welcome to Mosque Service Hub. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.',
            ),
            
            _buildSection(
              'Information We Collect',
              'We may collect information about you in a variety of ways. The information we may collect via the App includes:\n\n'
              '• Personal Data: Personally identifiable information, such as your name, email address, and telephone number, and demographic information, such as your age, gender, hometown, and interests, that you voluntarily give to us when you register with the App or when you choose to participate in various activities related to the App.\n\n'
              '• Derivative Data: Information our servers automatically collect when you access the App, such as your IP address, your browser type, your operating system, your access times, and the pages you have viewed directly before and after accessing the App.\n\n'
              '• Financial Data: Financial information, such as data related to your payment method (e.g., valid credit card number, card brand, expiration date) that we may collect when you purchase, order, return, exchange, or request information about our services from the App.',
            ),
            
            _buildSection(
              'Use of Your Information',
              'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the App to:\n\n'
              '• Create and manage your account\n'
              '• Process your transactions and send you related information\n'
              '• Email you regarding your account or order\n'
              '• Enable user-to-user communications\n'
              '• Generate a personal profile about you to make future visits to the App more personalized\n'
              '• Increase the efficiency and operation of the App\n'
              '• Monitor and analyze usage and trends to improve your experience with the App\n'
              '• Notify you of updates to the App\n'
              '• Offer new products, services, mobile applications, and/or recommendations to you\n'
              '• Perform other business activities as needed',
            ),
            
            _buildSection(
              'Disclosure of Your Information',
              'We may share information we have collected about you in certain situations. Your information may be disclosed as follows:\n\n'
              '• By Law or to Protect Rights: If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others, we may share your information as permitted or required by any applicable law, rule, or regulation.\n\n'
              '• Business Transfers: We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.\n\n'
              '• Third-Party Service Providers: We may share your information with third parties that perform services for us or on our behalf, including payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance.',
            ),
            
            _buildSection(
              'Security of Your Information',
              'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.',
            ),
            
            _buildSection(
              'Policy for Children',
              'We do not knowingly solicit information from or market to children under the age of 13. If we learn that we have collected personal information from a child under age 13 without verification of parental consent, we will delete that information as quickly as possible. If you believe we might have any information from or about a child under 13, please contact us.',
            ),
            
            _buildSection(
              'Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time in order to reflect, for example, changes to our practices or for other operational, legal, or regulatory reasons. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes.',
            ),
            
            _buildSection(
              'Contact Us',
              'If you have questions or comments about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@mosquehub.com\n'
              'Phone: +1 (555) 123-4567\n'
              'Address: 123 Islamic Center Drive, Community City, State 12345',
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(AppConfig.primaryTealColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service for Mosque Service Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(AppConfig.primaryTealColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Agreement to Terms',
              'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement. Additionally, when using this application\'s particular services, you shall be subject to any posted guidelines or rules applicable to such services.',
            ),
            
            _buildSection(
              'Description of Service',
              'Mosque Service Hub is a mobile application that connects users with local mosques and Islamic organizations. Our service provides:\n\n'
              '• Event listings and announcements from local mosques\n'
              '• Prayer time notifications and Qibla direction\n'
              '• Community engagement features\n'
              '• Educational content and resources\n'
              '• Donation and volunteer opportunities\n'
              '• Social networking within the Islamic community',
            ),
            
            _buildSection(
              'User Accounts and Registration',
              'To access certain features of the Service, you must register for an account. When you register for an account, you may be required to provide us with some information about yourself, such as your name, email address, or other contact information. You agree that the information you provide to us is accurate and that you will keep it accurate and up-to-date at all times.',
            ),
            
            _buildSection(
              'Acceptable Use Policy',
              'You may not use our service:\n\n'
              '• For any unlawful purpose or to solicit others to take unlawful actions\n'
              '• To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances\n'
              '• To infringe upon or violate our intellectual property rights or the intellectual property rights of others\n'
              '• To harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate\n'
              '• To submit false or misleading information\n'
              '• To upload or transmit viruses or any other type of malicious code\n'
              '• To spam, phish, pharm, pretext, spider, crawl, or scrape\n'
              '• For any obscene or immoral purpose\n'
              '• To interfere with or circumvent the security features of our service',
            ),
            
            _buildSection(
              'Content Guidelines',
              'Users may post, upload, or share content through our Service. By posting content, you grant us a non-exclusive, worldwide, royalty-free license to use, reproduce, modify, and distribute your content in connection with our Service. You are solely responsible for the content you post and must ensure it:\n\n'
              '• Does not violate any laws or regulations\n'
              '• Does not infringe on third-party rights\n'
              '• Is respectful and appropriate for a religious community\n'
              '• Does not contain hate speech, harassment, or discriminatory content\n'
              '• Aligns with Islamic values and principles',
            ),
            
            _buildSection(
              'Privacy and Data Protection',
              'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service, to understand our practices regarding the collection and use of your personal information.',
            ),
            
            _buildSection(
              'Intellectual Property Rights',
              'The Service and its original content, features, and functionality are and will remain the exclusive property of Mosque Service Hub and its licensors. The Service is protected by copyright, trademark, and other laws. Our trademarks and trade dress may not be used in connection with any product or service without our prior written consent.',
            ),
            
            _buildSection(
              'Termination',
              'We may terminate or suspend your account and bar access to the Service immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation, including but not limited to a breach of the Terms.',
            ),
            
            _buildSection(
              'Disclaimer',
              'The information on this application is provided on an "as is" basis. To the fullest extent permitted by law, this Company:\n\n'
              '• Excludes all representations and warranties relating to this application and its contents\n'
              '• Excludes all liability for damages arising out of or in connection with your use of this application',
            ),
            
            _buildSection(
              'Limitation of Liability',
              'In no event shall Mosque Service Hub, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your use of the Service.',
            ),
            
            _buildSection(
              'Governing Law',
              'These Terms shall be interpreted and governed by the laws of the jurisdiction in which our company is registered, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.',
            ),
            
            _buildSection(
              'Changes to Terms',
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.',
            ),
            
            _buildSection(
              'Contact Information',
              'If you have any questions about these Terms of Service, please contact us at:\n\n'
              'Email: legal@mosquehub.com\n'
              'Phone: +1 (555) 123-4567\n'
              'Address: 123 Islamic Center Drive, Community City, State 12345',
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(AppConfig.primaryTealColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
