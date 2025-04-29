import 'package:contactsafe/common/widgets/customsearchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart' show Contact;
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../common/widgets/navigation_bar.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _currentIndex = 2; // To highlight the current tab
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _contacts = [];
  List<Contact> _allContacts = [];
  final ScrollController _scrollController = ScrollController();

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
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
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      bool isGranted = await FlutterContacts.requestPermission();
      print('Permission Granted: $isGranted');
      if (isGranted) {
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        ); // Fetch with photo
        contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
        setState(() {
          _contacts = contacts;
          _allContacts = List.from(contacts);
        });
        print('Fetched ${contacts.length} contacts.');
      } else {
        print('Contact permission not granted.');
      }
    } catch (e) {
      print('Error requesting contact permission: $e');
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _contacts = List.from(_allContacts);
      });
    } else {
      final filteredList =
          _allContacts
              .where(
                (contact) => contact.displayName.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
      setState(() {
        _contacts = filteredList;
      });
    }
  }

  void _addNewEvent() {
    // TODO: Implement add new event
    print('Add new event');
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
              'Events',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterContacts,
            ),
            const SizedBox(height: 16.0),
            const Expanded(
              child: Center(
                child: Text(
                  'Events will be displayed here',
                ), // Replace with your events list
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTap,
      ),
    );
  }
}
