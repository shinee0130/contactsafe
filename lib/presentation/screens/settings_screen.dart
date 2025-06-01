import 'package:contactsafe/common/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
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
      body: SettingsList(
        physics: const BouncingScrollPhysics(),
        sections: [
          CustomSettingsSection(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                bottom: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 31.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),

          SettingsSection(
            title: const Text(
              'Privacy',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Open in "Settings" app'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (context) {
                  // TODO: Implement opening native settings
                  if (kDebugMode) {
                    print('Open in "Settings" app');
                  }
                },
              ),
              SettingsTile.navigation(
                title: const Text('Language'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (context) {
                  // TODO: Implement language selection/navigation
                  if (kDebugMode) {
                    print('Change language');
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text(
              'About',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Version'),
                value: const Text(
                  '1.0.1 (90)',
                  style: TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
                onPressed: (context) {},
              ),
              SettingsTile.navigation(
                title: const Text('Imprint'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (context) {
                  // TODO: Navigate to Imprint screen
                  if (kDebugMode) {
                    print('Navigate to Imprint');
                  }
                },
              ),
              SettingsTile.navigation(
                title: const Text('Privacy'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (context) {
                  // TODO: Navigate to Privacy screen
                  if (kDebugMode) {
                    print('Navigate to Privacy');
                  }
                },
              ),
            ],
          ),

          SettingsSection(
            title: const Text(
              'General',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Sort by first name'),
                initialValue: _sortByFirstName,
                onToggle: (bool value) {
                  setState(() {
                    _sortByFirstName = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Last name first'),
                initialValue: _lastNameFirst,
                onToggle: (bool value) {
                  setState(() {
                    _lastNameFirst = value;
                  });
                },
              ),
            ],
          ),

          SettingsSection(
            title: const Text(
              'Import',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Import contacts',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement import contacts functionality
                  if (kDebugMode) {
                    print('Import contacts');
                  }
                },
              ),
            ],
          ),

          SettingsSection(
            title: const Text(
              'Backup',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Create backup',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement create backup functionality
                  if (kDebugMode) {
                    print('Create backup');
                  }
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Restore from backup',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement restore from backup functionality
                  if (kDebugMode) {
                    print('Restore from backup');
                  }
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Backup in Google Drive',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement backup to Google Drive
                  if (kDebugMode) {
                    print('Backup in Google Drive');
                  }
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Restore from Google Drive',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement restore from Google Drive
                  if (kDebugMode) {
                    print('Restore from Google Drive');
                  }
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Import backup from link',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement import backup from link
                  if (kDebugMode) {
                    print('Import backup from link');
                  }
                },
              ),
            ],
          ),

          SettingsSection(
            title: const Text(
              'Usability',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'On board tour',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement on board tour
                  if (kDebugMode) {
                    print('On board tour');
                  }
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Select TabBar order',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement select TabBar order
                  if (kDebugMode) {
                    print('Select TabBar order');
                  }
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Change password',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement change password
                  if (kDebugMode) {
                    print('Change password');
                  }
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Delete all data',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement delete all data with confirmation
                  if (kDebugMode) {
                    print('Delete all data');
                  }
                },
              ),
            ],
          ),

          SettingsSection(
            title: const Text(
              'Password',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Use Password'),
                initialValue: _usePass,
                onToggle: (bool value) {
                  setState(() {
                    _usePass = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Use FaceID'),
                initialValue: _useFaceId,
                onToggle: (bool value) {
                  setState(() {
                    _useFaceId = value;
                  });
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Change password',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) {
                  // TODO: Implement change password
                  if (kDebugMode) {
                    print('Change password (from Password section)');
                  }
                },
              ),
            ],
          ),

          CustomSettingsSection(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                bottom: 8.0,
                left: 16.0,
              ),
              child: Text(
                'Powered by InAppSettingKit',
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTap,
      ),
    );
  }
}
