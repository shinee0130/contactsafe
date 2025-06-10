import 'package:contactsafe/shared/widgets/customsearchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../../../shared/widgets/navigation_bar.dart';
import 'package:contactsafe/features/events/data/models/event_model.dart'; // Import your AppEvent model
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _currentIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = []; // Stores all device contacts
  List<AppEvent> _events = []; // Stores events fetched from Firestore
  List<AppEvent> _filteredEvents =
      []; // Stores events after applying search filter
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  @override
  void initState() {
    super.initState();
    // Fetch contacts first, then fetch events (as events depend on contact data)
    _fetchContacts().then((_) {
      _fetchEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetches contacts from the device
  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      print('Contacts permission denied');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts permission is required to add participants.'),
        ),
      );
      return;
    }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
      setState(() {
        _allContacts = contacts;
      });
    } catch (e) {
      print('Error fetching contacts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching contacts: ${e.toString()}')),
      );
    }
  }

  // Fetches events from Firestore in real-time
  Future<void> _fetchEvents() async {
    try {
      _firestore
          .collection('events')
          .withConverter(
            fromFirestore: AppEvent.fromFirestore,
            toFirestore: (AppEvent event, options) => event.toFirestore(),
          )
          .snapshots()
          .listen(
            (snapshot) {
              final fetchedEvents =
                  snapshot.docs.map((doc) => doc.data() as AppEvent).toList();

              setState(() {
                _events = fetchedEvents;
                _filterEvents(
                  _searchController.text,
                ); // Re-filter when new events arrive
              });
            },
            onError: (error) {
              print("Error fetching events: $error");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error fetching events: ${error.toString()}'),
                ),
              );
            },
          );
    } catch (e) {
      print("Failed to set up event listener: $e");
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

  // Shows a dialog to add a new event with name, date, participants, and location
  void _addNewEvent() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;
    List<Contact> selectedParticipants = [];
    LatLng? selectedLocation; // Store the selected LatLng
    String? selectedAddress; // Store the selected address (optional)

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateSB) {
              return AlertDialog(
                title: const Text('New Event'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                        ),
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
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
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
                              const SnackBar(
                                content: Text('No contacts available to add.'),
                              ),
                            );
                            return;
                          }

                          final List<Contact>?
                          chosenContacts = await showDialog<List<Contact>>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              List<Contact> tempSelected = List.from(
                                selectedParticipants,
                              );
                              return AlertDialog(
                                title: const Text('Select Participants'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height:
                                      MediaQuery.of(dialogContext).size.height *
                                      0.6,
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
                                    onPressed:
                                        () =>
                                            Navigator.pop(dialogContext, null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(
                                          dialogContext,
                                          tempSelected,
                                        ),
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
                        child: Text(
                          'Add Participants (${selectedParticipants.length})',
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children:
                            selectedParticipants
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

                      // Google Maps Integration
                      const SizedBox(height: 20),
                      const Text('Select Event Location (Tap on map):'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(
                                47.9189,
                                106.9172,
                              ), // Default: Ulaanbaatar, Mongolia
                              zoom: 12,
                            ),
                            markers:
                                selectedLocation == null
                                    ? {}
                                    : {
                                      Marker(
                                        markerId: const MarkerId(
                                          'selected-location',
                                        ),
                                        position: selectedLocation!,
                                        infoWindow: InfoWindow(
                                          title: 'Event Location',
                                          snippet:
                                              selectedAddress ??
                                              'Selected Location',
                                        ),
                                      ),
                                    },
                            onTap: (LatLng tappedLocation) async {
                              String? address;
                              try {
                                final placemarks = await geo
                                    .placemarkFromCoordinates(
                                      tappedLocation.latitude,
                                      tappedLocation.longitude,
                                    );
                                if (placemarks.isNotEmpty) {
                                  final p = placemarks.first;
                                  address =
                                      '${p.street}, ${p.subLocality}, ${p.locality}';
                                  if (p.locality != null &&
                                      p.locality!.isNotEmpty) {
                                    address = address ?? p.locality;
                                  }
                                }
                              } catch (e) {
                                print('Error during geocoding: $e');
                                address =
                                    null; // Ensure it's null if geocoding fails
                              }

                              setStateSB(() {
                                selectedLocation = tappedLocation;
                                selectedAddress =
                                    address; // Store the resolved address
                              });
                            },
                          ),
                        ),
                      ),
                      if (selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Selected Location: ${selectedAddress ?? '${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
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
                        location:
                            selectedAddress ??
                            '${selectedLocation!.latitude}, ${selectedLocation!.longitude}', // Store address or coordinates
                        description:
                            descriptionController.text.isEmpty
                                ? null
                                : descriptionController.text,
                        participantContactIds:
                            selectedParticipants.map((c) => c.id).toList(),
                      );

                      try {
                        await _firestore
                            .collection('events')
                            .add(newAppEvent.toFirestore());
                        print('Event added to Firestore!');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event added successfully!'),
                          ),
                        );
                      } catch (e) {
                        print('Error adding event: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to add event: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Create'),
                  ),
                ],
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
            onPressed: () {}, // TODO: Implement sort functionality
            icon: Icon(Icons.swap_vert, color: Colors.blue, size: 30),
          ),
          IconButton(
            onPressed: _addNewEvent,
            icon: Icon(Icons.add, color: Colors.blue, size: 30),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
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
          print('Bottom navigation tapped: $index');
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
    // Resolve participants using the helper method in AppEvent model
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
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat.yMMMd().format(event.date)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Participants: $participantNames',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
