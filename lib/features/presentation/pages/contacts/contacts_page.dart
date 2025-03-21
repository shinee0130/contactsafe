import 'package:contactsafe/features/presentation/pages/contacts/contact_details.dart';
import 'package:contactsafe/features/presentation/pages/contacts/create_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // Request permission
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts =
          _contacts.where((contact) {
            return contact.displayName.toLowerCase().contains(
              query.toLowerCase(),
            );
          }).toList();
    });
  }

  void _navigateToCreateContact() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateContactScreen()),
    );
    _fetchContacts(); // Refresh contacts after adding a new contact
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _filteredContacts.isEmpty
                    ? Center(child: Text("No contacts found"))
                    : ListView.builder(
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        Contact contact = _filteredContacts[index];
                        return ListTile(
                          leading:
                              (contact.thumbnail != null)
                                  ? CircleAvatar(
                                    backgroundImage: MemoryImage(
                                      contact.thumbnail!,
                                    ),
                                  )
                                  : CircleAvatar(
                                    child: Text(
                                      _getInitials(contact.displayName),
                                    ),
                                  ),
                          title: Text(
                            contact.displayName.isNotEmpty
                                ? contact.displayName
                                : "Unknown",
                          ),
                          subtitle:
                              contact.phones.isNotEmpty
                                  ? Text(contact.phones.first.number)
                                  : null,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ContactDetailsScreen(
                                        contact: contact,
                                      ),
                                ),
                              ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateContact,
        child: Icon(Icons.add),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(" ");
    String initials =
        nameParts.map((word) => word.isNotEmpty ? word[0] : "").take(2).join();
    return initials.toUpperCase();
  }
}
