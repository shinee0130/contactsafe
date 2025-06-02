import 'dart:io';
import 'dart:convert';
import 'package:contactsafe/common/theme/app_colors.dart';
import 'package:contactsafe/presentation/screens/onboarding_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../common/widgets/navigation_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/widgets/navigation_item.dart';
import 'select_tab_bar_order_screen.dart';
import 'package:local_auth/local_auth.dart';

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

  List<NavigationItem> _navigationItems = NavigationItem.defaultItems();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadTabBarOrder(); // Load saved order when screen initializes
    _loadSettings();
  }

  // New method to load all relevant settings
  Future<void> _loadSettings() async {
    await _loadTabBarOrder(); // Load TabBar order
    await _loadUsePasswordSetting(); // Load _usePass setting
    await _loadUseFaceIdSetting();
    // You can add other settings loading here
  }

  // New method to load the _usePass setting
  Future<void> _loadUsePasswordSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Get the boolean value; default to false if not found
      _usePass = prefs.getBool('usePassword') ?? false;
    });
    if (kDebugMode) {
      print('Loaded usePassword: $_usePass');
    }
  }

  // New method to save the _usePass setting
  Future<void> _saveUsePasswordSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('usePassword', value);
    if (kDebugMode) {
      print('Saved usePassword: $value');
    }
  }

  Future<void> _loadUseFaceIdSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useFaceId = prefs.getBool('useFaceId') ?? false;
    });
    if (kDebugMode) {
      print('Loaded useFaceId: $_useFaceId');
    }
  }

  // *** NEW: Save the _useFaceId setting ***
  Future<void> _saveUseFaceIdSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useFaceId', value);
    if (kDebugMode) {
      print('Saved useFaceId: $value');
    }
  }

  // Load the saved TabBar order from SharedPreferences
  Future<void> _loadTabBarOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedOrderJson = prefs.getString('tabBarOrder');
    if (savedOrderJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(savedOrderJson);
        setState(() {
          _navigationItems =
              decodedList
                  .map(
                    (itemJson) => NavigationItem.fromJson(
                      itemJson as Map<String, dynamic>,
                    ),
                  )
                  .toList();
        });
        if (kDebugMode) {
          print(
            'Loaded TabBar order: ${_navigationItems.map((e) => e.label).join(', ')}',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding saved TabBar order: $e');
        }
        // Fallback to default if decoding fails
        setState(() {
          _navigationItems = NavigationItem.defaultItems();
        });
      }
    } else {
      if (kDebugMode) {
        print('No saved TabBar order found, using default.');
      }
    }
  }

  // Save the current TabBar order to SharedPreferences
  Future<void> _saveTabBarOrder(List<NavigationItem> newOrder) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> orderToJson =
        newOrder.map((item) => item.toJson()).toList();
    await prefs.setString('tabBarOrder', jsonEncode(orderToJson));
    setState(() {
      _navigationItems = newOrder;
    });
    if (kDebugMode) {
      print(
        'Saved TabBar order: ${_navigationItems.map((e) => e.label).join(', ')}',
      );
    }
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      if (kDebugMode) {
        print('Bottom navigation tapped: $index');
      }
      // Navigate based on the routeName of the selected item in the *current order*
      // Need to ensure _navigationItems is correctly mapped to the BottomNavigationBar's items.
      // This part would typically be handled in the parent widget that owns the BottomNavigationBar.
      // For now, we'll assume the /settings route is always accessible through its original index if needed
      // or that the parent widget rebuilds its navigation based on _navigationItems.
      if (index >= 0 && index < _navigationItems.length) {
        Navigator.pushReplacementNamed(
          context,
          _navigationItems[index].routeName,
        );
      } else {
        if (kDebugMode) {
          print('Invalid index for bottom navigation: $index');
        }
      }
    });
  }

  // Function to launch a URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (kDebugMode) {
        print('Could not launch $url');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
    }
  }

  Future<void> _importContacts() async {
    try {
      // Request permission
      if (await FlutterContacts.requestPermission()) {
        // Fetch all contacts
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true, // Get phone numbers, emails, etc.
          withPhoto: true,
        );

        if (kDebugMode) {
          print('Fetched ${contacts.length} contacts.');
          for (
            int i = 0;
            i < (contacts.length > 5 ? 5 : contacts.length);
            i++
          ) {
            print('Contact ${i + 1}: ${contacts[i].displayName}');
            if (contacts[i].phones.isNotEmpty) {
              print('  Phone: ${contacts[i].phones.first.number}');
            }
            if (contacts[i].emails.isNotEmpty) {
              print('  Email: ${contacts[i].emails.first.address}');
            }
          }
        }

        // TODO: Now, you need to decide what to do with these 'contacts'
        // - Save them to your app's local database (e.g., SQLite, Hive)
        // - Upload them to a backend server
        // - Process them as needed by your ContactSafe app
        // For demonstration, we'll just show a success message.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported ${contacts.length} contacts!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied.')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error importing contacts: $e');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing contacts: $e')));
    }
  }

  // New function to handle creating backup
  Future<void> _createBackup() async {
    if (kDebugMode) {
      print('Attempting to create backup...');
    }

    try {
      // 1. Get the directory to save the file
      // Use applicationDocumentsDirectory for app-specific private storage
      // For shared storage (like Downloads), it gets more complex due to scoped storage.
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/contactsafe_backup_${_formatDateTime(DateTime.now())}.json';
      final File file = File(filePath);

      // 2. Prepare the data to be backed up
      // TODO: Replace this dummy data with your actual ContactSafe app's contact data
      // For example, if you have a list of `ContactSafeContact` objects,
      // you would convert them to a serializable format (e.g., List<Map<String, dynamic>>).
      final List<Map<String, dynamic>> dummyContactsData = [
        {
          'id': '1',
          'name': 'John Doe',
          'phone': '123-456-7890',
          'email': 'john.doe@example.com',
        },
        {
          'id': '2',
          'name': 'Jane Smith',
          'phone': '987-654-3210',
          'email': 'jane.smith@example.com',
        },
      ];

      // Convert data to JSON string
      final String jsonContent = jsonEncode(dummyContactsData);

      // 3. Write the data to the file
      await file.writeAsString(jsonContent);

      if (kDebugMode) {
        print('Backup created at: $filePath');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Backup created successfully at ${file.path.split('/').last}',
          ),
        ),
      );

      // You could also offer to share the file here if desired
      // using share_plus package.
    } catch (e) {
      if (kDebugMode) {
        print('Error creating backup: $e');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create backup: $e')));
    }
  }

  //Restoring from backup file
  Future<void> _restoreFromBackup() async {
    if (kDebugMode) {
      print('Attempting to restore from backup...');
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'], // Suggest only JSON files
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileContent = await file.readAsString();

        // Parse the JSON content
        final List<dynamic> decodedData = jsonDecode(fileContent);

        // TODO: This is the most crucial part for your app!
        // You need to take 'decodedData' (which is List<Map<String, dynamic>> in this example)
        // and integrate it into your app's contact management system.
        // This might involve:
        // 1. Clearing existing contacts in your app.
        // 2. Iterating through 'decodedData' and creating/updating your app's contact objects.
        // 3. Saving these new/updated contacts to your app's database.
        if (kDebugMode) {
          print('Backup file selected: ${file.path}');
          print('Decoded data: $decodedData');
          print('Restored ${decodedData.length} contacts.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Restored ${decodedData.length} contacts from backup!',
            ),
          ),
        );

        // You might want to trigger a UI refresh of your contact list here
        // if your current contacts view is managed by a state management solution
        // or by calling a function that reloads contacts.
      } else {
        // User canceled the picker
        if (kDebugMode) {
          print('File picking canceled or no file selected.');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restoration canceled.')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring backup: $e');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to restore backup: $e')));
    }
  }

  // Helper function to format DateTime for filename
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}${_twoDigits(dateTime.month)}${_twoDigits(dateTime.day)}_${_twoDigits(dateTime.hour)}${_twoDigits(dateTime.minute)}${_twoDigits(dateTime.second)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // *** NEW: Confirmation Dialog for Delete All Data ***
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data?'),
          content: const Text(
            'Are you sure you want to delete ALL data from ContactSafe? This action cannot be undone. All contacts, photos, events, and settings will be permanently removed.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              // Use FilledButton for destructive action
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _deleteAllApplicationData(); // Proceed with deletion
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red, // Red color for delete
              ),
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

  // *** NEW: Function to delete all application data ***
  Future<void> _deleteAllApplicationData() async {
    if (kDebugMode) {
      print('Initiating delete all data process...');
    }

    try {
      // 1. Delete ContactSafe's internal contacts data
      // TODO: Implement your actual contact deletion logic here.
      // If you are using sqflite, this might look like:
      // await DatabaseProvider.instance.deleteAllContacts();
      // Or if you store contacts in a file:
      // final contactsFile = File('${(await getApplicationDocumentsDirectory()).path}/contacts.json');
      // if (await contactsFile.exists()) {
      //   await contactsFile.delete();
      // }
      print('TODO: Placeholder for deleting ContactSafe contacts data.');

      // 2. Delete any local backup files
      final directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        final List<FileSystemEntity> files = directory.listSync();
        for (final file in files) {
          // You might want to be more specific here, e.g., only delete files matching a certain pattern
          // if you store other app-critical files in the same directory.
          // For example, if your backups start with 'contactsafe_backup_':
          if (file.path.contains('contactsafe_backup_')) {
            await file.delete();
            if (kDebugMode) {
              print('Deleted backup file: ${file.path}');
            }
          }
          // If you want to delete ALL files in appDocumentsDirectory (use with caution):
          // await file.delete();
        }
      }
      print(
        'TODO: Placeholder for deleting local backup files (some are already deleted above).',
      );

      // 3. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // This clears all key-value pairs stored by your app
      if (kDebugMode) {
        print('SharedPreferences cleared.');
      }

      // 4. Reset other app-specific states (e.g., photos, events data)
      // TODO: Add logic to clear any other data specific to your app (e.g., photo galleries, event lists).
      // This might involve deleting files from other app-specific directories or resetting database tables.
      print(
        'TODO: Placeholder for deleting other app data (photos, events, etc.).',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All application data has been deleted.')),
      );

      // Optionally, navigate to a fresh state (e.g., login/onboarding screen)
      // This is crucial if your app relies on initial setup.
      // Example: Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const InitialSetupScreen()),
      //   (Route<dynamic> route) => false,
      // );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all data: $e');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete all data: $e')));
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
          // Header for "Settings"
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
                onPressed: (context) async {
                  if (await openAppSettings()) {
                    if (kDebugMode) {
                      print('Opened app settings');
                    }
                  } else {
                    if (kDebugMode) {
                      print('Could not open app settings');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open app settings'),
                      ),
                    );
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
                trailing: const Text(
                  '1.0.1 (90)',
                  style: TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
                onPressed: (context) {},
              ),
              SettingsTile.navigation(
                title: const Text('Imprint'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (context) {
                  _launchUrl('https://contactsafe.eu/index.php/impressum');
                },
              ),
              SettingsTile.navigation(
                title: const Text('Privacy'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: (context) {
                  _launchUrl(
                    'https://contactsafe.eu/index.php/datenschutzerklaerung',
                  );
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
                  _importContacts();
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
                  _createBackup();
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
                  _restoreFromBackup();
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
              ),
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Select TabBar order',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                onPressed: (context) async {
                  // Navigate to the reorder screen and wait for result
                  final List<NavigationItem>? newOrder = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SelectTabBarOrderScreen(
                            currentOrder: List.from(
                              _navigationItems,
                            ), // Pass a copy
                          ),
                    ),
                  );

                  if (newOrder != null) {
                    _saveTabBarOrder(newOrder); // Save the new order
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
                  _showDeleteConfirmationDialog();
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
                  _saveUsePasswordSetting(value);
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Use FaceID & Fingerprint'), // Updated title
                initialValue: _useFaceId,
                onToggle: (bool value) async {
                  // Make onToggle async for potential biometric checks
                  if (value) {
                    // If enabling biometrics, check if available and enroll
                    bool canCheckBiometrics =
                        await _localAuth.canCheckBiometrics;
                    List<BiometricType> availableBiometrics =
                        await _localAuth.getAvailableBiometrics();

                    if (kDebugMode) {
                      print('Can check biometrics: $canCheckBiometrics');
                      print('Available biometrics: $availableBiometrics');
                    }

                    if (canCheckBiometrics && availableBiometrics.isNotEmpty) {
                      // Optionally, prompt for authentication immediately to 'enroll' or confirm
                      // This is a common pattern for "enable biometrics" settings
                      bool authenticated = await _localAuth.authenticate(
                        localizedReason:
                            'Please authenticate to enable FaceID/Fingerprint',
                        options: const AuthenticationOptions(
                          stickyAuth:
                              true, // Keep dialog open if user switches app
                        ),
                      );

                      if (authenticated) {
                        setState(() {
                          _useFaceId =
                              value; // Update state only if authentication succeeds
                        });
                        _saveUseFaceIdSetting(value); // Save setting
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('FaceID/Fingerprint enabled.'),
                          ),
                        );
                      } else {
                        // Authentication failed or user canceled, so don't enable the switch
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Authentication failed or canceled. FaceID/Fingerprint not enabled.',
                            ),
                          ),
                        );
                        // Do NOT setState(_useFaceId = value) here to keep it off
                      }
                    } else {
                      // No biometrics available or set up on device
                      setState(() {
                        _useFaceId =
                            false; // Force switch off as biometrics are not available
                      });
                      _saveUseFaceIdSetting(false); // Save false state
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No FaceID/Fingerprint available or set up on this device.',
                          ),
                        ),
                      );
                    }
                  } else {
                    // If disabling, simply update state and save
                    setState(() {
                      _useFaceId = value;
                    });
                    _saveUseFaceIdSetting(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('FaceID/Fingerprint disabled.'),
                      ),
                    );
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
                    print('Change password (from Password section)');
                  }
                },
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
