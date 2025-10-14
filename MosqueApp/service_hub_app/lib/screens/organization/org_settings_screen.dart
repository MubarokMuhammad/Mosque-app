import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class OrgSettingsScreen extends StatefulWidget {
  const OrgSettingsScreen({super.key});

  @override
  State<OrgSettingsScreen> createState() => _OrgSettingsScreenState();
}

class _OrgSettingsScreenState extends State<OrgSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _notificationsEnabled = true;
  bool _publicProfile = false;
  bool _autoApproveMembers = false;
  bool _allowMemberInvites = true;
  String _selectedLanguage = 'Indonesian';
  String _selectedTimezone = 'Asia/Jakarta';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Organization Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Color(AppConfig.primaryTealColor),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Color(AppConfig.primaryTealColor),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Privacy'),
                Tab(text: 'Members'),
                Tab(text: 'Advanced'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildPrivacyTab(),
          _buildMembersTab(),
          _buildAdvancedTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Organization Information',
            children: [
              _buildTextField(
                label: 'Organization Name',
                value: 'Masjid Al-Ikhlas',
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Description',
                value:
                    'A community mosque serving the local area with various religious and social activities.',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Address',
                value: 'Jl. Masjid Raya No. 123, Jakarta',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Contact Phone',
                value: '+62 21 1234 5678',
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Email',
                value: 'info@masjidalikhas.org',
                icon: Icons.email,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Visibility Settings',
            children: [
              _buildSwitchTile(
                title: 'Public Profile',
                subtitle: 'Make organization visible to public',
                value: _publicProfile,
                icon: Icons.public,
                onChanged: (value) {
                  setState(() {
                    _publicProfile = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Show Member Count',
                subtitle: 'Display total number of members publicly',
                value: true,
                icon: Icons.people,
                onChanged: (value) {},
              ),
              _buildSwitchTile(
                title: 'Show Event Statistics',
                subtitle: 'Display event participation statistics',
                value: false,
                icon: Icons.analytics,
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            title: 'Data & Privacy',
            children: [
              _buildActionTile(
                title: 'Privacy Policy',
                subtitle: 'View and manage privacy settings',
                icon: Icons.privacy_tip,
                onTap: () {},
              ),
              _buildActionTile(
                title: 'Data Export',
                subtitle: 'Export organization data',
                icon: Icons.download,
                onTap: () {},
              ),
              _buildActionTile(
                title: 'Data Retention',
                subtitle: 'Manage data retention policies',
                icon: Icons.storage,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Member Management',
            children: [
              _buildSwitchTile(
                title: 'Auto-approve Members',
                subtitle: 'Automatically approve new member requests',
                value: _autoApproveMembers,
                icon: Icons.how_to_reg,
                onChanged: (value) {
                  setState(() {
                    _autoApproveMembers = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Allow Member Invites',
                subtitle: 'Let members invite others to join',
                value: _allowMemberInvites,
                icon: Icons.person_add,
                onChanged: (value) {
                  setState(() {
                    _allowMemberInvites = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Require Email Verification',
                subtitle: 'New members must verify their email',
                value: true,
                icon: Icons.verified_user,
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            title: 'Roles & Permissions',
            children: [
              _buildActionTile(
                title: 'Manage Roles',
                subtitle: 'Configure member roles and permissions',
                icon: Icons.admin_panel_settings,
                onTap: () {},
              ),
              _buildActionTile(
                title: 'Default Role',
                subtitle: 'Set default role for new members',
                icon: Icons.person,
                onTap: () {},
              ),
              _buildActionTile(
                title: 'Permission Templates',
                subtitle: 'Create and manage permission templates',
                icon: Icons.security,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Enable push notifications for events',
                value: _notificationsEnabled,
                icon: Icons.notifications,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Send email notifications to members',
                value: true,
                icon: Icons.email,
                onChanged: (value) {},
              ),
              _buildSwitchTile(
                title: 'SMS Notifications',
                subtitle: 'Send SMS notifications for urgent events',
                value: false,
                icon: Icons.sms,
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            title: 'Integration',
            children: [
              _buildActionTile(
                title: 'API Settings',
                subtitle: 'Manage API keys and integrations',
                icon: Icons.api,
                onTap: () {},
              ),
              _buildActionTile(
                title: 'Webhooks',
                subtitle: 'Configure webhook endpoints',
                icon: Icons.webhook,
                onTap: () {},
              ),
              _buildActionTile(
                title: 'Third-party Apps',
                subtitle: 'Manage connected applications',
                icon: Icons.apps,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            title: 'Danger Zone',
            children: [
              _buildActionTile(
                title: 'Reset Settings',
                subtitle: 'Reset all settings to default',
                icon: Icons.refresh,
                onTap: () {},
                isDestructive: true,
              ),
              _buildActionTile(
                title: 'Delete Organization',
                subtitle: 'Permanently delete this organization',
                icon: Icons.delete_forever,
                onTap: () {},
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(AppConfig.primaryTealColor)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(AppConfig.primaryTealColor)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(AppConfig.primaryTealColor)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(AppConfig.primaryTealColor)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(AppConfig.primaryTealColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withOpacity(0.1)
                      : Color(AppConfig.primaryTealColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red
                      : Color(AppConfig.primaryTealColor),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? Colors.red : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
