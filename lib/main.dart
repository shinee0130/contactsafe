import 'package:flutter/material.dart';
import 'features/presentation/pages/contacts_page.dart';

void main() {
  runApp(ContactSafeApp());
}

class ContactSafeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContactSafe',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: ContactsPage(),
    );
  }
}
