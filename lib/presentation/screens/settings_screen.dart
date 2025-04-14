import 'package:flutter/material.dart';
import 'package:contactsafe/common/widgets/navigation.dart';
import 'package:contactsafe/common/widgets/header.dart';
import 'package:contactsafe/common/theme/app_colors.dart';
import 'package:contactsafe/common/theme/app_styles.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4; // Index for the "Settings" tab

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
      appBar: ContactSafeHeader(titleText: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Text('Privacy', style: AppStyles.headlineMedium),
            ListTile(
              title: Text('Open "Settings" App', style: AppStyles.bodyMedium),
            ),
            Divider(color: AppColors.dividerColor),
            Text('About', style: AppStyles.headlineMedium),
            ListTile(title: Text('Version', style: AppStyles.bodyMedium)),
            ListTile(title: Text('Imprint', style: AppStyles.bodyMedium)),
            ListTile(title: Text('Privacy', style: AppStyles.bodyMedium)),
            Divider(color: AppColors.dividerColor),
            Text('General', style: AppStyles.headlineMedium),
            ListTile(
              title: Text('Sort by first name', style: AppStyles.bodyMedium),
              trailing: Switch(value: true, onChanged: (bool value) {}),
            ),
            ListTile(
              title: Text('Last name first', style: AppStyles.bodyMedium),
              trailing: Switch(value: false, onChanged: (bool value) {}),
            ),
            Divider(color: AppColors.dividerColor),
            Text('Import', style: AppStyles.headlineMedium),
            ListTile(
              title: Text('Import contacts', style: AppStyles.bodyMedium),
            ),
            Divider(color: AppColors.dividerColor),
            Text('Backup', style: AppStyles.headlineMedium),
            ListTile(title: Text('Create backup', style: AppStyles.bodyMedium)),
            ListTile(
              title: Text('Restore from backup', style: AppStyles.bodyMedium),
            ),
            // ... more settings items
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
