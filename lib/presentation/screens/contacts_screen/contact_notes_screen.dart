import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactNotesScreen extends StatelessWidget {
  final Contact contact;

  const ContactNotesScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ContactSafe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement Add new note functionality
              print('Add new note');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('No notes associated with this contact.'),
        // Or a ListView to display notes later:
        // child: ListView.builder(
        //   itemCount: 0,
        //   itemBuilder: (context, index) {
        //     return Container(); // Replace with note display
        //   },
        // ),
      ),
    );
  }
}
