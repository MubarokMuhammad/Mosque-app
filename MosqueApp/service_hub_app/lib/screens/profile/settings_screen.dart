import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

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
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_selectedLanguage),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(),
        ),
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
        ListTile(
          title: const Text('Data & Storage'),
          subtitle: const Text('Manage your data preferences'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDataSettings(),
        ),
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
          onTap: () => _contactSupport(),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is where the privacy policy content would be displayed. '
            'In a real app, this would contain the full privacy policy text '
            'or open a web view to display the policy from your website.',
          ),
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

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is where the terms of service content would be displayed. '
            'In a real app, this would contain the full terms and conditions '
            'or open a web view to display them from your website.',
          ),
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
                  content: Text('Account deletion requested. Please contact support.'),
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

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening app store...'),
      ),
    );
    // TODO: Implement app store rating
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing app...'),
      ),
    );
    // TODO: Implement app sharing
  }
}