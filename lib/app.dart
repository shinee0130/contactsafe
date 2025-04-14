import 'package:flutter/material.dart';
import 'package:contactsafe/presentation/screens/contacts_screen.dart';
import 'package:contactsafe/presentation/screens/search_screen.dart';
import 'package:contactsafe/presentation/screens/events_screen.dart';
import 'package:contactsafe/presentation/screens/photos_screen.dart';
import 'package:contactsafe/presentation/screens/settings_screen.dart';

class ContactSafeApp extends StatelessWidget {
  const ContactSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContactSafe',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home:
          ContactsFilteredScreen(), // Set ContactsScreen as the initial screen
      routes: {
        '/contacts': (context) => ContactsFilteredScreen(),
        '/search': (context) => SearchScreen(),
        '/events': (context) => EventsScreen(),
        '/photos': (context) => PhotosScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
