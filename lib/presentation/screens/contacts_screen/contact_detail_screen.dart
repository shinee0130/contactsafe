import 'package:contactsafe/presentation/screens/contacts_screen/edit_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../common/theme/app_colors.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;
  final bool isFavorite;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    this.isFavorite = false,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  Contact?
  _detailedContact; // Use a state variable to hold the potentially refetched contact

  @override
  void initState() {
    super.initState();
    _loadContactDetails(widget.contact.id); // Use widget.contact.id here
  }

  Future<void> _loadContactDetails(String contactId) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        Contact? fetchedContact = await FlutterContacts.getContact(
          contactId,
          withAccounts: true, // THIS IS CRUCIAL
          withPhoto: true,
        );
        setState(() {
          _detailedContact =
              fetchedContact ??
              widget.contact; // Use fetched or fallback to the passed contact
        });
      } else {
        // Handle permission denial (e.g., show a message)
        setState(() {
          _detailedContact = widget.contact; // Fallback if no permission
        });
      }
    } catch (e) {
      print('Error loading contact details with accounts: $e');
      setState(() {
        _detailedContact = widget.contact; // Fallback on error
      });
    }
  }

  Widget _buildAvatar(Contact contact) {
    return const Icon(Icons.person_outline, size: 100, color: Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    final currentContact =
        _detailedContact ?? widget.contact; // Use the stateful contact

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
                  builder:
                      (context) => EditContactScreen(
                        contact: currentContact,
                      ), // Use the stateful contact
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
            const Text(
              'Contact Details',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Center(
              child: _buildAvatar(currentContact),
            ), // Use the stateful contact
            const SizedBox(height: 16),
            Center(
              child: Text(
                currentContact.displayName, // Use the stateful contact
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            if (currentContact.phones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mobile',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      currentContact
                          .phones
                          .first
                          .number, // Use the stateful contact
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
                  Text('0', style: TextStyle(fontSize: 20)),
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_files',
                  arguments: currentContact, // Use the stateful contact
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Notes'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('0', style: TextStyle(fontSize: 20)),
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_notes',
                  arguments: currentContact, // Use the stateful contact
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
