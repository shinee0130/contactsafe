import 'package:contactsafe/features/contacts/presentation/provider/contacts_provider.dart';
import 'package:contactsafe/features/contacts/presentation/widgets/contact_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_group_screen.dart';
import 'package:contactsafe/shared/widgets/customsearchbar.dart';
import 'package:contactsafe/shared/widgets/navigation_bar.dart';
import 'package:contactsafe/core/theme/app_colors.dart';
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
      MaterialPageRoute(builder: (context) => const ContactGroupsScreen()),
    );
  }

  void _addNewContact() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContactScreen()),
    ).then((_) => _loadContacts());
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
        leadingWidth: 70.0,
        leading: TextButton(
          onPressed: _navigateToGroups,
          child: const Text(
            'Groups',
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary, size: 30),
            onPressed: _addNewContact,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contacts',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomSearchBar(
              controller: _searchController,
              onChanged: _filterContacts,
            ),
            const SizedBox(height: 16.0),
            Expanded(
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
