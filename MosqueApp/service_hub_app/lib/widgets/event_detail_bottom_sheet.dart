import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/mosques/mosque_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' as io;
import 'dart:async';

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
  final BuildContext parentContext;

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
    required this.parentContext,
  });

  @override
  State<EventDetailBottomSheet> createState() => _EventDetailBottomSheetState();
}

class _EventDetailBottomSheetState extends State<EventDetailBottomSheet> {
  bool isLiked = false;
  bool isAttending = false;
  bool _isSubmittingAttend = false;
  bool _isSubmittingLike = false;

  // Real-time data from Firebase
  Map<String, dynamic>? _realTimeEventData;
  String? _mosqueName;
  String? _mosqueAddress;
  String? _realTimeDate;
  StreamSubscription<DocumentSnapshot>? _eventSubscription;
  // Real-time attending count
  int? _attendingCount;
  StreamSubscription<QuerySnapshot>? _attendSubscription;
  double? _mosqueLat;
  double? _mosqueLng;
  // Real-time likes count
  int? _likesCount;
  StreamSubscription<QuerySnapshot>? _likeSubscription;

  @override
  void initState() {
    super.initState();
    _initializeRealTimeData();
    _initializeAttendanceListener();
    _checkAttendanceStatus();
    _initializeLikeListener();
    _checkLikeStatus();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _attendSubscription?.cancel();
    _likeSubscription?.cancel();
    super.dispose();
  }

