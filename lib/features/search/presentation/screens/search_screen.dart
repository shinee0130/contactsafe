import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contactsafe/features/events/data/local_event_repository.dart';
import 'package:intl/intl.dart';
import 'package:contactsafe/features/events/data/models/event_model.dart';
import 'package:contactsafe/features/events/presentation/screens/events_detail_screen.dart';
import 'package:contactsafe/shared/widgets/customsearchbar.dart';
import 'package:contactsafe/shared/widgets/navigation_bar.dart';

class _FileResult {
  final String id;
  final String name;
  final String contactId;
  final String contactName;

  _FileResult({
    required this.id,
    required this.name,
    required this.contactId,
    required this.contactName,
  });
}

class _NoteResult {
  final String id;
  final String content;
  final String contactId;
  final String contactName;

  _NoteResult({
    required this.id,
    required this.content,
    required this.contactId,
    required this.contactName,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = [];
  List<_FileResult> _allFiles = [];
  List<_NoteResult> _allNotes = [];
  List<AppEvent> _allEvents = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      // Fetch contacts
      bool isGranted = await FlutterContacts.requestPermission();
      if (isGranted) {
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
        setState(() {
          _allContacts = contacts;
        });
      }

      // Fetch files across all contacts
      final fileSnapshots = await FirebaseFirestore.instance
          .collectionGroup('files')
          .get();
      final files = fileSnapshots.docs.map((doc) {
        final data = doc.data();
        final contactId = doc.reference.parent.parent!.id;
        final contact = _allContacts.firstWhere(
          (c) => c.id == contactId,
          orElse: () => Contact(id: contactId, displayName: 'Unknown'),
        );
        return _FileResult(
          id: doc.id,
          name: data['name'] ?? '',
          contactId: contactId,
          contactName: contact.displayName,
        );
      }).toList();

      // Fetch notes across all contacts
      final noteSnapshots = await FirebaseFirestore.instance
          .collectionGroup('notes')
          .get();
      final notes = noteSnapshots.docs.map((doc) {
        final data = doc.data();
        final contactId = doc.reference.parent.parent!.id;
        final contact = _allContacts.firstWhere(
          (c) => c.id == contactId,
          orElse: () => Contact(id: contactId, displayName: 'Unknown'),
        );
        return _NoteResult(
          id: doc.id,
          content: data['content'] ?? '',
          contactId: contactId,
          contactName: contact.displayName,
        );
      }).toList();

      // Load events from local storage
      final events = await LocalEventRepository().loadEvents();

      setState(() {
        _allFiles = files;
        _allNotes = notes;
        _allEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  void _filterContent(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = <dynamic>[];

    // Search contacts
    results.addAll(
      _allContacts.where(
        (contact) =>
            contact.displayName.toLowerCase().contains(lowerQuery) ||
            (contact.phones.isNotEmpty &&
                contact.phones.any(
                  (phone) => phone.number.toLowerCase().contains(lowerQuery),
                )) ||
            (contact.emails.isNotEmpty &&
                contact.emails.any(
                  (email) => email.address.toLowerCase().contains(lowerQuery),
                )),
      ),
    );

    // Search files
    results.addAll(
      _allFiles.where(
        (file) =>
            file.name.toLowerCase().contains(lowerQuery) ||
            file.contactName.toLowerCase().contains(lowerQuery),
      ),
    );

    // Search notes
    results.addAll(
      _allNotes.where(
        (note) =>
            note.content.toLowerCase().contains(lowerQuery) ||
            note.contactName.toLowerCase().contains(lowerQuery),
      ),
    );

    // Search events
    results.addAll(
      _allEvents.where(
        (event) =>
            event.title.toLowerCase().contains(lowerQuery) ||
            (event.description?.toLowerCase().contains(lowerQuery) ?? false) ||
            (event.location?.toLowerCase().contains(lowerQuery) ?? false),
      ),
    );

    setState(() {
      _searchResults = results;
    });
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];

        if (item is Contact) {
          return _buildContactItem(item);
        } else if (item is _FileResult) {
          return _buildFileItem(item);
        } else if (item is _NoteResult) {
          return _buildNoteItem(item);
        } else if (item is AppEvent) {
          return _buildEventItem(item);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContactItem(Contact contact) {
    return ListTile(
      leading:
          contact.photo != null && contact.photo!.isNotEmpty
              ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
              : CircleAvatar(
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName[0].toUpperCase()
                      : '?',
                ),
              ),
      title: Text(contact.displayName),
      subtitle:
          contact.phones.isNotEmpty ? Text(contact.phones.first.number) : null,
      onTap: () {
        // Navigate to contact details
        Navigator.pushNamed(context, '/contact_detail', arguments: contact);
      },
    );
  }

  Widget _buildFileItem(_FileResult file) {
    return ListTile(
      leading: const Icon(Icons.insert_drive_file),
      title: Text(file.name),
      subtitle: Text('From: ${file.contactName}'),
      onTap: () {
        // No dedicated file view, so do nothing
      },
    );
  }

  Widget _buildNoteItem(_NoteResult note) {
    final preview = note.content.length > 50
        ? '${note.content.substring(0, 50)}...'
        : note.content;
    return ListTile(
      leading: const Icon(Icons.note),
      title: Text(preview),
      subtitle: Text('From: ${note.contactName}'),
    );
  }

  Widget _buildEventItem(AppEvent event) {
    return ListTile(
      leading: const Icon(Icons.event),
      title: Text(event.title),
      subtitle: Text(DateFormat.yMMMd().format(event.date)),
      onTap: () {
        // Navigate to event detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventsDetailScreen(
              event: event,
              allDeviceContacts: _allContacts,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ContactSafe',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterContent,
            ),
            const SizedBox(height: 16.0),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/contacts');
              break;
            case 1:
              // Already on search screen
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
