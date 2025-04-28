import 'package:contactsafe/presentation/screens/contacts_screen/edit_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../common/theme/app_colors.dart';
import 'contact_files_screen.dart';
import 'contact_notes_screen.dart';
import 'dart:typed_data';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;
  final bool isFavorite;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    this.isFavorite = false,
  });

  Widget _buildAvatar(Contact contact) {
    return const Icon(Icons.person_outline, size: 100, color: Colors.blue);
  }

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
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/groups');
            },
            child: const Text(
              'Group',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditContactScreen(contact: contact),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildAvatar(contact)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                contact.displayName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            if (contact.phones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mobile',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      contact.phones.first.number,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            ListTile(
              title: const Text('Files'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('0', style: TextStyle(color: Colors.grey)),
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_files',
                  arguments: contact,
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Notes'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('0', style: TextStyle(color: Colors.grey)),
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_notes',
                  arguments: contact,
                );
              },
            ),
            const Divider(),
            const ListTile(title: Text('Create VCF')),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
