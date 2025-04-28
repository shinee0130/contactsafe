import 'package:contactsafe/presentation/screens/contacts_screen/add_contact_screen.dart';
import 'package:contactsafe/presentation/screens/contacts_screen/contact_detail_screen.dart';
import 'package:contactsafe/presentation/screens/contacts_screen/contact_files_screen.dart';
import 'package:contactsafe/presentation/screens/contacts_screen/contact_group_screen.dart';
import 'package:contactsafe/presentation/screens/contacts_screen/contact_notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:contactsafe/presentation/screens/contacts_screen.dart';
import 'package:contactsafe/presentation/screens/search_screen.dart';
import 'package:contactsafe/presentation/screens/events_screen.dart';
import 'package:contactsafe/presentation/screens/photos_screen.dart';
import 'package:contactsafe/presentation/screens/settings_screen.dart';
import 'package:flutter_contacts/contact.dart';

class ContactSafeApp extends StatelessWidget {
  const ContactSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContactSafe',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: ContactsScreen(),
      routes: {
        '/contacts': (context) => const ContactsScreen(),
        '/search': (context) => const SearchScreen(),
        '/events': (context) => const EventsScreen(),
        '/photos': (context) => const PhotosScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/contact_detail':
            (context) => ContactDetailScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
        '/add_contact': (context) => const AddContactScreen(),
        '/groups': (context) => const ContactGroupsScreen(),
        '/contact_files':
            (context) => ContactFilesScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
        '/contact_notes':
            (context) => ContactNotesScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
      },
    );
  }
}
