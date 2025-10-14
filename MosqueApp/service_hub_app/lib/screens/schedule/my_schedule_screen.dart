import 'package:flutter/material.dart';
import '../../config/app_config.dart';

enum ViewType { day, week, month }

enum EventFilter { all, myEvents }

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({Key? key}) : super(key: key);

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  ViewType _currentView = ViewType.day;
  EventFilter _currentFilter = EventFilter.all;
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _prayerTimes = [
    {'name': 'Fajr', 'time': '05:30', 'icon': Icons.wb_twilight},
    {'name': 'Dhuhr', 'time': '12:45', 'icon': Icons.wb_sunny},
    {'name': 'Asr', 'time': '16:15', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Maghrib', 'time': '18:30', 'icon': Icons.wb_twilight},
    {'name': 'Isha', 'time': '20:00', 'icon': Icons.nightlight_round},
  ];

  final List<Map<String, dynamic>> _allEvents = [
    {
      'id': '1',
      'mosqueName': 'Islamic Center of Greater Cincinnati',
      'event': 'Friday Prayer (Jummah)',
      'time': '13:00',
      'date': DateTime.now(),
      'address': '8092 Montgomery Rd, Cincinnati, OH 45236',
      'isMyEvent': true,
      'type': 'prayer',
    },
    {
      'id': '2',
      'mosqueName': 'Masjid Al-Noor',
      'event': 'Quran Study Circle',
      'time': '19:30',
      'date': DateTime.now().add(Duration(days: 1)),
      'address': '2334 E 75th St, Chicago, IL 60649',
      'isMyEvent': false,
      'type': 'education',
    },
    {
      'id': '3',
      'mosqueName': 'Islamic Society of Boston',
      'event': 'Community Iftar',
      'time': '18:45',
      'date': DateTime.now().add(Duration(days: 2)),
      'address': '204 Prospect St, Cambridge, MA 02139',
      'isMyEvent': true,
      'type': 'community',
    },
    {
      'id': '4',
      'mosqueName': 'Dar Al-Hijrah Islamic Center',
      'event': 'Youth Basketball Tournament',
      'time': '15:00',
      'date': DateTime.now().add(Duration(days: 3)),
      'address': '3159 Row St, Falls Church, VA 22044',
      'isMyEvent': false,
      'type': 'sports',
    },
    {
      'id': '5',
      'mosqueName': 'Islamic Center of America',
      'event': 'Islamic History Lecture',
      'time': '20:00',
      'date': DateTime.now().add(Duration(days: 4)),
      'address': '19500 Ford Rd, Dearborn, MI 48128',
      'isMyEvent': true,
      'type': 'education',
    },
    {
      'id': '6',
      'mosqueName': 'Masjid Al-Farah',
      'event': 'Charity Drive',
      'time': '10:00',
      'date': DateTime.now().add(Duration(days: 5)),
      'address': '2045 W Peterson Ave, Chicago, IL 60659',
      'isMyEvent': false,
      'type': 'charity',
    },
    {
      'id': '7',
      'mosqueName': 'Islamic Center of Long Island',
      'event': 'Marriage Workshop',
      'time': '14:00',
      'date': DateTime.now().add(Duration(days: 6)),
      'address': '835 Brush Hollow Rd, Westbury, NY 11590',
      'isMyEvent': true,
      'type': 'workshop',
    },
    {
      'id': '8',
      'mosqueName': 'Masjid Omar Ibn Al-Khattab',
      'event': 'Eid Celebration Planning',
      'time': '19:00',
      'date': DateTime.now().add(Duration(days: 7)),
      'address': '11941 Foothill Blvd, Los Angeles, CA 91342',
      'isMyEvent': false,
      'type': 'planning',
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    List<Map<String, dynamic>> events = _allEvents;

    if (_currentFilter == EventFilter.myEvents) {
      events = events.where((event) => event['isMyEvent'] == true).toList();
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildViewToggleAndFilter(),
              const SizedBox(height: 24),
              // _buildPrayerTimesSection(),
              // const SizedBox(height: 32),
              _buildScheduleContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppConfig.primaryTealColor),
            Color(AppConfig.primaryTealColor).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(AppConfig.primaryTealColor).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mosque events',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // View Toggle Buttons
          Row(
            children: [
              const Icon(Icons.view_agenda, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              const Text(
                'View:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    _buildViewToggleButton('Day', ViewType.day),
                    const SizedBox(width: 8),
                    _buildViewToggleButton('Week', ViewType.week),
                    const SizedBox(width: 8),
                    _buildViewToggleButton('Month', ViewType.month),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Dropdown
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filter:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EventFilter>(
                      value: _currentFilter,
                      isExpanded: true,
                      onChanged: (EventFilter? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _currentFilter = newValue;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: EventFilter.all,
                          child: Text('All Community Events'),
                        ),
                        DropdownMenuItem(
                          value: EventFilter.myEvents,
                          child: Text('My Events Only'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(String label, ViewType viewType) {
    final bool isSelected = _currentView == viewType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentView = viewType;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(AppConfig.primaryTealColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Color(AppConfig.primaryTealColor)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: Color(AppConfig.primaryTealColor),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Prayer Times',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _prayerTimes
                .map((prayer) => _buildPrayerTimeCard(prayer))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimeCard(Map<String, dynamic> prayer) {
    final bool isNext = prayer['name'] == 'Dhuhr'; // Example: next prayer

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext
            ? Color(AppConfig.primaryTealColor).withOpacity(0.05)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color:
                isNext ? Color(AppConfig.primaryTealColor) : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNext
                  ? Color(AppConfig.primaryTealColor).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              prayer['icon'],
              color:
                  isNext ? Color(AppConfig.primaryTealColor) : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              prayer['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
                color:
                    isNext ? Color(AppConfig.primaryTealColor) : Colors.black87,
              ),
            ),
          ),
          Text(
            prayer['time'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isNext ? Color(AppConfig.primaryTealColor) : Colors.black87,
            ),
          ),
          if (isNext) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(AppConfig.primaryTealColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleContent() {
    switch (_currentView) {
      case ViewType.day:
        return _buildDayView();
      case ViewType.week:
        return _buildWeekView();
      case ViewType.month:
        return _buildMonthView();
    }
  }

  Widget _buildDayView() {
    final todayEvents = _filteredEvents.where((event) {
      final eventDate = event['date'] as DateTime;
      return eventDate.year == _selectedDate.year &&
          eventDate.month == _selectedDate.month &&
          eventDate.day == _selectedDate.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.today,
              color: Color(AppConfig.primaryTealColor),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Today\'s Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todayEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events scheduled for today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children:
                todayEvents.map((event) => _buildEventCard(event)).toList(),
          ),
      ],
    );
  }

  Widget _buildWeekView() {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekEvents = <DateTime, List<Map<String, dynamic>>>{};

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      weekEvents[day] = _filteredEvents.where((event) {
        final eventDate = event['date'] as DateTime;
        return eventDate.year == day.year &&
            eventDate.month == day.month &&
            eventDate.day == day.day;
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.view_week,
              color: Color(AppConfig.primaryTealColor),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Week View',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: weekEvents.entries.map((entry) {
              final day = entry.key;
              final events = entry.value;
              final isToday = day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isToday
                      ? Color(AppConfig.primaryTealColor).withOpacity(0.05)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isToday
                                ? Color(AppConfig.primaryTealColor)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_getDayName(day.weekday)} ${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isToday ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${events.length} event${events.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (events.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...events
                          .map((event) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color:
                                            Color(AppConfig.primaryTealColor),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${event['time']} - ${event['event']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Color(AppConfig.primaryTealColor),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Month View - ${_getMonthName(now.month)} ${now.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Weekday headers
                Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Calendar grid
                ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1,
                    (weekIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: List.generate(7, (dayIndex) {
                        final dayNumber =
                            weekIndex * 7 + dayIndex - firstWeekday + 2;
                        if (dayNumber < 1 || dayNumber > daysInMonth) {
                          return const Expanded(child: SizedBox(height: 40));
                        }

                        final dayDate =
                            DateTime(now.year, now.month, dayNumber);
                        final dayEvents = _filteredEvents.where((event) {
                          final eventDate = event['date'] as DateTime;
                          return eventDate.year == dayDate.year &&
                              eventDate.month == dayDate.month &&
                              eventDate.day == dayDate.day;
                        }).toList();

                        final isToday = dayNumber == now.day;

                        return Expanded(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Color(AppConfig.primaryTealColor)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: dayEvents.isNotEmpty && !isToday
                                  ? Border.all(
                                      color: Color(AppConfig.primaryTealColor),
                                      width: 1)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    dayNumber.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isToday
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (dayEvents.isNotEmpty && !isToday)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color:
                                            Color(AppConfig.primaryTealColor),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Events list for selected month
        if (_filteredEvents.isNotEmpty) ...[
          const Text(
            'Events This Month',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: _filteredEvents
                .where((event) {
                  final eventDate = event['date'] as DateTime;
                  return eventDate.year == now.year &&
                      eventDate.month == now.month;
                })
                .map((event) => _buildEventCard(event))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final eventDate = event['date'] as DateTime;
    final isMyEvent = event['isMyEvent'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(AppConfig.primaryTealColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event,
                color: Color(AppConfig.primaryTealColor),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event['event'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isMyEvent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(AppConfig.primaryTealColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'My Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['mosqueName'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(AppConfig.primaryTealColor),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event['address'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  event['time'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${eventDate.day}/${eventDate.month}/${eventDate.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}
