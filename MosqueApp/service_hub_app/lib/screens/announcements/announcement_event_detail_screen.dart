import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/announcement.dart';
import '../../config/app_config.dart';
import '../../services/bookmarks_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class AnnouncementEventDetailScreen extends StatefulWidget {
  final Announcement event;

  const AnnouncementEventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<AnnouncementEventDetailScreen> createState() => _AnnouncementEventDetailScreenState();
}

class _AnnouncementEventDetailScreenState extends State<AnnouncementEventDetailScreen> {
  bool isInterested = false;
  bool isAttending = false;
  bool _isSubmittingAttend = false;

  Future<void> _shareEvent() async {
    try {
      final String shareText = '''
📅 ${widget.event.title}

📍 ${widget.event.location ?? 'Location TBA'}
🕐 ${widget.event.eventTime ?? widget.event.date}
👤 Organizer: ${widget.event.organizer ?? 'Event Organizer'}

${widget.event.fullContent}

${widget.event.tags != null && widget.event.tags!.isNotEmpty ? '\n🏷️ Tags: ${widget.event.tags!.join(', ')}' : ''}

Don't miss this amazing event! Download our app to stay updated with more community events.
''';
      
      await Share.share(
        shareText,
        subject: widget.event.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share at this time. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    final bookmarked = await BookmarksService.isBookmarked(widget.event.id);
    setState(() {
      isInterested = bookmarked;
    });
  }

  Future<void> _toggleBookmark() async {
    if (isInterested) {
      await BookmarksService.removeBookmark(widget.event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Removed from bookmarked events',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.grey[600],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      await BookmarksService.addBookmark(widget.event);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Added to your bookmarked events!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: widget.event.color,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
    
    setState(() {
      isInterested = !isInterested;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventHeader(),
                _buildEventDetails(),
                _buildEventDescription(),
                _buildActionButtons(),
                const SizedBox(height: 100), // Space for bottom navigation
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
      backgroundColor: widget.event.color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareEvent,
        ),
        IconButton(
          icon: Icon(
            isInterested ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: _toggleBookmark,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.event.color,
                widget.event.color.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: Icon(
                    widget.event.icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        widget.event.color.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.event.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.event.icon,
                  color: widget.event.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event.date,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (widget.event.tags != null && widget.event.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.event.tags!.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.event.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.event.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (widget.event.eventTime != null)
            _buildDetailRow(
              Icons.access_time,
              'Time',
              widget.event.eventTime!,
            ),
          
          if (widget.event.location != null) ...[
            if (widget.event.eventTime != null) const SizedBox(height: 16),
            _buildDetailRow(
              Icons.location_on,
              'Location',
              widget.event.location!,
            ),
          ],
          
          if (widget.event.organizer != null) ...[
            if (widget.event.eventTime != null || widget.event.location != null) 
              const SizedBox(height: 16),
            _buildDetailRow(
              Icons.person,
              'Organizer',
              widget.event.organizer!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.event.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: widget.event.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Event',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.event.fullContent,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Attend button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmittingAttend
                  ? null
                  : (isAttending ? _handleUnattendTap : _handleAttendTap),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAttending ? Colors.green : widget.event.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isAttending ? 0 : 2,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isSubmittingAttend
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        key: ValueKey(isAttending),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAttending ? Icons.check_circle : Icons.event_available,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAttending ? 'Attending' : 'Attend',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bookmark button (Interested)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleBookmark,
              style: ElevatedButton.styleFrom(
                backgroundColor: isInterested ? Colors.grey[400] : widget.event.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isInterested ? 0 : 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInterested ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isInterested ? 'Bookmarked' : 'Mark as Interested',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Share button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _shareEvent,
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.event.color,
                side: BorderSide(color: widget.event.color, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Share Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAttendTap() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to attend.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingAttend = true;
    });

    try {
      Map<String, dynamic>? org;
      try {
        if (widget.event.id.isNotEmpty) {
          final evDoc = await FirebaseFirestore.instance
              .collection('mosqueapp_events')
              .doc(widget.event.id)
              .get();
          if (evDoc.exists) {
            final data = evDoc.data();
            final o = data?['organization'];
            if (o is Map<String, dynamic>) org = o;
          }
        }
      } catch (_) {
        // Silent fallback when event doc can't be fetched
      }

      final safeTitle = widget.event.title.replaceAll(' ', '_').toLowerCase();
      final docId = '${user.id}_${widget.event.id.isNotEmpty ? widget.event.id : safeTitle}';

      final attendanceData = {
        'user': {
          'userId': user.id,
          'userName': user.name,
          'userEmail': user.email,
          'userPhone': user.phone,
        },
        'event': {
          'eventId': widget.event.id,
          'title': widget.event.title,
          'date': widget.event.date,
          'description': widget.event.description,
          'location': widget.event.location,
        },
        'organization': {
          'organizationId': org?['organizationId'],
          'organizationName': org?['organizationName'] ?? widget.event.organizer,
          'address': org?['address'] ?? widget.event.location,
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
        SnackBar(
          content: const Text('You are now attending this event.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to save attendance. Please try again.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in first.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingAttend = true;
    });

    try {
      final safeTitle = widget.event.title.replaceAll(' ', '_').toLowerCase();
      final docId = '${user.id}_${widget.event.id.isNotEmpty ? widget.event.id : safeTitle}';

      await FirebaseFirestore.instance
          .collection('mosqueapp_events_attend')
          .doc(docId)
          .set(
        {
          'attendStatus': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      setState(() {
        isAttending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You are no longer attending.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to update attendance. Please try again.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
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

}