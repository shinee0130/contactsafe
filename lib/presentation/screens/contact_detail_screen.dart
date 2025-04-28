import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../common/theme/app_colors.dart';
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
    if (contact.photo != null) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: MemoryImage(contact.photo!),
      );
    } else {
      return CircleAvatar(
        radius: 40,
        child: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '',
          style: const TextStyle(fontSize: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact detail'),
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
              // TODO: Implement Edit functionality
              print('Edit');
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildAvatar(contact), // Use the _buildAvatar widget
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  contact.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isFavorite)
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
              ],
            ),
            const SizedBox(height: 5),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            if (contact.phones.isNotEmpty)
              _DetailItem(
                label: 'Mobile',
                value: contact.phones.first.number,
                icon: Icons.phone_android,
              ),
            if (contact.emails.isNotEmpty)
              _DetailItem(
                label: 'Email',
                value: contact.emails.first.address ?? 'No email',
                icon: Icons.email_outlined,
              ),
            const SizedBox(height: 10),
            const Divider(),
            _ClickableDetailItem(
              label: 'Files',
              value: '0',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_files',
                  arguments: contact,
                );
              },
            ),
            _ClickableDetailItem(
              label: 'Notes',
              value: '0',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_notes',
                  arguments: contact,
                );
              },
            ),
            const SizedBox(height: 10),
            const Divider(),
            ListTile(
              title: const Text('Create VCF'),
              onTap: () {
                // TODO: Implement Create VCF functionality
                print('Create VCF');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _DetailItem({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(icon, color: Colors.grey),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClickableDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ClickableDetailItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
