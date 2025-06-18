import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';

class ContactListWidget extends StatelessWidget {
  final List<Contact> contacts;
  final ScrollController scrollController;
  final Function(Contact) onContactTap;
  final Function(String) onLetterTap;
  final bool lastNameFirst;

  const ContactListWidget({
    super.key,
    required this.contacts,
    required this.scrollController,
    required this.onContactTap,
    required this.onLetterTap,
    required this.lastNameFirst,
  });

  @override
  Widget build(BuildContext context) {
    final groupedContacts = _groupContacts(contacts);
    final sortedKeys = groupedContacts.keys.toList()..sort();

    return Stack(
      children: [
        // Main Contact List
        contacts.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
            : ListView.separated(
              controller: scrollController,
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final letter = sortedKeys[index];
                final contactsForLetter = groupedContacts[letter]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary, // iOS blue
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contactsForLetter.length,
                      itemBuilder: (context, contactIndex) {
                        final contact = contactsForLetter[contactIndex];
                        return ContactListItem(
                          contact: contact,
                          onTap: () => onContactTap(contact),
                          lastNameFirst: lastNameFirst,
                        );
                      },
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            indent: 72,
                            color:
                                Theme.of(context).dividerColor, // Theme divider
                          ),
                    ),
                  ],
                );
              },
              separatorBuilder:
                  (context, index) =>
                      const Divider(height: 8, color: Colors.transparent),
            ),

        // Alphabetical Index
        if (contacts.isNotEmpty)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      sortedKeys.map((letter) {
                        return GestureDetector(
                          onTap: () => onLetterTap(letter),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 2,
                            ),
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Map<String, List<Contact>> _groupContacts(List<Contact> contacts) {
    final Map<String, List<Contact>> groupedContacts = {};
    for (final contact in contacts) {
      final String displayName =
          lastNameFirst && (contact.familyName?.isNotEmpty ?? false)
              ? '${contact.familyName ?? ''} ${contact.givenName ?? ''}'
              : (contact.displayName ?? '');
      if (displayName.isNotEmpty) {
        final firstLetter = displayName[0].toUpperCase();
        groupedContacts.putIfAbsent(firstLetter, () => []).add(contact);
      }
    }
    return groupedContacts;
  }
}

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final bool lastNameFirst;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onTap,
    required this.lastNameFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 16),
              _buildLeadingIcon(context),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  lastNameFirst && (contact.familyName?.isNotEmpty ?? false)
                      ? '${contact.familyName ?? ''} ${contact.givenName ?? ''}'
                      : (contact.displayName ?? ''),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    final bool hasPhoto = contact.avatar != null && contact.avatar!.isNotEmpty;
    final String initials =
        (lastNameFirst && (contact.familyName?.isNotEmpty ?? false)
                ? contact.familyName![0]
                : ((contact.displayName ?? '').isNotEmpty
                    ? contact.displayName![0]
                    : '?'))
            .toUpperCase();

    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.09), // iOS avatar bg
      backgroundImage: hasPhoto ? MemoryImage(contact.avatar!) : null,
      child:
          !hasPhoto
              ? Text(
                initials,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
              : null,
    );
  }
}
