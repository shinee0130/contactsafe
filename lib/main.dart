import 'package:contactsafe/core/theme/theme.dart';
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
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:contactsafe/app.dart';
import 'package:contactsafe/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Sign in anonymously if not already signed in
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  // await FirebaseAppCheck.instance.activate(
  //   webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.appAttest,
  // );

  final settingsController = SettingsController();
  final pinEnabled = await settingsController.hasPinEnabled();
  final languageCode = await settingsController.loadLanguage();

  runApp(
    ChangeNotifierProvider<LocaleProvider>(
      create: (_) => LocaleProvider(Locale(languageCode)),
      child: ContactSafeRoot(
        settingsController: settingsController,
        pinEnabled: pinEnabled,
      ),
    ),
  );
}

class ContactSafeRoot extends StatelessWidget {
  final SettingsController settingsController;
  final bool pinEnabled;

  const ContactSafeRoot({
    super.key,
    required this.settingsController,
    required this.pinEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'ContactSafe',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('mn')],
      initialRoute: '/',
      routes: {
        '/': (context) => pinEnabled
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
        '/contact_detail': (context) => ContactDetailScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
        '/add_contact': (context) => const AddContactScreen(),
        '/groups': (context) => const ContactGroupsScreen(),
        '/contact_files': (context) => ContactFilesScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
        '/contact_notes': (context) => ContactNotesScreen(
              contact: ModalRoute.of(context)!.settings.arguments as Contact,
            ),
      },
    );
  }
}
