import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/organization_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/organization_model.dart';
import '../../config/app_config.dart';
import 'organization_detail_screen.dart';
import 'create_organization_screen.dart';

class OrganizationsScreen extends StatefulWidget {
  const OrganizationsScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  OrganizationCategory? _selectedCategory;
  bool _showOnlyVerified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizationProvider>().loadOrganizations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<OrganizationProvider>(
              builder: (context, orgProvider, child) {
                if (orgProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredOrgs = _getFilteredOrganizations(orgProvider.organizations);

                if (filteredOrgs.isEmpty) {
                  return const Center(
                    child: Text('No organizations found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrgs.length,
                  itemBuilder: (context, index) {
                    return _buildOrganizationCard(filteredOrgs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isOrganization) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateOrganizationScreen(),
                  ),
                );
              },
              backgroundColor: Color(AppConfig.primaryTealColor),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search organizations...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Verified Only'),
                  selected: _showOnlyVerified,
                  onSelected: (selected) {
                    setState(() {
                      _showOnlyVerified = selected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...OrganizationCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getCategoryName(category)),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(OrganizationModel organization) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrganizationDetailScreen(organizationId: organization.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(organization.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getCategoryName(organization.category),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (organization.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                organization.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                organization.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      organization.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${organization.memberIds.length} members',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final isMember = organization.memberIds.contains(authProvider.userModel?.id);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isMember ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isMember ? 'Member' : 'Not Member',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<OrganizationModel> _getFilteredOrganizations(List<OrganizationModel> organizations) {
    return organizations.where((org) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        if (!org.name.toLowerCase().contains(searchTerm) &&
            !org.description.toLowerCase().contains(searchTerm) &&
            !org.address.toLowerCase().contains(searchTerm)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && org.category != _selectedCategory) {
        return false;
      }

      // Verified filter
      if (_showOnlyVerified && !org.isVerified) {
        return false;
      }

      return true;
    }).toList();
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}