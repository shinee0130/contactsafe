import 'package:flutter/material.dart';
import '../widgets/header_bar.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(
        title: "ContactSafe - filtered",
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: ListView(
        children: [
          ListTile(title: Text("Diana Diaz")),
          ListTile(title: Text("Derrick Fetcher")),
          ListTile(title: Text("John Fetcher")),
          ListTile(title: Text("Jessica Alba")),
          ListTile(title: Text("Rick Sanchez")),
          ListTile(title: Text("Rick Santorum")),
        ],
      ),
    );
  }
}
