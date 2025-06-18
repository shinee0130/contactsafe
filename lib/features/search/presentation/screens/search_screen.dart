import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contactsafe/l10n/context_loc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';

import 'package:contactsafe/features/events/data/local_event_repository.dart';
import 'package:contactsafe/features/events/data/models/event_model.dart';
import 'package:contactsafe/features/events/presentation/screens/events_detail_screen.dart';
import 'package:contactsafe/shared/widgets/custom_search_bar.dart';
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
        if (!mounted) return; // <-- энд нэмж өгнө
        setState(() {
          _allContacts = contacts;
        });
      }

      // Fetch files for this user only
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final fileSnapshots =
          await FirebaseFirestore.instance
              .collectionGroup('files')
              .where('uid', isEqualTo: uid)
              .get();
      final files =
          fileSnapshots.docs.map((doc) {
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

      // Fetch notes for this user only
      final noteSnapshots =
          await FirebaseFirestore.instance
              .collectionGroup('notes')
              .where('uid', isEqualTo: uid)
              .get();
      final notes =
          noteSnapshots.docs.map((doc) {
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

      if (!mounted) return; // <-- энд бас шалгана
      setState(() {
        _allFiles = files;
        _allNotes = notes;
        _allEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // <-- энд бас шалгана
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching data: $e');
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
      return Center(
        child: Text(
          context.loc.noResults,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 18,
          ),
        ),
      );
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading:
          contact.photo != null && contact.photo!.isNotEmpty
              ? CircleAvatar(
                backgroundImage: MemoryImage(contact.photo!),
                radius: 22,
              )
              : CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.09),
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
      title: Text(
        contact.displayName,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle:
          contact.phones.isNotEmpty
              ? Text(
                contact.phones.first.number,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              )
              : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        size: 22,
      ),
      onTap: () {
        Navigator.pushNamed(context, '/contact_detail', arguments: contact);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Theme.of(context).colorScheme.surface,
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.10),
    );
  }

  Widget _buildFileItem(_FileResult file) {
    return ListTile(
      leading: Icon(
        Icons.insert_drive_file,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        file.name,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: Text(
        '${context.loc.from}: ${file.contactName}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildNoteItem(_NoteResult note) {
    final preview =
        note.content.length > 50
            ? '${note.content.substring(0, 50)}...'
            : note.content;
    return ListTile(
      leading: Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
      title: Text(
        preview,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: Text(
        '${context.loc.from}: ${note.contactName}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildEventItem(AppEvent event) {
    return ListTile(
      leading: Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
      title: Text(
        event.title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: Text(
        DateFormat.yMMMd().format(event.date),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => EventsDetailScreen(
                  event: event,
                  allDeviceContacts: _allContacts,
                ),
          ),
        );
      },
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.loc.appTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6.0),
            Image.asset('assets/contactsafe_logo.png', height: 24),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.loc.search,
              style: const TextStyle(
                fontSize: 31.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterContent,
              hintText: context.loc.search,
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
