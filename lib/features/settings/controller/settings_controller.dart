import 'dart:convert';
import 'dart:io';
import 'package:contactsafe/shared/widgets/navigation_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
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
      'language': prefs.getString('language') ?? 'en',
      'sortByFirstName': prefs.getBool('sortByFirstName') ?? false,
      'lastNameFirst': prefs.getBool('lastNameFirst') ?? false,
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

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en';
  }

  Future<void> saveSortByFirstName(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sortByFirstName', value);
  }

  Future<bool> loadSortByFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sortByFirstName') ?? false;
  }

  Future<void> saveLastNameFirst(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lastNameFirst', value);
  }

  Future<bool> loadLastNameFirst() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('lastNameFirst') ?? false;
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
      final backupDir = Directory('${directory.path}/ContactSafe');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final String filePath =
          '${backupDir.path}/backup_${_formatDateTime(DateTime.now())}.json';
      final File file = File(filePath);

      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
      }

      final List<Map<String, dynamic>> contactsData = contacts.map((c) {
        return {
          'id': c.id,
          'displayName': c.displayName,
          'phones': c.phones.map((p) => p.number).toList(),
          'emails': c.emails.map((e) => e.address).toList(),
        };
      }).toList();

      await file.writeAsString(jsonEncode(contactsData));
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
        if (await FlutterContacts.requestPermission()) {
          for (final item in decodedData) {
            try {
              final contact = Contact()
                ..name = Name(first: item['firstName'] ?? '', last: item['lastName'] ?? '')
                ..phones = (item['phones'] as List?)
                        ?.map((p) => Phone(p.toString()))
                        .toList() ?? []
                ..emails = (item['emails'] as List?)
                        ?.map((e) => Email(e.toString()))
                        .toList() ?? [];
              await contact.insert();
            } catch (_) {}
          }
        }
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

  // Backup to Google Drive
  Future<void> backupToGoogleDrive() async {
    final fileName = await createBackup();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ContactSafe/$fileName');
    final GoogleSignInAccount? account = await GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]).signIn();
    if (account == null) throw Exception('Google sign in failed');
    final authHeaders = await account.authHeaders;
    final client = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(client);
    final driveFile = drive.File()..name = fileName;
    await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(file.openRead(), await file.length()),
    );
  }

  // Restore from Google Drive (downloads the most recent backup)
  Future<int> restoreFromGoogleDrive() async {
    final GoogleSignInAccount? account = await GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]).signIn();
    if (account == null) throw Exception('Google sign in failed');
    final authHeaders = await account.authHeaders;
    final client = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(client);
    final fileList = await driveApi.files.list(q: "name contains 'backup_'", spaces: 'drive', orderBy: 'createdTime desc');
    if (fileList.files == null || fileList.files!.isEmpty) {
      throw Exception('No backup file found');
    }
    final fileId = fileList.files!.first.id;
    if (fileId == null) throw Exception('Invalid file id');
    final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final bytes = await media.stream.toBytes();
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/ContactSafe');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final path = '${backupDir.path}/restored_${_formatDateTime(DateTime.now())}.json';
    final file = File(path);
    await file.writeAsBytes(bytes);
    final data = jsonDecode(utf8.decode(bytes)) as List<dynamic>;
    if (await FlutterContacts.requestPermission()) {
      for (final item in data) {
        try {
          final contact = Contact()
            ..name = Name(first: item['firstName'] ?? '', last: item['lastName'] ?? '')
            ..phones = (item['phones'] as List?)?.map((p) => Phone(p.toString())).toList() ?? []
            ..emails = (item['emails'] as List?)?.map((e) => Email(e.toString())).toList() ?? [];
          await contact.insert();
        } catch (_) {}
      }
    }
    return data.length;
  }

  // Import backup from link
  Future<int> importBackupFromLink(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/ContactSafe');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final path = '${backupDir.path}/imported_${_formatDateTime(DateTime.now())}.json';
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);
      final data = jsonDecode(response.body) as List<dynamic>;
      if (await FlutterContacts.requestPermission()) {
        for (final item in data) {
          try {
            final contact = Contact()
              ..name = Name(first: item['firstName'] ?? '', last: item['lastName'] ?? '')
              ..phones = (item['phones'] as List?)?.map((p) => Phone(p.toString())).toList() ?? []
              ..emails = (item['emails'] as List?)?.map((e) => Email(e.toString())).toList() ?? [];
            await contact.insert();
          } catch (_) {}
        }
      }
      return data.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error importing from link: $e');
      }
      throw Exception('Failed to import backup from link: $e');
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

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}
