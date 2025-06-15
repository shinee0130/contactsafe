import 'package:contactsafe/features/contacts/presentation/provider/contacts_provider.dart';
import 'package:contactsafe/features/contacts/presentation/widgets/contact_list_widget.dart';
import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_group_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/assign_contacts_to_group_screen.dart.dart'
    show globalContactGroupsMap;
import 'package:contactsafe/shared/widgets/customsearchbar.dart';
import 'package:contactsafe/shared/widgets/navigation_bar.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'add_contact_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ContactsProvider _contactsProvider;
  final List<String> _selectedGroups = [];
  List<Contact> _displayedContacts = [];
  final SettingsController _settingsController = SettingsController();
  bool _lastNameFirst = false;
  bool _sortByFirstName = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _sortByFirstName = await _settingsController.loadSortByFirstName();
    _lastNameFirst = await _settingsController.loadLastNameFirst();
    _contactsProvider = ContactsProvider(
      sortByFirstName: _sortByFirstName,
      lastNameFirst: _lastNameFirst,
    );
    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    await _contactsProvider.fetchContacts();
    _applyFilters(query: _searchController.text);
    if (mounted) {
      setState(() {});
    }
  }

  void _filterContacts(String query) {
    _applyFilters(query: query);
  }

  void _scrollToLetter(String letter) {
    final groupedContacts = _contactsProvider.groupContacts(_displayedContacts);
    if (groupedContacts.containsKey(letter)) {
      final offset = _calculateScrollOffset(letter, groupedContacts);
      _scrollController.animateTo(
        offset * 56.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int _calculateScrollOffset(
    String letter,
    Map<String, List<Contact>> groupedContacts,
  ) {
    int offset = 0;
    final sortedKeys = groupedContacts.keys.toList()..sort();

    for (final key in sortedKeys) {
      if (key == letter) {
        break;
      }
      offset += 1; // For the header
      offset += groupedContacts[key]!.length; // For the contacts
      offset += 2; // For the dividers (assuming each group has 2 dividers)
    }
    return offset;
  }

  void _applyFilters({String query = ''}) {
    List<Contact> filtered = List.from(_contactsProvider.allContacts);

    if (_selectedGroups.isNotEmpty) {
      filtered =
          filtered.where((contact) {
            final groups =
                globalContactGroupsMap[contact.displayName] ?? ['Not assigned'];
            if (groups.isEmpty) {
              groups.add('Not assigned');
            }
            return groups.any((g) => _selectedGroups.contains(g));
          }).toList();
    }

    if (query.isNotEmpty) {
      filtered =
          filtered
              .where(
                (c) =>
                    c.displayName.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }

    setState(() {
      _displayedContacts = filtered;
    });
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
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

  Future<void> _navigateToGroups() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const ContactGroupsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );

    if (result is List<String>) {
      _selectedGroups
        ..clear()
        ..addAll(result);
      _applyFilters(query: _searchController.text);
    }
  }

  void _addNewContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddContactScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _navigateToGroups,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewContact,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterContacts,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search contacts',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ContactListWidget(
                contacts: _displayedContacts,
                scrollController: _scrollController,
                onContactTap: (contact) {
                  Navigator.pushNamed(
                    context,
                    '/contact_detail',
                    arguments: contact,
                  );
                },
                onLetterTap: _scrollToLetter,
                lastNameFirst: _lastNameFirst,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: ContactSafeNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onBottomNavigationTap,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}
