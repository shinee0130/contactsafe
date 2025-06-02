import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactListWidget extends StatelessWidget {
  final List<Contact> contacts;
  final ScrollController scrollController;
  final Function(Contact) onContactTap;
  final Function(String) onLetterTap;

  const ContactListWidget({
    super.key,
    required this.contacts,
    required this.scrollController,
    required this.onContactTap,
    required this.onLetterTap,
  });

  @override
  Widget build(BuildContext context) {
    final groupedContacts = _groupContacts(contacts);
    final sortedKeys = groupedContacts.keys.toList()..sort();

    return Stack(
      children: [
        contacts.isEmpty
            ? const Center(child: Text('No contacts found.'))
            : ListView.builder(
              controller: scrollController,
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final letter = sortedKeys[index];
                final contactsForLetter = groupedContacts[letter]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 0),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contactsForLetter.length,
                      itemBuilder: (context, contactIndex) {
                        final contact = contactsForLetter[contactIndex];
                        return ContactListItem(
                          contact: contact,
                          onTap: () => onContactTap(contact),
                        );
                      },
                    ),
                    const Divider(),
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
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final letter = sortedKeys[index];
                return GestureDetector(
                  onTap: () => onLetterTap(letter),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.blue, // Or use your AppColors.primary
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
    );
  }

  Map<String, List<Contact>> _groupContacts(List<Contact> contacts) {
    final Map<String, List<Contact>> groupedContacts = {};
    for (final contact in contacts) {
      if (contact.displayName.isNotEmpty) {
        final firstLetter = contact.displayName[0].toUpperCase();
        groupedContacts.putIfAbsent(firstLetter, () => []).add(contact);
      }
    }
    return groupedContacts;
  }
}

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingIcon(),
      title: Text(contact.displayName),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLeadingIcon() {
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
}
