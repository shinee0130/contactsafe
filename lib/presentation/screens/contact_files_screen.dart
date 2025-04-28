import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../common/theme/app_colors.dart'; // Assuming you have this

class ContactFilesScreen extends StatelessWidget {
  final Contact contact;

  const ContactFilesScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${contact.displayName} - Files'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert), // Up/down arrow icon
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
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement Add file functionality
              print('Add file');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('No files associated with this contact.'),
        // Or you could start with an empty ListView:
        // child: ListView.builder(
        //   itemCount: 0, // Initially empty
        //   itemBuilder: (context, index) {
        //     return Container(); // Replace with file display widget
        //   },
        // ),
      ),
    );
  }
}
