import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../common/theme/app_colors.dart';

class ContactFilesScreen extends StatelessWidget {
  final Contact contact;

  const ContactFilesScreen({super.key, required this.contact});

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
            icon: const Icon(
              Icons.swap_vert,
              size: 30,
              color: AppColors.primary,
            ),
            onPressed: () {
              // TODO: Implement sorting/filtering functionality
              print('Sort/Filter files');
            },
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement Edit files functionality
              print('Edit files');
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 30, color: AppColors.primary),
            onPressed: () {
              // TODO: Implement Add file functionality
              print('Add file');
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
              '${contact.displayName} - Files', // Use string interpolation directly
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            // TODO: Implement UI to display the contact's files here
            // This could be a ListView.builder that fetches and displays
            // the files associated with the contact. For now, we'll
            // just display a placeholder.
            const Text('No files available for this contact yet.'),
          ],
        ),
      ),
    );
  }
}
