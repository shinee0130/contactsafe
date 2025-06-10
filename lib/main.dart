import 'package:contactsafe/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_detail_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_files_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_group_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contact_notes_screen.dart';
import 'package:contactsafe/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:contactsafe/features/events/presentation/screens/events_screen.dart';
import 'package:contactsafe/features/photos/presentation/screens/photos_screen.dart';
import 'package:contactsafe/features/search/presentation/screens/search_screen.dart';
import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:contactsafe/features/settings/presentation/screens/pin_verification_screen.dart';
import 'package:contactsafe/features/settings/presentation/screens/settings_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:contactsafe/app.dart';
import 'package:contactsafe/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  runApp(ContactSafeApp());

  // You have this line twice. You only need it once at the very beginning of main.
  // WidgetsFlutterBinding.ensureInitialized(); // <-- This line can be removed

  final settingsController = SettingsController();
  final pinEnabled = await settingsController.hasPinEnabled();

  runApp(
    MaterialApp(
      title: 'ContactSafe',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':
            (context) =>
                pinEnabled
                    ? PinVerificationGate(
                      controller: settingsController,
                      child: ContactSafeApp(),
                    )
                    : ContactSafeApp(),
        '/contacts': (context) => const ContactsScreen(),
        '/search': (context) => const SearchScreen(),
        '/events': (context) => const EventsScreen(),
        '/photos': (context) => const PhotosScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/contact_detail':
            (context) => ContactDetailScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
        '/add_contact': (context) => const AddContactScreen(),
        '/groups': (context) => const ContactGroupsScreen(),
        '/contact_files':
            (context) => ContactFilesScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
        '/contact_notes':
            (context) => ContactNotesScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
      },
    ),
  );
}
