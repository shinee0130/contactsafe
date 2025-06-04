import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:contactsafe/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_detail_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_files_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_group_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_notes_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:contactsafe/features/search/presentation/screens/search_screen.dart';
import 'package:contactsafe/features/events/presentation/screens/events_screen.dart';
import 'package:contactsafe/features/photos/presentation/screens/photos_screen.dart';
import 'package:contactsafe/features/settings/presentation/screens/settings_screen.dart';

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
