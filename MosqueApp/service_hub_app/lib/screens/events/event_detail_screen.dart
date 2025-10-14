import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Color(AppConfig.primaryTealColor),
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.userModel?.id == event.createdBy) {
                return PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Event'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Cancel Event'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Event'),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Report Event'),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(),
            _buildImageGallery(),
            _buildAttendeeInfo(),
            _buildLocationInfo(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getCategoryName(event.category),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(event.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStatusName(event.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.organizationName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatDateTime(event.startDateTime)} - ${_formatDateTime(event.endDateTime)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    if (event.imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: event.imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(event.imageUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAttendeeInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendee Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people, size: 20),
              const SizedBox(width: 8),
              Text(
                event.maxAttendees > 0
                    ? '${event.attendees.length} / ${event.maxAttendees} registered'
                    : '${event.attendees.length} registered',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (event.requiresRegistration) ...[
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.how_to_reg, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Registration required',
                  style: TextStyle(fontSize: 16, color: Colors.orange),
                ),
              ],
            ),
          ],
          if (event.isFull) ...[
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.event_busy, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Event is full',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Consumer2<AuthProvider, EventProvider>(
      builder: (context, authProvider, eventProvider, child) {
        final isRegistered = event.attendees.any(
          (attendee) => attendee.userId == authProvider.userModel?.id,
        );

        if (authProvider.userModel?.id == event.createdBy) {
          // Event creator actions
          return Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to attendee list or event management
                _showAttendeeList(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConfig.primaryTealColor),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Manage Attendees'),
            ),
          );
        } else if (event.requiresRegistration) {
          // Registration required
          return Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: event.isFull || !event.isUpcoming
                  ? null
                  : () {
                      if (isRegistered) {
                        _unregisterFromEvent(context, eventProvider);
                      } else {
                        _registerForEvent(context, eventProvider);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered
                    ? Colors.red
                    : Color(AppConfig.primaryTealColor),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                event.isFull
                    ? 'Event Full'
                    : !event.isUpcoming
                        ? 'Event Ended'
                        : isRegistered
                            ? 'Unregister'
                            : 'Register',
              ),
            ),
          );
        } else {
          // No registration required
          return Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No registration required - just show up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        // Navigate to edit event screen
        break;
      case 'cancel':
        _showCancelEventDialog(context);
        break;
      case 'delete':
        _showDeleteEventDialog(context);
        break;
      case 'report':
        _showReportEventDialog(context);
        break;
    }
  }

  void _registerForEvent(BuildContext context, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register for Event'),
        content: const Text('Would you like to register for this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              eventProvider.registerForEvent(event.id, authProvider.currentUser?.id ?? '');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully registered for event!'),
                ),
              );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void _unregisterFromEvent(BuildContext context, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unregister from Event'),
        content: const Text('Are you sure you want to unregister from this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              eventProvider.unregisterFromEvent(event.id, authProvider.currentUser?.id ?? '');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully unregistered from event.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Unregister'),
          ),
        ],
      ),
    );
  }

  void _showAttendeeList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendees (${event.attendees.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: event.attendees.length,
                itemBuilder: (context, index) {
                  final attendee = event.attendees[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(attendee.userName[0].toUpperCase()),
                    ),
                    title: Text(attendee.userName),
                    subtitle: Text(
                      'Registered: ${_formatDateTime(attendee.registeredAt)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (attendee.emailReminder)
                          const Icon(Icons.email, size: 16),
                        if (attendee.smsReminder)
                          const Icon(Icons.sms, size: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text('Are you sure you want to cancel this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EventProvider>().cancelEvent(event.id, 'Event cancelled by organizer');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Cancel Event'),
          ),
        ],
      ),
    );
  }

  void _showDeleteEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EventProvider>().deleteEvent(event.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReportEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Event'),
        content: const Text('Are you sure you want to report this event as inappropriate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Since reportEvent method doesn't exist, we'll remove this functionality for now
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report functionality not implemented yet.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(EventCategory category) {
    switch (category) {
      case EventCategory.prayer:
        return 'Prayer';
      case EventCategory.education:
        return 'Education';
      case EventCategory.community:
        return 'Community';
      case EventCategory.charity:
        return 'Charity';
      case EventCategory.celebration:
        return 'Celebration';
      case EventCategory.meeting:
        return 'Meeting';
      case EventCategory.other:
        return 'Other';
    }
  }

  String _getStatusName(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return Colors.green;
      case EventStatus.ongoing:
        return Colors.blue;
      case EventStatus.completed:
        return Colors.grey;
      case EventStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}