import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:contactsafe/shared/widgets/customsearchbar.dart';
import 'package:contactsafe/shared/widgets/navigation_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = [];
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
          _isLoading = false;
        });
      }

      // TODO: Add calls to fetch files, photos, events from your data sources
      // Example:
      // _allFiles = await FileService.getAllFiles();
      // _allEvents = await EventService.getAllEvents();
      // _allPhotos = await PhotoService.getAllPhotos();
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

    // TODO: Add search for other content types
    // Example:
    // results.addAll(_allFiles.where((file) =>
    //     file.name.toLowerCase().contains(lowerQuery)));
    // results.addAll(_allEvents.where((event) =>
    //     event.title.toLowerCase().contains(lowerQuery)));
    // results.addAll(_allPhotos.where((photo) =>
    //     photo.caption?.toLowerCase().contains(lowerQuery) ?? false));

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
        }
        // TODO: Add builders for other content types
        // else if (item is File) {
        //   return _buildFileItem(item);
        // } else if (item is Event) {
        //   return _buildEventItem(item);
        // } else if (item is Photo) {
        //   return _buildPhotoItem(item);
        // }

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

  // TODO: Add builders for other content types
  // Widget _buildFileItem(File file) { ... }
  // Widget _buildEventItem(Event event) { ... }
  // Widget _buildPhotoItem(Photo photo) { ... }

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
