import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'edit_contact.dart';

class ContactDetailsScreen extends StatelessWidget {
  final Contact contact;

  ContactDetailsScreen({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Contact details"),
        actions: [
          TextButton(
            onPressed: () {
              // Placeholder for group functionality
            },
            child: Text("Group", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              final updatedContact = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditContactScreen(contact: contact),
                ),
              );
              if (updatedContact != null) {
                // Handle contact update (pass back to previous screen)
              }
            },
            child: Text("Edit", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Divider(color: Colors.grey.shade800),
          _buildContactInfo(),
          Divider(color: Colors.grey.shade800),
          _buildActions(),
        ],
      ),
    );
  }

  /// **🔹 Contact Image + Name**
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
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
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          SizedBox(height: 10),
          Text(
            contact.displayName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (contact.organizations.isNotEmpty &&
              contact.organizations.first.company?.isNotEmpty == true)
            Text(
              contact.organizations.first.company!,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  /// **🔹 Phone Number & Email Display**
  Widget _buildContactInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.phones.isNotEmpty)
            ...contact.phones.map(
              (phone) => _infoTile(Icons.phone, "Phone", phone.number),
            ),
          if (contact.emails.isNotEmpty)
            ...contact.emails.map(
              (email) => _infoTile(Icons.email, "Email", email.address),
            ),
        ],
      ),
    );
  }

  /// **🔹 Action Buttons (Files, Notes, VCF)**
  Widget _buildActions() {
    return Column(
      children: [
        _actionTile("Files", "0"),
        _actionTile("Notes", "0"),
        _actionTile("Create VCF", ""),
      ],
    );
  }

  /// **🔹 Generic Info Tile (Phone, Email)**
  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(value, style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  /// **🔹 Action Tile (Files, Notes, Create VCF)**
  Widget _actionTile(String label, String value) {
    return ListTile(
      title: Text(label, style: TextStyle(fontSize: 18, color: Colors.white)),
      trailing:
          value.isNotEmpty
              ? Text(value, style: TextStyle(color: Colors.white))
              : null,
      onTap: () {},
    );
  }

  /// **🔹 Get Initials from Name**
  String _getInitials(String name) {
    List<String> nameParts = name.split(" ");
    String initials =
        nameParts.map((word) => word.isNotEmpty ? word[0] : "").take(2).join();
    return initials.toUpperCase();
  }
}
