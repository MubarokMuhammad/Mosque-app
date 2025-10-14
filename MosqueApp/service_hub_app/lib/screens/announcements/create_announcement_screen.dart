import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';
import '../../models/announcement_model.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  AnnouncementCategory _selectedCategory = AnnouncementCategory.general;
  String? _selectedCustomCategory;
  DateTime? _expirationDate;
  bool _emailNotification = true;
  bool _smsNotification = false;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createAnnouncement,
            child: Text(
              'POST',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildCategorySelector(),
              const SizedBox(height: 20),
              _buildExpirationDatePicker(),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildNotificationSettings(),
              const SizedBox(height: 32),
              _buildCreateButton(),
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
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Enter announcement title...',
            border: OutlineInputBorder(),
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
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _generateAnnouncementDescription,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 4),
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
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Enter announcement description...',
            border: OutlineInputBorder(),
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AnnouncementCategory>(
              value: _selectedCategory,
              isExpanded: true,
              onChanged: (category) {
                if (category != null) {
                  setState(() {
                    _selectedCategory = category;
                    _selectedCustomCategory = null; // Reset custom category when default is selected
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
              borderRadius: BorderRadius.circular(8),
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
        Text(
          'Expiration Date (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectExpirationDate,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
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
                      color: _expirationDate != null ? Colors.black : Colors.grey[600],
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
        Text(
          'Images (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedImages[index].path,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
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
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text(_selectedImages.isEmpty ? 'Add Images' : 'Add More Images'),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
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
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createAnnouncement,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Create Announcement'),
      ),
    );
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

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: false);
      
      final user = authProvider.currentUser!;
      
      final announcement = AnnouncementModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        organizationId: user.id,
        organizationName: user.name,
        createdBy: user.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: _expirationDate,
        status: AnnouncementStatus.active,
        imageUrls: [], // Will be updated after image upload
        isBoosted: false,
        boostedUntil: null,
        boostPrice: 0.0,
        emailNotification: _emailNotification,
        smsNotification: _smsNotification,
        viewCount: 0,
        reportedBy: [],
        metadata: {},
      );

      final success = await announcementProvider.createAnnouncement(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        organizationId: user.id,
        organizationName: user.name,
        createdBy: user.id,
        expiresAt: _expirationDate,
        imageUrls: [],
        emailNotification: _emailNotification,
        smsNotification: _smsNotification,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              announcementProvider.errorMessage ?? 'Failed to create announcement',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Select Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Default Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...AnnouncementCategory.values.map((category) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.folder_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                    title: Text(_getCategoryName(category)),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _selectedCustomCategory = null;
                      });
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
              if (_customSubcategories.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Custom Subcategories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ..._customSubcategories.map((category) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.label_rounded,
                          size: 20,
                          color: Color(AppConfig.primaryTealColor),
                        ),
                      ),
                      title: Text(category),
                      onTap: () {
                        setState(() {
                          _selectedCustomCategory = category;
                          _selectedCategory = AnnouncementCategory.other; // Set to 'Other' for custom categories
                        });
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
        additionalInfo: _selectedCustomCategory,
      );

      if (description.isNotEmpty) {
        setState(() {
          _descriptionController.text = description;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Description generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate description: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingDescription = false;
        });
      }
    }
  }
}