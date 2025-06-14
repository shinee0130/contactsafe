import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
      bool isGranted = await FlutterContacts.requestPermission();
      if (isGranted) {
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
          withAccounts: true,
        );
        contacts.sort((a, b) {
          String keyA =
              sortByFirstName
                  ? a.name.first
                  : (a.name.last.isNotEmpty ? a.name.last : a.displayName);
          String keyB =
              sortByFirstName
                  ? b.name.first
                  : (b.name.last.isNotEmpty ? b.name.last : b.displayName);
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
                (contact) => contact.displayName.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  Map<String, List<Contact>> groupContacts(List<Contact> contacts) {
    final Map<String, List<Contact>> groupedContacts = {};
    for (final contact in contacts) {
      final String displayName =
          lastNameFirst && contact.name.last.isNotEmpty
              ? '${contact.name.last} ${contact.name.first}'
              : contact.displayName;
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
