import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_config.dart';
import '../../models/announcement_model.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  AnnouncementCategory _selectedCategory = AnnouncementCategory.general;
  String? _selectedCustomCategory;
  DateTime? _expirationDate;
  bool _emailNotification = true;
  bool _smsNotification = false;
  List<XFile> _selectedImages = [];
  List<String> _tags = [];
  bool _isLoading = false;
  bool _isDraftLoading = false;
  final AIService _aiService = AIService();
  bool _isGeneratingDescription = false;

  // Default categories
  final List<String> _defaultCategories = [
    'General',
    'Events',
    'Prayer Times',
    'Emergency',
    'Community',
  ];

  // Custom subcategories (in real app, this would come from a database or shared preferences)
  final List<String> _customSubcategories = [
    'Programs',
    'Youth Activities',
    'Educational Classes',
    'Charity Drives',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Draft Button
          TextButton.icon(
            onPressed:
                _isDraftLoading ? null : () => _saveAnnouncement(isDraft: true),
            icon: _isDraftLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: const Text('DRAFT'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          // Publish Button
          TextButton.icon(
            onPressed:
                _isLoading ? null : () => _saveAnnouncement(isDraft: false),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.publish, size: 18),
            label: const Text('PUBLISH'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.2),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: 24),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              _buildTagsField(),
              const SizedBox(height: 24),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              _buildExpirationDatePicker(),
              const SizedBox(height: 24),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildNotificationSettings(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.title,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Announcement Title',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter a compelling title for your announcement...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            prefixIcon: Icon(
              Icons.edit,
              color: Color(AppConfig.primaryTealColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            if (value.trim().length < 5) {
              return 'Title must be at least 5 characters';
            }
            return null;
          },
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _generateAnnouncementDescription,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(AppConfig.primaryTealColor).withOpacity(0.1),
                      Color(AppConfig.primaryTealColor).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(AppConfig.primaryTealColor).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Color(AppConfig.primaryTealColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConfig.primaryTealColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Provide detailed information about your announcement...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
          maxLength: 1000,
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_offer,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: 'Add tags to help categorize your announcement...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Color(AppConfig.primaryTealColor), width: 2),
            ),
            prefixIcon: Icon(
              Icons.tag,
              color: Color(AppConfig.primaryTealColor),
            ),
            suffixIcon: IconButton(
              onPressed: _addTag,
              icon: Icon(
                Icons.add_circle,
                color: Color(AppConfig.primaryTealColor),
              ),
            ),
          ),
          onFieldSubmitted: (_) => _addTag(),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppConfig.primaryTealColor),
            Color(AppConfig.primaryTealColor).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(AppConfig.primaryTealColor).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
            ),
            const Spacer(),
            if (_customSubcategories.isNotEmpty)
              TextButton.icon(
                onPressed: _showCategorySelectionDialog,
                icon: Icon(
                  Icons.category_rounded,
                  size: 16,
                  color: Color(AppConfig.primaryTealColor),
                ),
                label: Text(
                  'Browse All',
                  style: TextStyle(
                    color: Color(AppConfig.primaryTealColor),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AnnouncementCategory>(
              value: _selectedCategory,
              isExpanded: true,
              onChanged: (category) {
                if (category != null) {
                  setState(() {
                    _selectedCategory = category;
                    _selectedCustomCategory = null;
                  });
                }
              },
              items: AnnouncementCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryName(category)),
                );
              }).toList(),
            ),
          ),
        ),
        if (_selectedCustomCategory != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(AppConfig.primaryTealColor).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(AppConfig.primaryTealColor).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.label_rounded,
                  size: 16,
                  color: Color(AppConfig.primaryTealColor),
                ),
                const SizedBox(width: 8),
                Text(
                  'Custom Category: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _selectedCustomCategory!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConfig.primaryTealColor),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCustomCategory = null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpirationDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Expiration Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectExpirationDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Color(AppConfig.primaryTealColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _expirationDate != null
                        ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                        : 'Select expiration date',
                    style: TextStyle(
                      color: _expirationDate != null
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                ),
                if (_expirationDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _expirationDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Images',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _selectedImages[index].path,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 40),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label:
              Text(_selectedImages.isEmpty ? 'Add Images' : 'Add More Images'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(AppConfig.primaryTealColor),
            side: BorderSide(color: Color(AppConfig.primaryTealColor)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications,
              size: 20,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppConfig.primaryTealColor),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              CheckboxListTile(
                title: const Text('Send Email Notifications'),
                subtitle: const Text('Notify subscribers via email'),
                value: _emailNotification,
                onChanged: (value) {
                  setState(() {
                    _emailNotification = value ?? false;
                  });
                },
                activeColor: Color(AppConfig.primaryTealColor),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Send SMS Notifications'),
                subtitle: const Text('Notify subscribers via SMS'),
                value: _smsNotification,
                onChanged: (value) {
                  setState(() {
                    _smsNotification = value ?? false;
                  });
                },
                activeColor: Color(AppConfig.primaryTealColor),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                _isDraftLoading ? null : () => _saveAnnouncement(isDraft: true),
            icon: _isDraftLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Save as Draft'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(AppConfig.primaryTealColor),
              side: BorderSide(color: Color(AppConfig.primaryTealColor)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _isLoading ? null : () => _saveAnnouncement(isDraft: false),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.publish),
            label: const Text('Publish Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConfig.primaryTealColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 10) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _expirationDate = date;
      });
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 5) {
          _selectedImages = _selectedImages.take(5).toList();
        }
      });
    }
  }

  Future<void> _saveAnnouncement({required bool isDraft}) async {
    print('DEBUG: _saveAnnouncement called with isDraft: $isDraft');
    
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }
    
    print('DEBUG: Form validation passed');

    setState(() {
      if (isDraft) {
        _isDraftLoading = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;

      if (user == null) {
        print('DEBUG: User is null');
        throw Exception('User not authenticated');
      }
      
      print('DEBUG: User found: ${user.email}');

      // Get user's organization data
      String organizationId = user.id;
      String organizationName = 'Unknown Organization';

      // Fetch organization data from Firestore
      print('DEBUG: Fetching organization data for user: ${user.id}');
      final orgQuery = await FirebaseFirestore.instance
          .collection('mosqueapp_organizations')
          .where('adminIds', arrayContains: user.id)
          .limit(1)
          .get();

      if (orgQuery.docs.isNotEmpty) {
        final orgData = orgQuery.docs.first.data();
        organizationId = orgQuery.docs.first.id;
        organizationName = orgData['organizationName'] ??
            orgData['name'] ??
            'Unknown Organization';
        print('DEBUG: Organization found: $organizationName');
      } else {
        print('DEBUG: No organization found for user');
      }

      // Create announcement document
      final announcementData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory.toString().split('.').last,
        'tags': _tags,
        'organizationId': organizationId,
        'organizationName': organizationName,
        'createdBy': user.id,
        'createdByName': user.name ?? 'Unknown User',
        'createdByEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': _expirationDate,
        'status': isDraft ? 'draft' : 'published',
        'imageUrls': [], // Will be updated after image upload
        'isBoosted': false,
        'boostedUntil': null,
        'boostPrice': 0.0,
        'emailNotification': _emailNotification,
        'smsNotification': _smsNotification,
        'viewCount': 0,
        'reportedBy': [],
        'metadata': {
          'userDetails': {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'userType': user.userType,
          },
          'organizationDetails': {
            'id': organizationId,
            'name': organizationName,
          },
          'createdFrom': 'mobile_app',
          'version': '1.0.0',
        },
      };

      print('DEBUG: Saving announcement data: ${announcementData['title']}');
      
      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('mosqueapp_announcements')
          .add(announcementData);

      print('DEBUG: Announcement saved with ID: ${docRef.id}');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDraft
                  ? 'Announcement saved as draft successfully!'
                  : 'Announcement published successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (error) {
      print('DEBUG: Error saving announcement: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isDraft) {
            _isDraftLoading = false;
          } else {
            _isLoading = false;
          }
        });
      }
    }
  }

  String _getCategoryName(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.general:
        return 'General';
      case AnnouncementCategory.event:
        return 'Event';
      case AnnouncementCategory.prayer:
        return 'Prayer';
      case AnnouncementCategory.education:
        return 'Education';
      case AnnouncementCategory.charity:
        return 'Charity';
      case AnnouncementCategory.community:
        return 'Community';
      case AnnouncementCategory.emergency:
        return 'Emergency';
      case AnnouncementCategory.other:
        return 'Other';
    }
  }

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.category_rounded,
              color: Color(AppConfig.primaryTealColor),
            ),
            const SizedBox(width: 8),
            const Text('Select Category'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Default Categories'),
              const SizedBox(height: 8),
              ...AnnouncementCategory.values.map((category) {
                return ListTile(
                  title: Text(_getCategoryName(category)),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _selectedCustomCategory = null;
                    });
                    Navigator.of(context).pop();
                  },
                  selected: _selectedCategory == category,
                  selectedTileColor:
                      Color(AppConfig.primaryTealColor).withOpacity(0.1),
                );
              }).toList(),
              const Divider(),
              const Text('Custom Categories'),
              const SizedBox(height: 8),
              ..._customSubcategories.map((category) {
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    setState(() {
                      _selectedCustomCategory = category;
                      _selectedCategory = AnnouncementCategory.other;
                    });
                    Navigator.of(context).pop();
                  },
                  selected: _selectedCustomCategory == category,
                  selectedTileColor:
                      Color(AppConfig.primaryTealColor).withOpacity(0.1),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAnnouncementDescription() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title first to generate description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingDescription = true;
    });

    try {
      final description = await _aiService.generateAnnouncementDescription(
        title: _titleController.text.trim(),
        category: _getCategoryName(_selectedCategory),
        additionalInfo: '',
      );

      setState(() {
        _descriptionController.text = description;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to generate description: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGeneratingDescription = false;
      });
    }
  }
}
