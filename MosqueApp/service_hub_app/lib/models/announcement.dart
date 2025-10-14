import 'package:flutter/material.dart';

enum AnnouncementType {
  shortAnnouncement,
  event,
}

class Announcement {
  final String id;
  final String title;
  final String description;
  final String fullContent;
  final String date;
  final AnnouncementType type;
  final Color color;
  final IconData icon;
  final String? location;
  final String? eventTime;
  final String? organizer;
  final List<String>? tags;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.date,
    required this.type,
    required this.color,
    required this.icon,
    this.location,
    this.eventTime,
    this.organizer,
    this.tags,
  });

  bool get isEvent => type == AnnouncementType.event;
  bool get isShortAnnouncement => type == AnnouncementType.shortAnnouncement;
}