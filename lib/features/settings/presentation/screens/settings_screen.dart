import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:contactsafe/features/settings/presentation/screens/select_tab_bar_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contactsafe/core/theme/app_colors.dart';
import 'package:contactsafe/features/settings/presentation/widgets/onboarding_screen.dart';
import 'package:contactsafe/shared/widgets/navigation_bar.dart';
import 'package:contactsafe/shared/widgets/navigation_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4;
  bool _sortByFirstName = false;
  bool _lastNameFirst = false;
  bool _usePass = false;
  bool _useFaceId = false;
  List<NavigationItem> _navigationItems = NavigationItem.defaultItems();
  final SettingsController _controller = SettingsController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _controller.loadSettings();
    setState(() {
      _usePass = settings['usePassword'] ?? false;
      _useFaceId = settings['useFaceId'] ?? false;
      _navigationItems =
          settings['tabBarOrder'] ?? NavigationItem.defaultItems();
    });
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index >= 0 && index < _navigationItems.length) {
        Navigator.pushReplacementNamed(
          context,
          _navigationItems[index].routeName,
        );
      }
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
    }
  }

  Future<void> _importContacts() async {
    try {
      final count = await _controller.importContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported $count contacts!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing contacts: $e')));
    }
  }

  Future<void> _createBackup() async {
    try {
      final fileName = await _controller.createBackup();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup created successfully at $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create backup: $e')));
    }
  }

  Future<void> _restoreFromBackup() async {
    try {
      final count = await _controller.restoreFromBackup();
      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restored $count contacts from backup!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to restore backup: $e')));
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data?'),
          content: const Text(
            'Are you sure you want to delete ALL data from ContactSafe? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllApplicationData();
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete All',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllApplicationData() async {
    try {
      await _controller.deleteAllApplicationData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All application data has been deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete all data: $e')));
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      final biometrics = await _controller.checkBiometrics();
      if (biometrics['canCheckBiometrics'] &&
          (biometrics['availableBiometrics'] as List).isNotEmpty) {
        final authenticated = await _controller.authenticateWithBiometrics();
        if (authenticated) {
          setState(() => _useFaceId = true);
          await _controller.saveUseFaceIdSetting(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FaceID/Fingerprint enabled.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication failed or canceled.')),
          );
        }
      } else {
        setState(() => _useFaceId = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No FaceID/Fingerprint available.')),
        );
      }
    } else {
      setState(() => _useFaceId = false);
      await _controller.saveUseFaceIdSetting(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FaceID/Fingerprint disabled.')),
      );
    }
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
                onPressed: (context) async => await openAppSettings(),
              ),
              SettingsTile.navigation(
                title: const Text('Language'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (context) {},
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
                trailing: const Text(
                  '1.0.1 (90)',
                  style: TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
                onPressed: (context) {},
              ),
              SettingsTile.navigation(
                title: const Text('Imprint'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed:
                    (context) => _launchUrl(
                      'https://contactsafe.eu/index.php/impressum',
                    ),
              ),
              SettingsTile.navigation(
                title: const Text('Privacy'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed:
                    (context) => _launchUrl(
                      'https://contactsafe.eu/index.php/datenschutzerklaerung',
                    ),
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
                onToggle: (value) => setState(() => _sortByFirstName = value),
              ),
              SettingsTile.switchTile(
                title: const Text('Last name first'),
                initialValue: _lastNameFirst,
                onToggle: (value) => setState(() => _lastNameFirst = value),
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
                onPressed: (context) => _importContacts(),
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
                onPressed: (context) => _createBackup(),
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Restore from backup',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) => _restoreFromBackup(),
              ),
              // ... other backup tiles ...
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
                onPressed:
                    (context) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    ),
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Select TabBar order',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) async {
                  final newOrder = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SelectTabBarOrderScreen(
                            currentOrder: List.from(_navigationItems),
                          ),
                    ),
                  );
                  if (newOrder != null) {
                    await _controller.saveTabBarOrder(newOrder);
                    setState(() => _navigationItems = newOrder);
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
                onPressed: (context) => _showDeleteConfirmationDialog(),
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
                onToggle: (value) async {
                  setState(() => _usePass = value);
                  await _controller.saveUsePasswordSetting(value);
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Use FaceID & Fingerprint'),
                initialValue: _useFaceId,
                onToggle: _handleBiometricToggle,
              ),
            ],
          ),
          CustomSettingsSection(
            child: const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0),
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
