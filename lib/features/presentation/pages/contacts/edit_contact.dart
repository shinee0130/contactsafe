import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class EditContactScreen extends StatefulWidget {
  final Contact contact;

  EditContactScreen({required this.contact});

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(
      text: widget.contact.name.first,
    );
    lastNameController = TextEditingController(text: widget.contact.name.last);
    phoneController = TextEditingController(
      text:
          widget.contact.phones.isNotEmpty
              ? widget.contact.phones.first.number
              : '',
    );
    emailController = TextEditingController(
      text:
          widget.contact.emails.isNotEmpty
              ? widget.contact.emails.first.address
              : '',
    );
  }

  Future<void> _saveContact() async {
    widget.contact.name.first = firstNameController.text;
    widget.contact.name.last = lastNameController.text;

    if (phoneController.text.isNotEmpty) {
      widget.contact.phones = [Phone(phoneController.text)];
    }
    if (emailController.text.isNotEmpty) {
      widget.contact.emails = [Email(emailController.text)];
    }

    await FlutterContacts.updateContact(widget.contact);
    Navigator.pop(context, true); // Return true to indicate an update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Contact"),
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  widget.contact.thumbnail != null
                      ? MemoryImage(widget.contact.thumbnail!)
                      : null,
              child:
                  widget.contact.thumbnail == null
                      ? Text(
                        _getInitials(widget.contact.displayName),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            SizedBox(height: 10),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveContact,
              child: Text("Save Contact"),
            ),
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
