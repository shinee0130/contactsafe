import 'package:contactsafe/utils/color_extensions.dart';
import 'package:contactsafe/shared/widgets/customsearchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:contactsafe/features/events/data/local_event_repository.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/widgets/navigation_bar.dart';
import 'package:contactsafe/features/events/data/models/event_model.dart';
import 'package:contactsafe/features/events/presentation/widgets/location_picker_screen.dart';
import 'package:contactsafe/features/events/presentation/screens/events_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _currentIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = []; // Stores all device contacts
  List<AppEvent> _events = []; // Stores events from local storage
  List<AppEvent> _filteredEvents =
      []; // Stores events after applying search filter
  final LocalEventRepository _eventRepository = LocalEventRepository();
  EventSortOption _sortOption = EventSortOption.dateAsc;

  @override
  void initState() {
    super.initState();
    // Fetch contacts first, then fetch events (as events depend on contact data)
    _fetchContacts().then((_) {
      _fetchEvents();
    });
    _requestLocationPermission(); // Request location permission on screen init
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Requests location permissions (for the 'My Location' button and current location)
  Future<void> _requestLocationPermission() async {
    final status =
        await Permission.locationWhenInUse
            .request(); // Or .location if you need background location

    if (status.isGranted) {
      debugPrint('Location permission granted');
    } else if (status.isDenied) {
      debugPrint('Location permission denied');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is recommended for map features.',
            ),
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      debugPrint('Location permission permanently denied');
      if (mounted) {
        openAppSettings(); // Direct the user to app settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission permanently denied. Please enable it in app settings.',
            ),
          ),
        );
      }
    }
  }

  // Fetches contacts from the device
  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      debugPrint('Contacts permission denied');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Contacts permission is required to add participants.',
            ),
          ),
        );
      }
      return;
    }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
      if (!mounted) {
        return;
      }
      setState(() {
        _allContacts = contacts;
      });
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching contacts: ${e.toString()}')),
        );
      }
    }
  }

  // Loads events from local storage
  Future<void> _fetchEvents() async {
    try {
      final events = await _eventRepository.loadEvents();
      if (!mounted) {
        return;
      }
      setState(() {
        _events = events;
        _sortEvents();
        _filterEvents(_searchController.text);
      });
    } catch (e) {
      debugPrint("Failed to load events: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: ${e.toString()}')),
        );
      }
    }
  }

  // Filters the events based on the search query
  void _filterEvents(String query) {
    setState(() {
      _filteredEvents =
          query.isEmpty
              ? List.from(_events) // If query is empty, show all events
              : _events
                  .where(
                    (event) =>
                        event.title.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ||
                        (event.location?.toLowerCase() ?? '').contains(
                          query.toLowerCase(),
                        ) ||
                        (event.description?.toLowerCase() ?? '').contains(
                          query.toLowerCase(),
                        ) ||
                        // Search by participant names
                        event
                            .getParticipants(_allContacts)
                            .any(
                              (p) => p.displayName.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                            ),
                  )
                  .toList();
    });
  }

  void _sortEvents() {
    switch (_sortOption) {
      case EventSortOption.titleAsc:
        _events.sort((a, b) => a.title.compareTo(b.title));
        break;
      case EventSortOption.titleDesc:
        _events.sort((a, b) => b.title.compareTo(a.title));
        break;
      case EventSortOption.dateAsc:
        _events.sort((a, b) => a.date.compareTo(b.date));
        break;
      case EventSortOption.dateDesc:
        _events.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort Events By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...EventSortOption.values.map(
                (option) => ListTile(
                  title: Text(_getSortOptionName(option)),
                  trailing: _sortOption == option
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _sortOption = option;
                      _sortEvents();
                      _filterEvents(_searchController.text);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSortOptionName(EventSortOption option) {
    switch (option) {
      case EventSortOption.titleAsc:
        return 'Title (A-Z)';
      case EventSortOption.titleDesc:
        return 'Title (Z-A)';
      case EventSortOption.dateAsc:
        return 'Date (Oldest first)';
      case EventSortOption.dateDesc:
        return 'Date (Newest first)';
    }
  }

  // Shows a dialog to add a new event with name, date, participants, and location
  void _addNewEvent() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;
    List<Contact> selectedParticipants = [];
    LatLng? selectedLocation;
    String? selectedAddress; // This will hold the address string

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSB) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: (0.1 * 255).round()),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Event Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description (Optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? 'Select Date'
                            : 'Date: ${DateFormat.yMMMd().format(selectedDate!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setStateSB(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (_allContacts.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No contacts available to add.')),
                          );
                          return;
                        }

                        final List<Contact>? chosenContacts = await showDialog<List<Contact>>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            List<Contact> tempSelected = List.from(selectedParticipants);
                            return AlertDialog(
                              title: const Text('Select Participants'),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: MediaQuery.of(dialogContext).size.height * 0.6,
                                child: ListView.builder(
                                  itemCount: _allContacts.length,
                                  itemBuilder: (context, index) {
                                    final contact = _allContacts[index];
                                    return CheckboxListTile(
                                      title: Text(contact.displayName),
                                      value: tempSelected.contains(contact),
                                      onChanged: (bool? value) {
                                        setStateSB(() {
                                          if (value == true) {
                                            tempSelected.add(contact);
                                          } else {
                                            tempSelected.remove(contact);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, null),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, tempSelected),
                                  child: const Text('Select'),
                                ),
                              ],
                            );
                          },
                        );

                        if (chosenContacts != null) {
                          setStateSB(() {
                            selectedParticipants = chosenContacts;
                          });
                        }
                      },
                      child: Text('Add Participants (${selectedParticipants.length})'),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: selectedParticipants
                          .map(
                            (contact) => Chip(
                              label: Text(contact.displayName),
                              onDeleted: () {
                                setStateSB(() {
                                  selectedParticipants.remove(contact);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationPickerScreen(
                              initialLocation: selectedLocation,
                              initialAddress: selectedAddress,
                            ),
                          ),
                        );

                        if (result != null && result['location'] != null) {
                          setStateSB(() {
                            selectedLocation = result['location'];
                            selectedAddress = result['address'];
                          });
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Choose Location on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                    if (selectedLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Location: ${selectedAddress ?? '${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isEmpty ||
                                selectedDate == null ||
                                selectedLocation == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a title, select a date, and select a location.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final newAppEvent = AppEvent(
                              title: titleController.text,
                              date: selectedDate!,
                              location: selectedAddress ??
                                  '${selectedLocation!.latitude}, ${selectedLocation!.longitude}',
                              description: descriptionController.text.isEmpty
                                  ? null
                                  : descriptionController.text,
                              participantContactIds:
                                  selectedParticipants.map((c) => c.id).toList(),
                              userId: '',
                            );

                            try {
                          await _eventRepository.addEvent(newAppEvent);
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                                _events.add(newAppEvent);
                                _sortEvents();
                                _filterEvents(_searchController.text);
                          });
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Event added successfully!')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to add event: ${e.toString()}'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10.0),
            Text(
              'ContactSafe',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showSortDialog,
            icon: Icon(Icons.swap_vert, color: Colors.blue, size: 30),
          ),
          IconButton(
            onPressed: _addNewEvent,
            icon: Icon(Icons.add, color: Colors.blue, size: 30),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events',
              style: TextStyle(
                fontSize: 31.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterEvents,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child:
                  _filteredEvents.isEmpty && _events.isEmpty
                      ? Center(
                        child: Text(
                          'No events found. Create one!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredEvents.length,
                        itemBuilder: (context, index) {
                          final appEvent = _filteredEvents[index];
                          // Pass _allContacts to the EventCard to resolve participant names
                          return EventCard(
                            event: appEvent,
                            allDeviceContacts: _allContacts,
                          );
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
          debugPrint('Bottom navigation tapped: $index');
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/contacts');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              // Already on events screen, no need to navigate
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

// EventCard widget (updated to accept AppEvent and resolve participant names)
class EventCard extends StatelessWidget {
  final AppEvent event; // Now uses AppEvent
  final List<Contact> allDeviceContacts; // To resolve participant names

  const EventCard({
    super.key,
    required this.event,
    required this.allDeviceContacts,
  });

  @override
  Widget build(BuildContext context) {
    final List<Contact> eventParticipants = event.getParticipants(
      allDeviceContacts,
    );
    final String participantNames =
        eventParticipants.isEmpty
            ? 'None'
            : eventParticipants.map((c) => c.displayName).join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Theme.of(context).colorScheme.surface,
      // Make the card tappable to view details
      child: InkWell(
        // Use InkWell for tap feedback
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EventsDetailScreen(
                    event: event,
                    allDeviceContacts: allDeviceContacts,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (event.location != null && event.location!.isNotEmpty)
                Text(
                  'Location: ${event.location}',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: (0.7 * 255).round()),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat.yMMMd().format(event.date)}',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Participants: $participantNames',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (event.description != null && event.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Description: ${event.description}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: (0.7 * 255).round()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
enum EventSortOption { titleAsc, titleDesc, dateAsc, dateDesc }
