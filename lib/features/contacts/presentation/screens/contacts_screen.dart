import 'package:contactsafe/features/contacts/presentation/provider/contacts_provider.dart';
import 'package:contactsafe/features/contacts/presentation/widgets/contact_list_widget.dart';
import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:contactsafe/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_group_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/assign_contacts_to_group_screen.dart'
    show globalContactGroupsMap;
import 'package:contactsafe/shared/widgets/custom_search_bar.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.loc.appTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        leading: SizedBox(
          width: 120, // Fixed width
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.only(
                left: 16.0,
              ), // Remove default padding
            ),
            onPressed: _navigateToGroups,
            child: Text(
              context.loc.group,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              onPressed: _addNewContact,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              context.loc.contacts,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterContacts,
              hintText: context.loc.search,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (Theme.of(context).brightness == Brightness.light)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    if (Theme.of(context).brightness == Brightness.dark)
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.25,
                        ), // эсвэл 0.18~0.22, илүү бага opacity
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                  border: Border.all(color: Colors.transparent, width: 0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            if (Theme.of(context).brightness == Brightness.dark)
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 4,
                offset: const Offset(0, 1),
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
    );
  }
}
