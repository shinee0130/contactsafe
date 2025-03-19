import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactDetailsScreen extends StatelessWidget {
  final Contact contact;

  ContactDetailsScreen({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.displayName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    contact.thumbnail != null
                        ? MemoryImage(contact.thumbnail!)
                        : null,
                child:
                    contact.thumbnail == null
                        ? Text(
                          _getInitials(contact.displayName),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Name:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(contact.displayName, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            if (contact.phones.isNotEmpty) ...[
              Text(
                "Phone:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...contact.phones.map(
                (phone) => Text(phone.number, style: TextStyle(fontSize: 16)),
              ),
            ],
            SizedBox(height: 10),
            if (contact.emails.isNotEmpty) ...[
              Text(
                "Email:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...contact.emails.map(
                (email) => Text(email.address, style: TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
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
