import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:contactsafe/features/settings/presentation/screens/pin_dialog.dart';
import 'package:contactsafe/features/settings/presentation/screens/select_tab_bar_order_screen.dart';
import 'package:contactsafe/features/settings/presentation/widgets/onboarding_screen.dart';
import 'package:contactsafe/shared/widgets/navigation_bar.dart';
import 'package:contactsafe/shared/widgets/navigation_item.dart';

import 'package:contactsafe/l10n/app_localizations.dart';
import 'package:contactsafe/l10n/locale_provider.dart';

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
  String _currentLanguage = 'en';
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
      _currentLanguage = settings['language'] ?? 'en';
      _sortByFirstName = settings['sortByFirstName'] ?? false;
      _lastNameFirst = settings['lastNameFirst'] ?? false;
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
    final success = await launchUrl(url);
    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
    }
  }

  Future<void> _importContacts() async {
    try {
      final count = await _controller.importContacts();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported $count contacts!')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing contacts: $e')));
    }
  }

  Future<void> _createBackup() async {
    try {
      final fileName = await _controller.createBackup();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup created successfully at $fileName')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create backup: $e')));
    }
  }

  Future<void> _restoreFromBackup() async {
    try {
      final count = await _controller.restoreFromBackup();
      if (count > 0) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restored $count contacts from backup!')),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to restore backup: $e')));
    }
  }

  Future<void> _backupToGoogleDrive() async {
    try {
      await _controller.backupToGoogleDrive();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup uploaded to Google Drive')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restoreFromGoogleDrive() async {
    try {
      final count = await _controller.restoreFromGoogleDrive();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restored $count contacts from Google Drive')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  Future<void> _importBackupFromLink(String url) async {
    try {
      final count = await _controller.importBackupFromLink(url);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $count contacts from link')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  Future<String?> _promptForLink() async {
    String? url;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter backup link'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'https://...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                url = controller.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
    if (url != null && url!.isEmpty) {
      url = null;
    }
    return url;
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.loc.translate('deleteAll') + ' Data?'),
          content: Text(
            'Are you sure you want to delete ALL data from ContactSafe? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllApplicationData();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                context.loc.translate('deleteAll'),
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
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
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All application data has been deleted.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete all data: $e')));
    }
  }

  Future<String?> _showCreatePinDialog() async {
    String? pin;
    String? confirmPin;
    String? error;

    // First PIN entry
    pin = await showDialog<String>(
      context: context,
      builder:
          (context) => PinDialog(title: 'Create a 4-digit PIN', error: error),
    );

    if (pin == null) {
      return null;
    }

    // Confirm PIN
    confirmPin = await showDialog<String>(
      context: context,
      builder: (context) => PinDialog(title: 'Confirm your PIN', error: error),
    );

    if (confirmPin == null) {
      return null;
    }

    if (pin != confirmPin) {
      if (!mounted) {
        return null; // Check if the widget is still mounted
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match. Please try again.')),
      );
      return await _showCreatePinDialog(); // Recursive call to retry
    }

    return pin;
  }

  Future<bool> _showVerifyPinDialog() async {
    final hasPin = await _controller.hasPin();
    if (!hasPin) {
      return true;
    }

    bool verified = false;
    String? error;

    while (!verified) {
      final enteredPin = await showDialog<String>(
        context: context,
        builder: (context) => PinDialog(title: 'Enter your PIN', error: error),
      );

      if (enteredPin == null) {
        return false;
      }

      verified = await _controller.verifyPin(enteredPin);
      if (!verified) {
        error = 'Incorrect PIN. Please try again.';
      }
    }

    return true;
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
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Biometrics enabled.')));
        } else {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication failed or canceled.')),
          );
        }
      } else {
        setState(() => _useFaceId = false);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No biometrics available.')),
        );
      }
    } else {
      setState(() => _useFaceId = false);
      await _controller.saveUseFaceIdSetting(false);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Biometrics disabled.')));
    }
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'de':
        return 'German';
      case 'mn':
        return 'Mongolian';
      default:
        return 'English';
    }
  }

  Future<void> _showLanguageDialog() async {
    final options = [
      {'code': 'en', 'label': 'English', 'icon': Icons.language},
      {'code': 'de', 'label': 'German', 'icon': Icons.language},
      {'code': 'mn', 'label': 'Mongolian', 'icon': Icons.language},
    ];
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.language,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Divider(),
              ...options.map((opt) {
                final isSelected = opt['code'] == _currentLanguage;
                return ListTile(
                  leading: Icon(
                    opt['icon'] as IconData,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                  ),
                  title: Text(opt['label'] as String),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () => Navigator.pop(context, opt['code']),
                  selected: isSelected,
                );
              }),
              const SizedBox(height: 12),
              TextButton(
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _currentLanguage = selected);
      await _controller.saveLanguage(selected);
      Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).setLocale(Locale(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.loc.translate('appTitle'),
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
      ),
      body: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.surface,
          settingsSectionBackground: Theme.of(context).colorScheme.surface,
          titleTextColor: Theme.of(context).colorScheme.primary,
          settingsTileTextColor: Theme.of(context).colorScheme.onSurface,
          tileDescriptionTextColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          dividerColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.5),
        ),
        darkTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.surface,
          settingsSectionBackground: Theme.of(context).colorScheme.surface,
          titleTextColor: Theme.of(context).colorScheme.primary,
          settingsTileTextColor: Theme.of(context).colorScheme.onSurface,
          tileDescriptionTextColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          dividerColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.5),
        ),
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
                  Text(
                    context.loc.translate('settings'),
                    style: TextStyle(
                      fontSize: 31.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
          SettingsSection(
            title: Text(
              'Privacy',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Open in "Settings" app'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed: (context) async => await openAppSettings(),
              ),
              SettingsTile.navigation(
                title: Text(context.loc.translate('language')),
                trailing: Text(
                  _languageLabel(_currentLanguage),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                onPressed: (context) => _showLanguageDialog(),
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'About',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Version'),
                trailing: Text(
                  '1.0.1 (90)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 15.0,
                  ),
                ),
                onPressed: (context) {},
              ),
              SettingsTile.navigation(
                title: const Text('Imprint'),
                trailing: Icon(
                  Icons.open_in_new,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed:
                    (context) => _launchUrl(
                      'https://contactsafe.eu/index.php/impressum',
                    ),
              ),
              SettingsTile.navigation(
                title: const Text('Privacy Policy'),
                trailing: Icon(
                  Icons.open_in_new,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed:
                    (context) => _launchUrl(
                      'https://contactsafe.eu/index.php/datenschutzerklaerung',
                    ),
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'General',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Sort by first name'),
                initialValue: _sortByFirstName,
                onToggle: (value) async {
                  setState(() => _sortByFirstName = value);
                  await _controller.saveSortByFirstName(value);
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Last name first'),
                initialValue: _lastNameFirst,
                onToggle: (value) async {
                  setState(() => _lastNameFirst = value);
                  await _controller.saveLastNameFirst(value);
                },
              ),
            ],
          ),
          //------------------------------------------------------------------------------------
          SettingsSection(
            title: Text(
              'Data Management',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            //------------------------------------------------------------------------------------
            tiles: [
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Import contacts',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPressed: (context) => _importContacts(),
              ),
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Create backup',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPressed: (context) => _createBackup(),
              ),
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Restore from backup',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPressed: (context) => _restoreFromBackup(),
              ),
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Backup to Google Drive',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPressed: (context) => _backupToGoogleDrive(),
              ),
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Restore from Google Drive',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPressed: (context) => _restoreFromGoogleDrive(),
              ),
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Import backup from link',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPressed: (context) async {
                  final url = await _promptForLink();
                  if (url != null) {
                    _importBackupFromLink(url);
                  }
                },
              ),
            ],
          ),
          //------------------------------------------------------------------------------------
          SettingsSection(
            title: Text(
              'App Customization & Reset',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            tiles: [
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Onboard Tour',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Select TabBar order',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('TabBar order updated successfully!'),
                      ),
                    );
                  }
                },
              ),
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    'Delete all app data',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                onPressed: (context) => _showDeleteConfirmationDialog(),
              ),
            ],
          ),
          //------------------------------------------------------------------------------------
          SettingsSection(
            title: Text(
              'Security',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Use PIN'),
                initialValue: _usePass,
                onToggle: (value) async {
                  if (value) {
                    // Enable PIN
                    final pin = await _showCreatePinDialog();
                    if (pin != null && pin.length == 4) {
                      await _controller.savePin(pin);
                      setState(() => _usePass = true);
                      await _controller.saveUsePasswordSetting(true);
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN enabled.')),
                      );
                    } else {
                      setState(() => _usePass = false);
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PIN setup canceled or invalid.'),
                        ),
                      );
                    }
                  } else {
                    // Disable PIN
                    final verified = await _showVerifyPinDialog();
                    if (verified) {
                      await _controller.deletePin();
                      setState(() => _usePass = false);
                      await _controller.saveUsePasswordSetting(false);
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN disabled.')),
                      );
                    }
                  }
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Use Biometrics (Face ID/Fingerprint)'),
                initialValue: _useFaceId,
                onToggle: _handleBiometricToggle,
              ),
              if (_usePass)
                SettingsTile.navigation(
                  title: Text(
                    'Change PIN',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: (context) async {
                    final verified = await _showVerifyPinDialog();
                    if (verified) {
                      final newPin = await _showCreatePinDialog();
                      if (newPin != null && newPin.length == 4) {
                        await _controller.savePin(newPin);
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PIN changed successfully'),
                          ),
                        );
                      } else {
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PIN change canceled or invalid.'),
                          ),
                        );
                      }
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
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
