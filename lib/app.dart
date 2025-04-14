import 'package:flutter/material.dart';
import 'package:contactsafe/presentation/screens/contacts_screen.dart'; // Adjust path if needed

class ContactSafeApp extends StatelessWidget {
  const ContactSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContactSafe',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ContactsFilteredScreen(),
      routes: {
        '/contacts': (context) => ContactsFilteredScreen(),
        // Add other routes as you create more screens
      },
    );
  }
}
