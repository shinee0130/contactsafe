import 'dart:convert';
import 'dart:io';
import 'package:contactsafe/shared/widgets/navigation_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:file_picker/file_picker.dart';

class SettingsController {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _pinKey = 'user_pin';
  static const String _usePasswordKey = 'usePassword';

  // Load all settings
  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'usePassword': prefs.getBool('usePassword') ?? false,
      'useFaceId': prefs.getBool('useFaceId') ?? false,
      'tabBarOrder': await _loadTabBarOrder(prefs),
    };
  }

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await prefs.setBool(_usePasswordKey, true);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    return savedPin == pin;
  }

  Future<void> deletePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.setBool(_usePasswordKey, false);
  }

  Future<bool> hasPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_usePasswordKey) ?? false;
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  // Save FaceID setting
  Future<void> saveUseFaceIdSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useFaceId', value);
    if (kDebugMode) {
      print('Saved useFaceId: $value');
    }
  }

  // Load TabBar order
  Future<List<NavigationItem>> _loadTabBarOrder(SharedPreferences prefs) async {
    final String? savedOrderJson = prefs.getString('tabBarOrder');
    if (savedOrderJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(savedOrderJson);
        return decodedList
            .map(
              (itemJson) =>
                  NavigationItem.fromJson(itemJson as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding saved TabBar order: $e');
        }
        return NavigationItem.defaultItems();
      }
    } else {
      if (kDebugMode) {
        print('No saved TabBar order found, using default.');
      }
      return NavigationItem.defaultItems();
    }
  }

  // Save TabBar order
  Future<void> saveTabBarOrder(List<NavigationItem> newOrder) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> orderToJson =
        newOrder.map((item) => item.toJson()).toList();
    await prefs.setString('tabBarOrder', jsonEncode(orderToJson));
    if (kDebugMode) {
      print('Saved TabBar order: ${newOrder.map((e) => e.label).join(', ')}');
    }
  }

  // Import contacts
  Future<int> importContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        return contacts.length;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error importing contacts: $e');
      }
      throw Exception('Failed to import contacts: $e');
    }
  }

  // Create backup
  Future<String> createBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/contactsafe_backup_${_formatDateTime(DateTime.now())}.json';
      final File file = File(filePath);

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

      await file.writeAsString(jsonEncode(dummyContactsData));
      return file.path.split('/').last;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating backup: $e');
      }
      throw Exception('Failed to create backup: $e');
    }
  }

  // Restore from backup
  Future<int> restoreFromBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileContent = await file.readAsString();
        final List<dynamic> decodedData = jsonDecode(fileContent);
        return decodedData.length;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring backup: $e');
      }
      throw Exception('Failed to restore backup: $e');
    }
  }

  // Delete all application data
  Future<void> deleteAllApplicationData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        final List<FileSystemEntity> files = directory.listSync();
        for (final file in files) {
          if (file.path.contains('contactsafe_backup_')) {
            await file.delete();
          }
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all data: $e');
      }
      throw Exception('Failed to delete all data: $e');
    }
  }

  // Check biometric availability
  Future<Map<String, dynamic>> checkBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    List<BiometricType> availableBiometrics =
        await _localAuth.getAvailableBiometrics();
    return {
      'canCheckBiometrics': canCheckBiometrics,
      'availableBiometrics': availableBiometrics,
    };
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    return await _localAuth.authenticate(
      localizedReason: 'Please authenticate to enable FaceID/Fingerprint',
      options: const AuthenticationOptions(stickyAuth: true),
    );
  }

  // Helper function to format DateTime for filename
  String _formatDateTime(DateTime dateTime) {
    String twoDigits(int n) => n >= 10 ? '$n' : '0$n';
    return '${dateTime.year}${twoDigits(dateTime.month)}${twoDigits(dateTime.day)}_${twoDigits(dateTime.hour)}${twoDigits(dateTime.minute)}${twoDigits(dateTime.second)}';
  }

  Future<void> saveUsePasswordSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_usePasswordKey, value);
    if (kDebugMode) {
      print('Saved usePassword: $value');
    }
  }
}
