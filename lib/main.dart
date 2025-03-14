import 'package:flutter/material.dart';
import 'package:contactsafe/features/presentation/pages/contacts_page.dart';
import 'package:contactsafe/features/presentation/pages/search_page.dart';
import 'package:contactsafe/features/presentation/pages/events_page.dart';
import 'package:contactsafe/features/presentation/pages/photos_page.dart';
import 'package:contactsafe/features/presentation/pages/settings_page.dart';
import 'package:contactsafe/features/presentation/widgets/header_bar.dart';
import 'package:contactsafe/features/presentation/widgets/nav_bar.dart'
    as customnav;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: HeaderBar(),
        ),
        body: _buildBody(),
        bottomNavigationBar: customnav.NavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return ContactsPage();
      case 1:
        return SearchPage();
      case 2:
        return EventsPage();
      case 3:
        return PhotosPage();
      case 4:
        return SettingsPage();
      default:
        return Container();
    }
  }
}
