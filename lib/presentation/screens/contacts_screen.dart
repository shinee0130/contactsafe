import 'package:contactsafe/presentation/screens/contacts_screen/contact_group_screen.dart';
import 'package:flutter/material.dart';
import '../../common/widgets/customsearchbar.dart';
import '../../common/widgets/navigation_bar.dart';
import '../../common/theme/app_colors.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'contacts_screen/add_contact_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _contacts = [];
  List<Contact> _allContacts = [];
  final ScrollController _scrollController = ScrollController();

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
        );
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

  Map<String, List<Contact>> _groupContacts(List<Contact> contacts) {
    final Map<String, List<Contact>> groupedContacts = {};
    for (final contact in contacts) {
      if (contact.displayName.isNotEmpty) {
        final firstLetter = contact.displayName[0].toUpperCase();
        if (!groupedContacts.containsKey(firstLetter)) {
          groupedContacts[firstLetter] = [];
        }
        groupedContacts[firstLetter]!.add(contact);
      }
    }
    return groupedContacts;
  }

  List<String> _buildIndexLetters() {
    final groupedContacts = _groupContacts(_contacts);
    final sortedKeys = groupedContacts.keys.toList()..sort();
    return sortedKeys;
  }

  void _scrollToLetter(String letter) {
    final groupedContacts = _groupContacts(_contacts);
    final sortedKeys = groupedContacts.keys.toList()..sort();
    int indexToScrollTo = -1;

    for (int i = 0; i < sortedKeys.length; i++) {
      if (sortedKeys[i] == letter) {
        final firstContactInGroup = groupedContacts[letter]!.first;
        indexToScrollTo = _allContacts.indexOf(firstContactInGroup);
        break;
      }
    }

    if (indexToScrollTo != -1) {
      int offset = 0;
      final filteredGroupedContacts = _groupContacts(_contacts);
      final filteredSortedKeys = filteredGroupedContacts.keys.toList()..sort();

      for (final key in filteredSortedKeys) {
        if (key == letter) {
          break;
        }
        offset += 1;
        offset += filteredGroupedContacts[key]!.length;
      }

      _scrollController.animateTo(
        offset * 56.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildLeadingIcon(Contact contact) {
    if (contact.photo != null) {
      return CircleAvatar(backgroundImage: MemoryImage(contact.photo!));
    } else {
      return CircleAvatar(
        child: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '',
        ),
      );
    }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedContacts = _groupContacts(_contacts);
    final sortedKeys = groupedContacts.keys.toList()..sort();

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
              child: Stack(
                children: [
                  _contacts.isEmpty
                      ? const Center(child: Text('No contacts found.'))
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, index) {
                          final letter = sortedKeys[index];
                          final contactsForLetter = groupedContacts[letter]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                ),
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: contactsForLetter.length,
                                itemBuilder: (context, contactIndex) {
                                  final contact =
                                      contactsForLetter[contactIndex];
                                  return ListTile(
                                    leading: _buildLeadingIcon(contact),
                                    title: Text(contact.displayName),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/contact_detail',
                                        arguments: contact,
                                      );
                                    },
                                  );
                                },
                              ),
                              Divider(),
                            ],
                          );
                        },
                      ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _buildIndexLetters().length,
                        itemBuilder: (context, index) {
                          final letter = _buildIndexLetters()[index];
                          return GestureDetector(
                            onTap: () {
                              _scrollToLetter(letter);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 1.0,
                              ),
                              child: Text(
                                letter,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
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
