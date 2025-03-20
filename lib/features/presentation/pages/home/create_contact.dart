import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class CreateContactScreen extends StatefulWidget {
  @override
  _CreateContactScreenState createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  List<TextEditingController> phoneControllers = [TextEditingController()];
  List<TextEditingController> emailControllers = [TextEditingController()];

  void _addPhoneField() {
    setState(() {
      phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    setState(() {
      phoneControllers.removeAt(index);
    });
  }

  void _addEmailField() {
    setState(() {
      emailControllers.add(TextEditingController());
    });
  }

  void _removeEmailField(int index) {
    setState(() {
      emailControllers.removeAt(index);
    });
  }

  Future<void> _saveContact() async {
    if (firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("First name is required")));
      return;
    }

    Contact newContact = Contact(
      name: Name(
        first: firstNameController.text,
        last: lastNameController.text,
      ),
      phones:
          phoneControllers
              .where((controller) => controller.text.isNotEmpty)
              .map((controller) => Phone(controller.text))
              .toList(),
      emails:
          emailControllers
              .where((controller) => controller.text.isNotEmpty)
              .map((controller) => Email(controller.text))
              .toList(),
    );

    await FlutterContacts.insertContact(newContact);
    Navigator.pop(context, true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Contact"),
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                  TextButton(
                    onPressed: () {},
                    child: Text("Clear", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: "Last Name"),
            ),
            SizedBox(height: 10),

            // Phones
            for (int i = 0; i < phoneControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: phoneControllers[i],
                      decoration: InputDecoration(labelText: "Phone"),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  if (i > 0)
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removePhoneField(i),
                    ),
                ],
              ),
            TextButton.icon(
              onPressed: _addPhoneField,
              icon: Icon(Icons.add, color: Colors.green),
              label: Text("Add phone"),
            ),

            // Emails
            for (int i = 0; i < emailControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: emailControllers[i],
                      decoration: InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  if (i > 0)
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeEmailField(i),
                    ),
                ],
              ),
            TextButton.icon(
              onPressed: _addEmailField,
              icon: Icon(Icons.add, color: Colors.green),
              label: Text("Add email"),
            ),
          ],
        ),
      ),
    );
  }
}
