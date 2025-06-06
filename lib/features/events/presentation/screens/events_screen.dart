import 'package:contactsafe/core/theme/app_colors.dart';
import 'package:contactsafe/shared/widgets/customsearchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/navigation_bar.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _currentIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];
  List<Contact> _allContacts = [];
  List<Event> _events = []; // New list for events
  List<Event> _filteredEvents = []; // New list for filtered events

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    // _loadSampleEvents(); // Load some sample events // Will be called after contacts are fetched
  }

  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission()) return;
    
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );
    
    contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    setState(() {
      _allContacts = contacts;
      _filteredContacts = List.from(contacts); // Keep for now, might be used elsewhere or removed later
    });
    _loadSampleEvents(); // Load events after contacts are fetched
  }

  void _filterEvents(String query) { // Renamed and modified from _filterContacts
    setState(() {
      _filteredEvents = query.isEmpty
          ? List.from(_events)
          : _events
              .where((event) => event.title
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
    });
  }

  void _loadSampleEvents() {
    // TODO: Replace with actual event loading logic
    // Ensure _allContacts is not empty before using it for participants
    List<Contact> sampleParticipants1 = _allContacts.length >= 3 ? _allContacts.take(3).toList() : [];
    List<Contact> sampleParticipants2 = _allContacts.length >= 5 ? _allContacts.take(5).toList() : [];

    setState(() {
      _events = [
        Event(
          title: 'Team Meeting',
          date: DateTime.now().add(const Duration(days: 1)),
          participants: sampleParticipants1,
        ),
        Event(
          title: 'Product Launch',
          date: DateTime.now().add(const Duration(days: 7)),
          participants: sampleParticipants2,
        ),
      ];
      _filteredEvents = List.from(_events); // Initialize filteredEvents
    });
  }

  void _addNewEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Event'),
        content: const Text('Event creation dialog will go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual event creation
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10.0,),
            const Text(
              'ContactSafe',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {}, // TODO: Implement sort functionality
            icon: const Icon(Icons.swap_vert, color: AppColors.primary, size: 30),
          ),
          IconButton(
            onPressed: _addNewEvent,
            icon: const Icon(Icons.add, color: AppColors.primary, size: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Events',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterEvents, // Changed to _filterEvents
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _filteredEvents.isEmpty // Changed to _filteredEvents
                  ? const Center(child: Text('No events found'))
                  : ListView.builder(
                      itemCount: _filteredEvents.length, // Changed to _filteredEvents.length
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index]; // Changed to _filteredEvents[index]
                        return EventCard(event: event);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
        setState(() => _currentIndex = index);
        print('Bottom navigation tapped: $index');
        switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/contacts');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/search');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/events');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/photos');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
        },
      ),
    );
  }
}

// New Event model class
class Event {
  final String title;
  final DateTime date;
  final List<Contact> participants;

  Event({
    required this.title,
    required this.date,
    required this.participants,
  });
}

// New EventCard widget
class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat.yMMMd().format(event.date)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Participants: ${event.participants.length}',
            ),
          ],
        ),
      ),
    );
  }
}