import 'package:flutter/material.dart';
import '../../common/widgets/navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4; // To highlight the current tab

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      print('Bottom navigation tapped: $index');
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/contacts');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/search');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/events');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/photos');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ContactSafe',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        // Assuming settings might have a scrollable list
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(title: Text('Open in "Settings" app')),
            Divider(),
            Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(title: Text('Version')),
            ListTile(title: Text('Imprint')),
            ListTile(title: Text('Privacy')),
            Divider(),
            Text('General', style: TextStyle(fontWeight: FontWeight.bold)),
            // ListTile(
            //   title: Text('Sort by First name'),
            //   trailing: Switch(value: true, onChanged:),
            // ),
            // ListTile(
            //   title: Text('Last name first'),
            //   trailing: Switch(value: false, onChanged:),
            // ),
            Divider(),
            Text('Import', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(title: Text('Import contacts')),
            Divider(),
            Text('Backup', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(title: Text('Create backup')),
            ListTile(title: Text('Restore from Backup')),
            ListTile(title: Text('Backup in iCloud')),
            ListTile(title: Text('Restore from iCloud')),
            ListTile(title: Text('Import backup from link')),
            Divider(),
            Text(
              'Accessibility',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(title: Text('On board tour')),
            ListTile(title: Text('Select TabBar order')),
            ListTile(title: Text('Change password')),
            ListTile(title: Text('Delete all data')),
            Divider(),
            Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
            // ListTile(
            //   title: Text('Use FaceID'),
            //   trailing: Switch(value: true, onChanged: (value) {}), // Example switch
            // ),
            ListTile(title: Text('Change password')),
            Divider(),
            Text('Powered by thekeyring.at', style: TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTap,
      ),
    );
  }
}
