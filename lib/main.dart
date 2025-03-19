import 'package:contactsafe/features/presentation/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'features/presentation/pages/contacts_page.dart';
import 'features/presentation/pages/search_page.dart';
import 'features/presentation/pages/events_page.dart';
import 'features/presentation/pages/photos_page.dart';
import 'features/presentation/pages/settings_page.dart';

void main() {
  runApp(ContactSafeApp());
}

class ContactSafeApp extends StatelessWidget {
  const ContactSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ContactsScreen(),
    SearchScreen(),
    EventsScreen(),
    PhotosScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
