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
import 'package:contactsafe/l10n/context_loc.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.could_not_open_url(urlString),
          ),
        ),
      );
    }
  }

  Future<void> _importContacts() async {
    try {
      final count = await _controller.importContacts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.successfully_imported_contacts(count),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.error_importing_contacts(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _createBackup() async {
    try {
      final fileName = await _controller.createBackup();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.backup_created_successfully(fileName),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.failed_to_create_backup(e.toString()),
          ),
        ),
      );
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
          SnackBar(
            content: Text(
              context.loc.restored_contacts_from_backup(count),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.failed_to_restore_backup(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _backupToGoogleDrive() async {
    try {
      await _controller.backupToGoogleDrive();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.backup_uploaded_to_google_drive)),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.backup_failed(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _restoreFromGoogleDrive() async {
    try {
      final count = await _controller.restoreFromGoogleDrive();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.restored_contacts_from_google_drive(count),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.restore_failed(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _importBackupFromLink(String url) async {
    try {
      final count = await _controller.importBackupFromLink(url);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.imported_contacts_from_link(count),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.import_failed(e.toString()),
          ),
        ),
      );
    }
  }

  Future<String?> _promptForLink() async {
    String? url;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(context.loc.enter_backup_link),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'https://...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () {
                url = controller.text.trim();
                Navigator.of(context).pop();
              },
              child: Text(context.loc.import),
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
          title: Text(context.loc.delete_all_data),
          content: Text(context.loc.delete_all_data_confirm),
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
                context.loc.deleteAll,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.loc.all_app_data_deleted)));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.loc.failed_to_delete_all_data(e.toString()),
          ),
        ),
      );
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
          (context) =>
              PinDialog(title: context.loc.create_a_4_digit_pin, error: error),
    );

    if (pin == null) {
      return null;
    }

    // Confirm PIN
    confirmPin = await showDialog<String>(
      context: context,
      builder:
          (context) =>
              PinDialog(title: context.loc.confirm_your_pin, error: error),
    );

    if (confirmPin == null) {
      return null;
    }

    if (pin != confirmPin) {
      if (!mounted) {
        return null; // Check if the widget is still mounted
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.loc.pins_do_not_match)));
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
        builder:
            (context) =>
                PinDialog(title: context.loc.enter_your_pin, error: error),
      );

      if (enteredPin == null) {
        return false;
      }

      verified = await _controller.verifyPin(enteredPin);
      if (!verified) {
        error = context.loc.incorrect_pin_try_again;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.loc.biometrics_enabled)),
          );
        } else {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.loc.authentication_failed_or_canceled),
            ),
          );
        }
      } else {
        setState(() => _useFaceId = false);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.loc.no_biometrics_available)),
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
      ).showSnackBar(SnackBar(content: Text(context.loc.biometrics_disabled)));
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
              context.loc.appTitle,
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
                    context.loc.settings,
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
              context.loc.privacy,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Text(context.loc.open_in_settings_app),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed: (context) async => await openAppSettings(),
              ),
              SettingsTile.navigation(
                title: Text(context.loc.language),
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
              context.loc.about,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            tiles: [
              SettingsTile.navigation(
                title: Text(context.loc.version),
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
                title: Text(context.loc.imprint),
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
                title: Text(context.loc.privacy_policy),
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
              context.loc.general,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            tiles: [
              SettingsTile.switchTile(
                title: Text(context.loc.sort_by_first_name),
                initialValue: _sortByFirstName,
                onToggle: (value) async {
                  setState(() => _sortByFirstName = value);
                  await _controller.saveSortByFirstName(value);
                },
              ),
              SettingsTile.switchTile(
                title: Text(context.loc.last_name_first),
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
              context.loc.data_management,
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
                    context.loc.import_contacts,
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
                    context.loc.create_backup,
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
                    context.loc.restore_from_backup,
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
                    context.loc.backup_to_google_drive,
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
                    context.loc.restore_from_google_drive,
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
                    context.loc.import_backup_from_link,
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
              context.loc.app_customization_and_reset,
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
                    context.loc.onboard_tour,
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
                    context.loc.select_tabbar_order,
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
                      SnackBar(content: Text(context.loc.tabbar_order_updated)),
                    );
                  }
                },
              ),
              //------------------------------------------------------------------------------------
              SettingsTile.navigation(
                title: Center(
                  child: Text(
                    context.loc.delete_all_app_data,
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
              context.loc.security,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            tiles: [
              SettingsTile.switchTile(
                title: Text(context.loc.use_pin),
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
                        SnackBar(content: Text(context.loc.pin_enabled)),
                      );
                    } else {
                      setState(() => _usePass = false);
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.loc.pin_setup_canceled_or_invalid,
                          ),
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
                        SnackBar(content: Text(context.loc.pin_disabled)),
                      );
                    }
                  }
                },
              ),
              SettingsTile.switchTile(
                title: Text(context.loc.use_biometrics),
                initialValue: _useFaceId,
                onToggle: _handleBiometricToggle,
              ),
              if (_usePass)
                SettingsTile.navigation(
                  title: Text(
                    context.loc.change_pin,
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
                          SnackBar(
                            content: Text(context.loc.pin_changed_successfully),
                          ),
                        );
                      } else {
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.loc.pin_change_canceled_or_invalid,
                            ),
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
                context.loc.powered_by_inappsettingkit,
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
