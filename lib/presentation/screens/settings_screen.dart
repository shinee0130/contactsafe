import 'package:contactsafe/common/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../common/widgets/navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4;
  bool _sortByFirstName = false;
  bool _lastNameFirst = false;
  bool _useFaceId = false;
  bool _usePass = false;

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      if (kDebugMode) {
        print('Bottom navigation tapped: $index');
      }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Privacy',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const ListTile(
              title: Text('Open in "Settings" app'),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
            ),
            const ListTile(
              title: Text('Language'),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
            ),
            const Divider(),
            const Text(
              'About',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const ListTile(
              title: Text('Version'),
              trailing: Text(
                '1.0.1 (90)',
                style: TextStyle(color: Colors.grey, fontSize: 15.0),
              ),
            ),
            const ListTile(
              title: Text('Imprint'),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
            ),
            const ListTile(
              title: Text('Privacy'),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
            ),
            const Divider(),
            const Text(
              'General',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            SwitchListTile(
              title: const Text('Sort by first name'),
              value: _sortByFirstName,
              onChanged: (bool value) {
                setState(() {
                  _sortByFirstName = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Last name first'),
              value: _lastNameFirst,
              onChanged: (bool value) {
                setState(() {
                  _lastNameFirst = value;
                });
              },
            ),
            const Divider(),
            const Text(
              'Import',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Import contacts',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const Divider(),
            const Text(
              'Backup',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Create backup',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Restore from backup',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Backup in Google Drive',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Restore from Google Drive',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Import backup from link',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const Divider(),
            const Text(
              'Usability',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'On board tour',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Select TabBar order',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Change password',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Delete all data',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const Divider(),
            const Text(
              'Password',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            SwitchListTile(
              title: const Text('Use Password'),
              value: _usePass,
              onChanged: (bool value) {
                setState(() {
                  _usePass = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Use FaceID'),
              value: _useFaceId,
              onChanged: (bool value) {
                setState(() {
                  _useFaceId = value;
                });
              },
            ),
            const ListTile(
              title: Center(
                child: Text(
                  'Change password',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                'Powered by InAppSettingKit',
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ),
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
