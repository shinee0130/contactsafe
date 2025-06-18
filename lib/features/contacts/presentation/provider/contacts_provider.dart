import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsProvider {
  final bool sortByFirstName;
  final bool lastNameFirst;

  ContactsProvider({this.sortByFirstName = false, this.lastNameFirst = false});

  List<Contact> _contacts = [];
  List<Contact> _allContacts = [];

  List<Contact> get contacts => _contacts;
  List<Contact> get allContacts => _allContacts;

  Future<void> fetchContacts() async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts =
            (await FlutterContactsService.getContacts(withThumbnails: false)).toList();
        contacts.sort((a, b) {
          String keyA =
              sortByFirstName
                  ? (a.givenName ?? '')
                  : ((a.familyName?.isNotEmpty ?? false)
                      ? a.familyName!
                      : (a.displayName ?? ''));
          String keyB =
              sortByFirstName
                  ? (b.givenName ?? '')
                  : ((b.familyName?.isNotEmpty ?? false)
                      ? b.familyName!
                      : (b.displayName ?? ''));
          return keyA.compareTo(keyB);
        });
        _contacts = contacts;
        _allContacts = List.from(contacts);
      }
    } catch (e) {
      debugPrint('Error requesting contact permission: $e');
      rethrow;
    }
  }

  void filterContacts(String query) {
    if (query.isEmpty) {
      _contacts = List.from(_allContacts);
    } else {
      _contacts =
          _allContacts
              .where(
                (contact) => (contact.displayName?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()),
              )
              .toList();
    }
  }

  Map<String, List<Contact>> groupContacts(List<Contact> contacts) {
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

  List<String> buildIndexLetters(Map<String, List<Contact>> groupedContacts) {
    return groupedContacts.keys.toList()..sort();
  }

  int findContactIndexForLetter(
    String letter,
    Map<String, List<Contact>> groupedContacts,
  ) {
    final sortedKeys = groupedContacts.keys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      if (sortedKeys[i] == letter) {
        final firstContactInGroup = groupedContacts[letter]!.first;
        return _allContacts.indexOf(firstContactInGroup);
      }
    }
    return -1;
  }
}
