import 'package:contactsafe/features/presentation/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: Center(child: Text('Contacts Page')),
      bottomNavigationBar: NavBar(),
    );
  }
}
