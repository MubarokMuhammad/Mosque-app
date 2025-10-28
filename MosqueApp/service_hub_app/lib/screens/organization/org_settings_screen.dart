import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

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

  // Stream untuk data organisasi dari Firebase
  Stream<DocumentSnapshot>? _organizationStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeOrganizationStream();
  }

  void _initializeOrganizationStream() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel?.email != null) {
      _organizationStream = FirebaseFirestore.instance
          .collection('mosqueapp_organizations')
          .where('userDetails.email', isEqualTo: authProvider.userModel!.email)
          .limit(1)
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty
              ? snapshot.docs.first
              : throw Exception('No organization found'));
    }
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
              fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black),
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
                // Tab(text: 'Members'),
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
          // _buildMembersTab(),
          _buildAdvancedTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _organizationStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading organization data',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeOrganizationStream();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No organization data found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please contact support if this is an error',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          );
        }

        final orgData = snapshot.data!.data() as Map<String, dynamic>;

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
                    value: orgData['name'] ?? 'No name available',
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description',
                    value: orgData['description'] ?? 'No description available',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Address',
                    value: orgData['address'] ?? 'No address available',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Contact Phone',
                    value: orgData['phone'] ?? 'No phone available',
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email',
                    value: orgData['email'] ?? 'No email available',
                    icon: Icons.email,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
                onTap: () {
                  _showPrivacyPolicy();
                },
              ),
              // _buildActionTile(
              //   title: 'Data Export',
              //   subtitle: 'Export organization data',
              //   icon: Icons.download,
              //   onTap: () {},
              // ),
              // _buildActionTile(
              //   title: 'Data Retention',
              //   subtitle: 'Manage data retention policies',
              //   icon: Icons.storage,
              //   onTap: () {},
              // ),
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
              // _buildSwitchTile(
              //   title: 'SMS Notifications',
              //   subtitle: 'Send SMS notifications for urgent events',
              //   value: false,
              //   icon: Icons.sms,
              //   onChanged: (value) {},
              // ),
            ],
          ),
          const SizedBox(height: 20),
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

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PrivacyPolicyScreen(),
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
'Privacy Policy for UmmaHub',
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
'Welcome to UmmaHub. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.',
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