  void _initializeRealTimeData() {
    if (widget.eventId != null) {
      // Listen to real-time updates from Firebase
      _eventSubscription = FirebaseFirestore.instance
          .collection('mosqueapp_events')
          .doc(widget.eventId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            _realTimeEventData = snapshot.data() as Map<String, dynamic>?;

            // Extract mosque information
            final organization =
                _realTimeEventData?['organization'] as Map<String, dynamic>?;
            _mosqueName =
                organization?['organizationName'] ?? widget.organizationName;
            _mosqueAddress = organization?['address'];
            _mosqueLat = _parseDouble(organization?['latitude']);
            _mosqueLng = _parseDouble(organization?['longitude']);

            // Extract and format real-time date
            final dateData = _realTimeEventData?['date'];
            if (dateData is Timestamp) {
              final dateTime = dateData.toDate();
              final timeData =
                  _realTimeEventData?['time'] as Map<String, dynamic>?;
              if (timeData != null) {
                final hour = timeData['hour'] ?? 0;
                final minute = timeData['minute'] ?? 0;
                final formattedTime =
                    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                _realTimeDate = '${_formatDate(dateTime)} at $formattedTime';
              } else {
                _realTimeDate = _formatDate(dateTime);
              }
            } else if (dateData is String) {
              _realTimeDate = dateData;
            }
          });
        }
      });
    } else {
      // Fallback to provided data
      _mosqueName =
          widget.organization?['organizationName'] ?? widget.organizationName;
      _mosqueAddress = widget.organization?['address'];
      _mosqueLat = _parseDouble(widget.organization?['latitude']);
      _mosqueLng = _parseDouble(widget.organization?['longitude']);
      _realTimeDate = widget.date;
    }
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    final dayName = days[dateTime.weekday % 7];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    return '$dayName, $day $month $year';
  }

  void _initializeAttendanceListener() {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('mosqueapp_events_attend')
          .where('attendStatus', isEqualTo: true);

      if (widget.eventId != null) {
        query = query.where('event.eventId', isEqualTo: widget.eventId);
      } else {
        // Fallback ke judul event jika eventId tidak ada
        query = query.where('event.title', isEqualTo: widget.title);
      }

      _attendSubscription = query.snapshots().listen((snapshot) {
        final count = snapshot.docs.length;
        if (mounted && _attendingCount != count) {
          setState(() {
            _attendingCount = count;
          });
        }
      }, onError: (e) {
        debugPrint('Attendance listener error: $e');
      });
    } catch (e) {
      debugPrint('Failed to init attendance listener: $e');
    }
  }

  void _initializeLikeListener() {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('mosqueapp_likes_mosques')
          .where('likeStatus', isEqualTo: true);

      if (widget.eventId != null) {
        query = query.where('event.eventId', isEqualTo: widget.eventId);
      } else {
        query = query.where('event.title', isEqualTo: widget.title);
      }

      _likeSubscription = query.snapshots().listen((snapshot) {
        final count = snapshot.docs.length;
        if (mounted && _likesCount != count) {
          setState(() {
            _likesCount = count;
          });
        }
      }, onError: (e) {
        debugPrint('Likes listener error: $e');
      });
    } catch (e) {
      debugPrint('Failed to init likes listener: $e');
    }
  }

  Future<void> _checkAttendanceStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;
      if (user == null || user.email == null) {
        return;
      }

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('mosqueapp_events_attend')
          .where('user.userEmail', isEqualTo: user.email);

      if (widget.eventId != null) {
        query = query.where('event.eventId', isEqualTo: widget.eventId);
      } else {
        // Fallback ketika eventId tidak tersedia, gunakan kecocokan judul event
        query = query.where('event.title', isEqualTo: widget.title);
      }

      final snapshot = await query.limit(1).get();

      bool newStatus = false;
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final attendStatus = data['attendStatus'];
        if (attendStatus is bool) {
          newStatus = attendStatus;
        }
      }

      if (mounted && newStatus != isAttending) {
        setState(() {
          isAttending = newStatus;
        });
      }
    } catch (e) {
      debugPrint('Attendance status check failed: $e');
    }
  }

  Future<void> _checkLikeStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;
      if (user == null || user.email == null) {
        return;
      }

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('mosqueapp_likes_mosques')
          .where('user.userEmail', isEqualTo: user.email);

      if (widget.eventId != null) {
        query = query.where('event.eventId', isEqualTo: widget.eventId);
      } else {
        query = query.where('event.title', isEqualTo: widget.title);
      }

      final snapshot = await query.limit(1).get();

      bool newStatus = false;
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final likeStatus = data['likeStatus'];
        if (likeStatus is bool) {
          newStatus = likeStatus;
        }
      }

      if (mounted && newStatus != isLiked) {
        setState(() {
          isLiked = newStatus;
        });
      }
    } catch (e) {
      debugPrint('Like status check failed: $e');
    }
  }

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
          'organizationName':
              org?['organizationName'] ?? widget.organizationName,
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

  Future<void> _handleLikeTap() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to like this event.')),
      );
      return;
    }

    setState(() {
      _isSubmittingLike = true;
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

      final likeData = {
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
        'likeStatus': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('mosqueapp_likes_mosques')
          .doc(docId)
          .set(likeData, SetOptions(merge: true));

      setState(() {
        isLiked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks! You liked this announcement.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save like: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingLike = false;
        });
      }
    }
  }

  Future<void> _handleUnlikeTap() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null) {
      return;
    }

    setState(() {
      _isSubmittingLike = true;
    });

    final safeTitle = widget.title.replaceAll(' ', '_').toLowerCase();
    final docId = '${user.id}_${widget.eventId ?? safeTitle}';

    try {
      await FirebaseFirestore.instance
          .collection('mosqueapp_likes_mosques')
          .doc(docId)
          .set({
        'likeStatus': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        isLiked = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Like removed.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingLike = false;
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

                // Date and Location
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Real-time date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _realTimeDate ?? widget.date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Mosque location
                    if (_mosqueName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Dismiss bottom sheet first
                                    Navigator.pop(context);
                                    // Then navigate to mosque profile using parent context
                                    Future.microtask(() {
                                      Navigator.push(
                                        widget.parentContext,
                                        MaterialPageRoute(
                                          builder: (_) => MosqueDetailScreen(
                                            mosqueName: _mosqueName!,
                                            mosqueAddress: _mosqueAddress ??
                                                'Unknown Address',
                                            mosqueDescription: null,
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                  child: Text(
                                    _mosqueName!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (_mosqueAddress != null) ...[
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: _showMapsOptionsBottomSheet,
                                    child: Text(
                                      _mosqueAddress!,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
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
                          '${_likesCount ?? widget.likes}',
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
                          '${_attendingCount ?? widget.attending} Attending',
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
                        onTap: _isSubmittingLike
                            ? null
                            : () async {
                                if (isLiked) {
                                  await _handleUnlikeTap();
                                } else {
                                  await _handleLikeTap();
                                }
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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

  double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      return double.tryParse(v);
    }
    return null;
  }

  void _showMapsOptionsBottomSheet() {
    final address = _mosqueAddress ?? _mosqueName ?? 'Destination';
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.place, color: Color(AppConfig.primaryTealColor)),
                  const SizedBox(width: 8),
                  const Text(
                    'Open Directions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openGoogleMaps(address),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.map),
                          SizedBox(width: 8),
                          Text('Open in Google Maps'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openAppleMaps(address),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.navigation),
                          SizedBox(width: 8),
                          Text('Open in Apple Maps'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openGoogleMaps(String address) async {
    final hasLatLng = _mosqueLat != null && _mosqueLng != null;
    Uri primary;
    final List<Uri> fallbacks = [];

    if (io.Platform.isIOS) {
      // iOS: Try Google Maps app, then web fallback
      primary = hasLatLng
          ? Uri.parse(
              'comgooglemaps://?daddr=${_mosqueLat},${_mosqueLng}&directionsmode=driving')
          : Uri.parse(
              'comgooglemaps://?daddr=${Uri.encodeComponent(address)}&directionsmode=driving');
      fallbacks.add(Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${hasLatLng ? '${_mosqueLat},${_mosqueLng}' : Uri.encodeComponent(address)}'));
    } else {
      // Android: Try Google Navigation intent, then geo, then web fallbacks
      primary = hasLatLng
          ? Uri.parse('google.navigation:q=${_mosqueLat},${_mosqueLng}&mode=d')
          : Uri.parse(
              'google.navigation:q=${Uri.encodeComponent(address)}&mode=d');

      if (hasLatLng) {
        fallbacks.add(Uri.parse(
            'geo:${_mosqueLat},${_mosqueLng}?q=${_mosqueLat},${_mosqueLng}(Destination)'));
      } else {
        fallbacks.add(Uri.parse('geo:0,0?q=${Uri.encodeComponent(address)}'));
      }

      fallbacks.add(Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${hasLatLng ? '${_mosqueLat},${_mosqueLng}' : Uri.encodeComponent(address)}'));
      fallbacks.add(Uri.parse(
          'https://maps.google.com/?daddr=${hasLatLng ? '${_mosqueLat},${_mosqueLng}' : Uri.encodeComponent(address)}'));
    }

    if (!await _tryLaunch(primary)) {
      for (final f in fallbacks) {
        if (await _tryLaunch(f)) return;
      }
    }
  }

  Future<void> _openAppleMaps(String address) async {
    final hasLatLng = _mosqueLat != null && _mosqueLng != null;
    Uri uri;
    if (io.Platform.isIOS) {
      // iOS Apple Maps app scheme
      uri = hasLatLng
          ? Uri.parse('maps://?daddr=${_mosqueLat},${_mosqueLng}&dirflg=d')
          : Uri.parse('maps://?daddr=${Uri.encodeComponent(address)}&dirflg=d');
    } else {
      // Fallback to Apple Maps web on non‑iOS
      uri = Uri.parse(
          'https://maps.apple.com/?daddr=${hasLatLng ? '${_mosqueLat},${_mosqueLng}' : Uri.encodeComponent(address)}');
    }
    if (!await _tryLaunch(uri)) {
      final webUri = Uri.parse(
          'https://maps.apple.com/?daddr=${hasLatLng ? '${_mosqueLat},${_mosqueLng}' : Uri.encodeComponent(address)}');
      await _tryLaunch(webUri);
    }
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      final scheme = (uri.scheme).toLowerCase();
      final isWeb = scheme == 'http' || scheme == 'https';
      final isMapIntent = scheme == 'google.navigation' ||
          scheme == 'geo' ||
          scheme == 'comgooglemaps' ||
          scheme == 'maps';

      if (isWeb) {
        // In-app webview with non-null WebViewConfiguration
        final ok = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration:
              const WebViewConfiguration(enableJavaScript: true),
        );
        if (ok) return true;
        // Fallback to external browser
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      // Non-web intents
      final mode = isMapIntent
          ? LaunchMode.externalNonBrowserApplication
          : LaunchMode.externalApplication;
      final ok = await launchUrl(uri, mode: mode);
      if (ok) return true;
      // Fallback to platform default
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Launch error: $e');
    }
    return false;
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
  String? eventId,
  Map<String, dynamic>? eventData,
  Map<String, dynamic>? organization,
  String? organizationName,
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
        eventId: eventId,
        eventData: eventData,
        organization: organization,
        organizationName: organizationName,
        parentContext: context,
      ),
    ),
  );
}
