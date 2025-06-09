import 'package:contactsafe/features/contacts/presentation/provider/contacts_provider.dart';
import 'package:contactsafe/features/contacts/presentation/widgets/contact_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_group_screen.dart';
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
  final ContactsProvider _contactsProvider = ContactsProvider();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    await _contactsProvider.fetchContacts();
    if (mounted) setState(() {});
  }

  void _filterContacts(String query) {
    _contactsProvider.filterContacts(query);
    setState(() {});
  }

  void _scrollToLetter(String letter) {
    final groupedContacts = _contactsProvider.groupContacts(
      _contactsProvider.contacts,
    );
    final index = _contactsProvider.findContactIndexForLetter(
      letter,
      groupedContacts,
    );

    if (index != -1) {
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
      if (key == letter) break;
      offset += 1; // For the header
      offset += groupedContacts[key]!.length; // For the contacts
      offset += 2; // For the dividers (assuming each group has 2 dividers)
    }
    return offset;
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

  void _navigateToGroups() {
    Navigator.push(
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ContactSafe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onBackground,
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
            child: const Text(
              'Group',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.blue, size: 24),
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
              'Contacts',
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
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ContactListWidget(
                    contacts: _contactsProvider.contacts,
                    scrollController: _scrollController,
                    onContactTap: (contact) {
                      Navigator.pushNamed(
                        context,
                        '/contact_detail',
                        arguments: contact,
                      );
                    },
                    onLetterTap: _scrollToLetter,
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
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
    );
  }
}
