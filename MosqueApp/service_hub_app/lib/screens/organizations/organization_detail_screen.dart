import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/organization_model.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final String organizationId;

  const OrganizationDetailScreen({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  State<OrganizationDetailScreen> createState() => _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  OrganizationModel? organization;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganization();
  }

  Future<void> _loadOrganization() async {
    try {
      final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);
      final org = orgProvider.getOrganizationById(widget.organizationId);
      setState(() {
        organization = org;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading organization: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Organization Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (organization == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Organization Details'),
        ),
        body: const Center(
          child: Text('Organization not found'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildOrganizationInfo(),
                _buildContactInfo(),
                _buildLocationInfo(),
                _buildMembersSection(),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          organization!.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(AppConfig.primaryTealColor),
                Color(AppConfig.secondaryTealColor),
              ],
            ),
          ),
          child: organization!.logoUrl != null
              ? Image.network(
                  organization!.logoUrl!,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.business,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: ListTile(
                leading: Icon(Icons.report),
                title: Text('Report'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizationInfo() {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(organization!.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryName(organization!.category),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (organization!.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            organization!.description,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.email,
            'Email',
            organization!.email,
            () => _launchEmail(organization!.email),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.phone,
            'Phone',
            organization!.phone,
            () => _launchPhone(organization!.phone),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.person,
            'Direct Contact',
            '${organization!.directContactName}\n${organization!.directContactPhone}',
            () => _launchPhone(organization!.directContactPhone),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, color: Color(AppConfig.primaryTealColor)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
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
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: Color(AppConfig.primaryTealColor)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  organization!.address,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openMap,
              icon: const Icon(Icons.map),
              label: const Text('Open in Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConfig.primaryTealColor),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          const Text(
            'Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.people, color: Color(AppConfig.primaryTealColor)),
              const SizedBox(width: 12),
              Text(
                '${organization!.memberIds.length} members',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final authProvider = Provider.of<AuthProvider>(context);
    final isUserMember = organization!.memberIds.contains(authProvider.userModel?.id);
    final isUserAdmin = organization!.adminIds.contains(authProvider.userModel?.id);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isUserMember && !isUserAdmin)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _joinOrganization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppConfig.primaryTealColor),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Join Organization'),
              ),
            ),
          if (isUserMember && !isUserAdmin)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _leaveOrganization,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Leave Organization'),
              ),
            ),
          if (isUserAdmin)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _editOrganization,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppConfig.primaryTealColor),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Edit Organization'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _manageMembers,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(AppConfig.primaryTealColor),
                      side: BorderSide(color: Color(AppConfig.primaryTealColor)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Manage Members'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getCategoryName(OrganizationCategory category) {
    switch (category) {
      case OrganizationCategory.mosque:
        return 'Mosque';
      case OrganizationCategory.charity:
        return 'Charity';
      case OrganizationCategory.education:
        return 'Education';
      case OrganizationCategory.community:
        return 'Community';
      case OrganizationCategory.healthcare:
        return 'Healthcare';
      case OrganizationCategory.other:
        return 'Other';
    }
  }

  Color _getCategoryColor(OrganizationCategory category) {
    switch (category) {
      case OrganizationCategory.mosque:
        return Colors.green;
      case OrganizationCategory.charity:
        return Colors.orange;
      case OrganizationCategory.education:
        return Colors.blue;
      case OrganizationCategory.community:
        return Colors.purple;
      case OrganizationCategory.healthcare:
        return Colors.red;
      case OrganizationCategory.other:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareOrganization();
        break;
      case 'report':
        _reportOrganization();
        break;
    }
  }

  void _shareOrganization() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality not implemented yet')),
    );
  }

  void _reportOrganization() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Organization'),
        content: const Text('Are you sure you want to report this organization?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Organization reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) {
    // Implement email launch
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening email to $email')),
    );
  }

  void _launchPhone(String phone) {
    // Implement phone launch
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phone')),
    );
  }

  void _openMap() {
    // Implement map opening
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening maps')),
    );
  }

  void _joinOrganization() async {
    try {
      final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await orgProvider.addMember(widget.organizationId, authProvider.userModel!.id);
      _loadOrganization(); // Refresh data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined organization')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining organization: $e')),
        );
      }
    }
  }

  void _leaveOrganization() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Organization'),
        content: const Text('Are you sure you want to leave this organization?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await orgProvider.removeMember(widget.organizationId, authProvider.userModel!.id);
                _loadOrganization(); // Refresh data
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully left organization')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error leaving organization: $e')),
                  );
                }
              }
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _editOrganization() {
    // Navigate to edit organization screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit organization functionality not implemented yet')),
    );
  }

  void _manageMembers() {
    // Navigate to manage members screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage members functionality not implemented yet')),
    );
  }
}