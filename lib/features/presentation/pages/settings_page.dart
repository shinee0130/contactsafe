import 'package:contactsafe/features/presentation/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text('Settings Page')),
      bottomNavigationBar: NavBar(),
    );
  }
}
