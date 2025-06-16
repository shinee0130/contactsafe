import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_mn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('mn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'contactSafe'**
  String get appTitle;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos'**
  String get noPhotos;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Convenience method to access a localized string by [key].
  /// Returns the key itself if no matching message is found.
  String translate(String key) {
    switch (key) {
      case 'appTitle':
        return appTitle;
      case 'contacts':
        return contacts;
      case 'search':
        return search;
      case 'events':
        return events;
      case 'photos':
        return photos;
      case 'settings':
        return settings;
      case 'group':
        return group;
      case 'noPhotos':
        return noPhotos;
      case 'deleteAll':
        return deleteAll;
      case 'language':
        return language;
      case 'noResults':
        return noResults;
      case 'privacy':
        return 'Privacy';
      case 'open_in_settings_app':
        return 'Open in "Settings" app';
      case 'about':
        return 'About';
      case 'version':
        return 'Version';
      case 'imprint':
        return 'Imprint';
      case 'privacy_policy':
        return 'Privacy Policy';
      case 'general':
        return 'General';
      case 'sort_by_first_name':
        return 'Sort by first name';
      case 'last_name_first':
        return 'Last name first';
      case 'data_management':
        return 'Data Management';
      case 'import_contacts':
        return 'Import contacts';
      case 'create_backup':
        return 'Create backup';
      case 'restore_from_backup':
        return 'Restore from backup';
      case 'backup_to_google_drive':
        return 'Backup to Google Drive';
      case 'restore_from_google_drive':
        return 'Restore from Google Drive';
      case 'import_backup_from_link':
        return 'Import backup from link';
      case 'app_customization_and_reset':
        return 'App Customization & Reset';
      case 'onboard_tour':
        return 'Onboard Tour';
      case 'select_tabbar_order':
        return 'Select TabBar order';
      case 'select_tabbar_order_title':
        return 'Select TabBar Order';
      case 'delete_all_app_data':
        return 'Delete all app data';
      case 'security':
        return 'Security';
      case 'use_pin':
        return 'Use PIN';
      case 'use_biometrics':
        return 'Use Biometrics (Face ID/Fingerprint)';
      case 'change_pin':
        return 'Change PIN';
      case 'powered_by_inappsettingkit':
        return 'Powered by InAppSettingKit';
      case 'tabbar_order_updated':
        return 'TabBar order updated successfully!';
      case 'could_not_open_url':
        return 'Could not open {url}';
      case 'successfully_imported_contacts':
        return 'Successfully imported {count} contacts!';
      case 'error_importing_contacts':
        return 'Error importing contacts: {error}';
      case 'backup_created_successfully':
        return 'Backup created successfully at {fileName}';
      case 'failed_to_create_backup':
        return 'Failed to create backup: {error}';
      case 'restored_contacts_from_backup':
        return 'Restored {count} contacts from backup!';
      case 'failed_to_restore_backup':
        return 'Failed to restore backup: {error}';
      case 'backup_uploaded_to_google_drive':
        return 'Backup uploaded to Google Drive';
      case 'backup_failed':
        return 'Backup failed: {error}';
      case 'restored_contacts_from_google_drive':
        return 'Restored {count} contacts from Google Drive';
      case 'restore_failed':
        return 'Restore failed: {error}';
      case 'imported_contacts_from_link':
        return 'Imported {count} contacts from link';
      case 'import_failed':
        return 'Import failed: {error}';
      case 'all_app_data_deleted':
        return 'All application data has been deleted.';
      case 'failed_to_delete_all_data':
        return 'Failed to delete all data: {error}';
      case 'pin_enabled':
        return 'PIN enabled.';
      case 'pin_setup_canceled_or_invalid':
        return 'PIN setup canceled or invalid.';
      case 'pin_disabled':
        return 'PIN disabled.';
      case 'pin_changed_successfully':
        return 'PIN changed successfully';
      case 'pin_change_canceled_or_invalid':
        return 'PIN change canceled or invalid.';
      case 'biometrics_enabled':
        return 'Biometrics enabled.';
      case 'authentication_failed_or_canceled':
        return 'Authentication failed or canceled.';
      case 'no_biometrics_available':
        return 'No biometrics available.';
      case 'biometrics_disabled':
        return 'Biometrics disabled.';
      case 'pins_do_not_match':
        return 'PINs do not match. Please try again.';
      case 'create_a_4_digit_pin':
        return 'Create a 4-digit PIN';
      case 'confirm_your_pin':
        return 'Confirm your PIN';
      case 'enter_your_pin':
        return 'Enter your PIN';
      case 'incorrect_pin_try_again':
        return 'Incorrect PIN. Please try again.';
      case 'enter_backup_link':
        return 'Enter backup link';
      case 'import':
        return 'Import';
      default:
        return key;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'mn':
      return AppLocalizationsMn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

/// Extension on [BuildContext] to easily access [AppLocalizations].
extension AppLocalizationsX on BuildContext {
  /// Shorthand for `AppLocalizations.of(this)!`.
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
