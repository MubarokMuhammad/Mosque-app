import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EventDetailBottomSheet extends StatefulWidget {
  final String title;
  final String date;
  final String description;
  final String imageAsset;
  final int likes;
  final int attending;
  final String? eventId;
  final Map<String, dynamic>? eventData;
  final Map<String, dynamic>? organization;
  final String? organizationName;

  const EventDetailBottomSheet({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.imageAsset,
    this.likes = 120,
    this.attending = 50,
    this.eventId,
    this.eventData,
    this.organization,
    this.organizationName,
  });

  @override
  State<EventDetailBottomSheet> createState() => _EventDetailBottomSheetState();
}

class _EventDetailBottomSheetState extends State<EventDetailBottomSheet> {
  bool isLiked = false;
  bool isAttending = false;
  bool _isSubmittingAttend = false;

  Future<void> _handleAttendTap() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to attend this event.')),
      );
      return;
    }

    setState(() {
      _isSubmittingAttend = true;
    });

    try {
      Map<String, dynamic>? org = widget.organization;
      if (org == null && widget.eventData != null) {
        final o = widget.eventData!['organization'];
        if (o is Map<String, dynamic>) {
          org = o;
        }
      }

      final safeTitle = widget.title.replaceAll(' ', '_').toLowerCase();
      final docId = '${user.id}_${widget.eventId ?? safeTitle}';

      final attendanceData = {
        'user': {
          'userId': user.id,
          'userName': user.name,
          'userEmail': user.email,
          'userPhone': user.phone,
          'userType': user.userType.toString().split('.').last,
          'profileImageUrl': user.profileImageUrl,
          'location': user.location,
        },
        'event': {
          'eventId': widget.eventId,
          'title': widget.title,
          'date': widget.date,
          'description': widget.description,
          'imageAsset': widget.imageAsset,
        },
        'organization': {
          'organizationId': org?['organizationId'],
          'organizationName': org?['organizationName'] ?? widget.organizationName,
          'address': org?['address'],
          'latitude': org?['latitude'],
          'longitude': org?['longitude'],
          'verificationStatus': org?['verificationStatus'],
        },
        'attendStatus': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('mosqueapp_events_attend')
          .doc(docId)
          .set(attendanceData, SetOptions(merge: true));

      setState(() {
        isAttending = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved. See you at the event!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save attendance: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingAttend = false;
        });
      }
    }
  }

  Future<void> _handleUnattendTap() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null) {
      return;
    }
    setState(() {
      _isSubmittingAttend = true;
    });
    final safeTitle = widget.title.replaceAll(' ', '_').toLowerCase();
    final docId = '${user.id}_${widget.eventId ?? safeTitle}';
    try {
      await FirebaseFirestore.instance
          .collection('mosqueapp_events_attend')
          .doc(docId)
          .set({
        'attendStatus': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        isAttending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance removed.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update attendance: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingAttend = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Announcement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event Image
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(
                widget.imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Date
                Text(
                  widget.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    // Likes
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.likes}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 24),

                    // Attending
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.attending} Attending',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Like Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: isLiked ? Colors.red : Colors.grey[300]!,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Like',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isLiked ? Colors.red : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Attend Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (isAttending) {
                            await _handleUnattendTap();
                          } else {
                            await _handleAttendTap();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isAttending
                                ? Color(AppConfig.primaryTealColor)
                                : Color(AppConfig.primaryTealColor),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Color(AppConfig.primaryTealColor)
                                    .withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _isSubmittingAttend
                                ? [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Saving...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ]
                                : [
                                    Icon(
                                      isAttending
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAttending ? 'Attending' : 'Attend',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showEventDetailBottomSheet({
  required BuildContext context,
  required String title,
  required String date,
  required String description,
  required String imageAsset,
  int likes = 120,
  int attending = 50,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => EventDetailBottomSheet(
        title: title,
        date: date,
        description: description,
        imageAsset: imageAsset,
        likes: likes,
        attending: attending,
      ),
    ),
  );
}
