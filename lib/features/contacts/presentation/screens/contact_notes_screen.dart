import 'package:contactsafe/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactNotesScreen extends StatelessWidget {
  final Contact contact;

  const ContactNotesScreen({super.key, required this.contact});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30, color: AppColors.primary),
            onPressed: () {
              // TODO: Implement Add new note functionality
              print('Add new note');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${contact.displayName} - Notes',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            // TODO: Implement UI to display the contact's files here
            const Text('No files available for this contact yet.'),
          ],
        ),
      ),
    );
  }
}
