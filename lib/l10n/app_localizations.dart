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

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEvent;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @selectParticipants.
  ///
  /// In en, this message translates to:
  /// **'Select Participants'**
  String get selectParticipants;

  /// No description provided for @addParticipants.
  ///
  /// In en, this message translates to:
  /// **'Add Participants'**
  String get addParticipants;

  /// No description provided for @chooseLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose Location on Map'**
  String get chooseLocationOnMap;

  /// No description provided for @eventAdded.
  ///
  /// In en, this message translates to:
  /// **'Event added successfully!'**
  String get eventAdded;

  /// No description provided for @failedToAddEvent.
  ///
  /// In en, this message translates to:
  /// **'Failed to add event'**
  String get failedToAddEvent;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @createContact.
  ///
  /// In en, this message translates to:
  /// **'Create contact'**
  String get createContact;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @pager.
  ///
  /// In en, this message translates to:
  /// **'Pager'**
  String get pager;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @addPhone.
  ///
  /// In en, this message translates to:
  /// **'Add phone'**
  String get addPhone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @addEmail.
  ///
  /// In en, this message translates to:
  /// **'Add email'**
  String get addEmail;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get enterAddress;

  /// No description provided for @exampleEmail.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get exampleEmail;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @addBirthday.
  ///
  /// In en, this message translates to:
  /// **'Add birthday'**
  String get addBirthday;

  /// No description provided for @changePicture.
  ///
  /// In en, this message translates to:
  /// **'Change picture'**
  String get changePicture;

  /// No description provided for @addPicture.
  ///
  /// In en, this message translates to:
  /// **'Add picture'**
  String get addPicture;

  /// No description provided for @contactSafe.
  ///
  /// In en, this message translates to:
  /// **'contactSafe'**
  String get contactSafe;

  /// No description provided for @contactSavedDevice.
  ///
  /// In en, this message translates to:
  /// **'Contact saved to device!'**
  String get contactSavedDevice;

  /// No description provided for @contactPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Contact permission denied. Cannot save to device.'**
  String get contactPermissionDenied;

  /// No description provided for @contactSavedCloud.
  ///
  /// In en, this message translates to:
  /// **'Contact saved to Cloud Firestore!'**
  String get contactSavedCloud;

  /// No description provided for @failedToSaveContact.
  ///
  /// In en, this message translates to:
  /// **'Failed to save contact: {error}'**
  String failedToSaveContact(Object error);

  /// No description provided for @photoPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission denied.'**
  String get photoPermissionDenied;

  /// No description provided for @photoPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission permanently denied. Please enable in settings.'**
  String get photoPermissionPermanentlyDenied;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @assignToGroup.
  ///
  /// In en, this message translates to:
  /// **'Assign to \"{groupName}\"'**
  String assignToGroup(Object groupName);

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found on your device.'**
  String get noContactsFound;

  /// No description provided for @contactsAssignedToGroup.
  ///
  /// In en, this message translates to:
  /// **'Contacts assigned to \"{groupName}\"'**
  String contactsAssignedToGroup(Object groupName);

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @exportVcf.
  ///
  /// In en, this message translates to:
  /// **'Export VCF'**
  String get exportVcf;

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number available'**
  String get noPhoneNumber;

  /// No description provided for @noEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'No email address available'**
  String get noEmailAddress;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}'**
  String calling(Object name);

  /// No description provided for @messaging.
  ///
  /// In en, this message translates to:
  /// **'Messaging {name}'**
  String messaging(Object name);

  /// No description provided for @emailing.
  ///
  /// In en, this message translates to:
  /// **'Emailing {name}'**
  String emailing(Object name);

  /// No description provided for @favoriteStatusToggled.
  ///
  /// In en, this message translates to:
  /// **'{name} favorite status toggled!'**
  String favoriteStatusToggled(Object name);

  /// No description provided for @contactExported.
  ///
  /// In en, this message translates to:
  /// **'Contact exported to: {filePath}'**
  String contactExported(Object filePath);

  /// No description provided for @errorAccessingStorage.
  ///
  /// In en, this message translates to:
  /// **'Error accessing storage.'**
  String get errorAccessingStorage;

  /// No description provided for @errorSavingVcf.
  ///
  /// In en, this message translates to:
  /// **'Error saving VCF file: {error}'**
  String errorSavingVcf(Object error);

  /// No description provided for @storagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied. Please enable in settings.'**
  String get storagePermissionDenied;

  /// No description provided for @couldNotLaunchPhone.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone call'**
  String get couldNotLaunchPhone;

  /// No description provided for @couldNotLaunchSms.
  ///
  /// In en, this message translates to:
  /// **'Could not launch messaging app'**
  String get couldNotLaunchSms;

  /// No description provided for @couldNotLaunchEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not launch email app'**
  String get couldNotLaunchEmail;

  /// No description provided for @noFilesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No files available'**
  String get noFilesAvailable;

  /// No description provided for @tapToAddFiles.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add files'**
  String get tapToAddFiles;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @sortFilesBy.
  ///
  /// In en, this message translates to:
  /// **'Sort Files By'**
  String get sortFilesBy;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// No description provided for @dateOldest.
  ///
  /// In en, this message translates to:
  /// **'Date (Oldest first)'**
  String get dateOldest;

  /// No description provided for @dateNewest.
  ///
  /// In en, this message translates to:
  /// **'Date (Newest first)'**
  String get dateNewest;

  /// No description provided for @sizeSmallest.
  ///
  /// In en, this message translates to:
  /// **'Size (Smallest first)'**
  String get sizeSmallest;

  /// No description provided for @sizeLargest.
  ///
  /// In en, this message translates to:
  /// **'Size (Largest first)'**
  String get sizeLargest;

  /// No description provided for @renameFile.
  ///
  /// In en, this message translates to:
  /// **'Rename File'**
  String get renameFile;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @fileDeleted.
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get fileDeleted;

  /// No description provided for @fileDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete file: {error}'**
  String fileDeleteFailed(Object error);

  /// No description provided for @failedToLoadFiles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load files: {error}'**
  String failedToLoadFiles(Object error);

  /// No description provided for @fileUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) uploaded successfully.'**
  String fileUploadSuccess(Object count);

  /// No description provided for @fileUploadFail.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) failed to upload.'**
  String fileUploadFail(Object count);

  /// No description provided for @fileUploadNone.
  ///
  /// In en, this message translates to:
  /// **'No files selected or processed.'**
  String get fileUploadNone;

  /// No description provided for @selectedFilesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Selected files deleted successfully!'**
  String get selectedFilesDeleted;

  /// No description provided for @failedToDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete selected files: {error}'**
  String failedToDeleteSelected(Object error);

  /// No description provided for @failedToRenameFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename file: {error}'**
  String failedToRenameFile(Object error);

  /// No description provided for @failedToShareFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to share file: {error}'**
  String failedToShareFile(Object error);

  /// No description provided for @unableToRetrieveFile.
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve file data'**
  String get unableToRetrieveFile;

  /// No description provided for @failedToOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to open file: {error}'**
  String failedToOpenFile(Object error);

  /// No description provided for @couldNotDownloadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not download file data'**
  String get couldNotDownloadFile;

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open file'**
  String get couldNotOpenFile;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @selectAllGroups.
  ///
  /// In en, this message translates to:
  /// **'Select all groups'**
  String get selectAllGroups;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @enterNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Enter the name for your new group:'**
  String get enterNewGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @okAddContacts.
  ///
  /// In en, this message translates to:
  /// **'Ok & add contacts'**
  String get okAddContacts;

  /// No description provided for @groupExists.
  ///
  /// In en, this message translates to:
  /// **'Group \"{groupName}\" already exists.'**
  String groupExists(Object groupName);

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'contactSafe'**
  String get appName;

  /// No description provided for @notesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'{contactName} - Notes'**
  String notesScreenTitle(Object contactName);

  /// No description provided for @noNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesTitle;

  /// No description provided for @noNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first note'**
  String get noNotesSubtitle;

  /// No description provided for @addNewNote.
  ///
  /// In en, this message translates to:
  /// **'Add New Note'**
  String get addNewNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @writeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note here...'**
  String get writeNoteHint;

  /// No description provided for @noteEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get noteEdited;

  /// No description provided for @failedToLoadNotes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notes: {error}'**
  String failedToLoadNotes(Object error);

  /// No description provided for @failedToAddNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to add note: {error}'**
  String failedToAddNote(Object error);

  /// No description provided for @failedToUpdateNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to update note: {error}'**
  String failedToUpdateNote(Object error);

  /// No description provided for @failedToDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete note: {error}'**
  String failedToDeleteNote(Object error);

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editContact;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContact;

  /// No description provided for @contactUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contact updated successfully!'**
  String get contactUpdated;

  /// No description provided for @contactUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update contact: {error}'**
  String contactUpdateFailed(Object error);

  /// No description provided for @contactDeleted.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted successfully!'**
  String get contactDeleted;

  /// No description provided for @contactDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete contact: {error}'**
  String contactDeleteFailed(Object error);

  /// No description provided for @noteDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteDetailTitle;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @emailAction.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAction;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @exportVCF.
  ///
  /// In en, this message translates to:
  /// **'Export VCF'**
  String get exportVCF;

  /// No description provided for @fileUploaded.
  ///
  /// In en, this message translates to:
  /// **'File uploaded'**
  String get fileUploaded;

  /// No description provided for @fileRenamed.
  ///
  /// In en, this message translates to:
  /// **'File renamed'**
  String get fileRenamed;

  /// No description provided for @noFiles.
  ///
  /// In en, this message translates to:
  /// **'No files available'**
  String get noFiles;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotes;

  /// No description provided for @tapToAddNote.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first note'**
  String get tapToAddNote;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name for your new group'**
  String get enterGroupName;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDate;

  /// No description provided for @eventLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get eventLocation;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescription;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @noParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants added.'**
  String get noParticipants;

  /// No description provided for @mapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map location unavailable. Could not geocode address.'**
  String get mapUnavailable;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please enable in settings.'**
  String get permissionDenied;

  /// No description provided for @sortEventsBy.
  ///
  /// In en, this message translates to:
  /// **'Sort Events By'**
  String get sortEventsBy;

  /// No description provided for @titleAz.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get titleAz;

  /// No description provided for @titleZa.
  ///
  /// In en, this message translates to:
  /// **'Title (Z-A)'**
  String get titleZa;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @noContactsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No contacts available to add.'**
  String get noContactsAvailable;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @locationPermissionRecommended.
  ///
  /// In en, this message translates to:
  /// **'Location permission is recommended for map features.'**
  String get locationPermissionRecommended;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Please enable it in app settings.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @contactsPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is required to add participants.'**
  String get contactsPermissionRequired;

  /// No description provided for @errorFetchingContacts.
  ///
  /// In en, this message translates to:
  /// **'Error fetching contacts'**
  String get errorFetchingContacts;

  /// No description provided for @errorLoadingEvents.
  ///
  /// In en, this message translates to:
  /// **'Error loading events'**
  String get errorLoadingEvents;

  /// No description provided for @locationColon.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get locationColon;

  /// No description provided for @dateColon.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get dateColon;

  /// No description provided for @participantsColon.
  ///
  /// In en, this message translates to:
  /// **'Participants:'**
  String get participantsColon;

  /// No description provided for @descriptionColon.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionColon;

  /// No description provided for @pleaseFillAllEventFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title, select a date, and select a location.'**
  String get pleaseFillAllEventFields;

  /// No description provided for @chooseEventLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose Event Location'**
  String get chooseEventLocation;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to show your current location.'**
  String get locationPermissionNeeded;

  /// No description provided for @couldNotGetCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get current location.'**
  String get couldNotGetCurrentLocation;

  /// No description provided for @pickedLocation.
  ///
  /// In en, this message translates to:
  /// **'Picked Location'**
  String get pickedLocation;

  /// No description provided for @tapToPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to pick a location'**
  String get tapToPickLocation;

  /// No description provided for @selectThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Select This Location'**
  String get selectThisLocation;

  /// No description provided for @failedToLoadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Failed to load photos'**
  String get failedToLoadPhotos;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @user_pin.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get user_pin;

  /// No description provided for @usePassword.
  ///
  /// In en, this message translates to:
  /// **'Use Password'**
  String get usePassword;

  /// No description provided for @useFaceId.
  ///
  /// In en, this message translates to:
  /// **'Use FaceID'**
  String get useFaceId;

  /// No description provided for @tabBarOrder.
  ///
  /// In en, this message translates to:
  /// **'Tab Bar Order'**
  String get tabBarOrder;

  /// No description provided for @sortByFirstName.
  ///
  /// In en, this message translates to:
  /// **'Sort by First Name'**
  String get sortByFirstName;

  /// No description provided for @lastNameFirst.
  ///
  /// In en, this message translates to:
  /// **'Show Last Name First'**
  String get lastNameFirst;

  /// No description provided for @saved_useFaceId.
  ///
  /// In en, this message translates to:
  /// **'Saved useFaceId: {value}'**
  String saved_useFaceId(Object value);

  /// No description provided for @no_saved_tabBar_order.
  ///
  /// In en, this message translates to:
  /// **'No saved TabBar order found, using default.'**
  String get no_saved_tabBar_order;

  /// No description provided for @error_decoding_tabBar_order.
  ///
  /// In en, this message translates to:
  /// **'Error decoding saved TabBar order: {error}'**
  String error_decoding_tabBar_order(Object error);

  /// No description provided for @saved_tabBar_order.
  ///
  /// In en, this message translates to:
  /// **'Saved TabBar order: {labels}'**
  String saved_tabBar_order(Object labels);

  /// No description provided for @error_importing_contacts.
  ///
  /// In en, this message translates to:
  /// **'Error importing contacts: {error}'**
  String error_importing_contacts(Object error);

  /// No description provided for @failed_import_contacts.
  ///
  /// In en, this message translates to:
  /// **'Failed to import contacts: {error}'**
  String failed_import_contacts(Object error);

  /// No description provided for @error_creating_backup.
  ///
  /// In en, this message translates to:
  /// **'Error creating backup: {error}'**
  String error_creating_backup(Object error);

  /// No description provided for @failed_create_backup.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup: {error}'**
  String failed_create_backup(Object error);

  /// No description provided for @failed_to_download_file.
  ///
  /// In en, this message translates to:
  /// **'Failed to download file'**
  String get failed_to_download_file;

  /// No description provided for @error_restoring_backup.
  ///
  /// In en, this message translates to:
  /// **'Error restoring backup: {error}'**
  String error_restoring_backup(Object error);

  /// No description provided for @failed_restore_backup.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore backup: {error}'**
  String failed_restore_backup(Object error);

  /// No description provided for @google_sign_in_failed.
  ///
  /// In en, this message translates to:
  /// **'Google sign in failed'**
  String get google_sign_in_failed;

  /// No description provided for @no_backup_file_found.
  ///
  /// In en, this message translates to:
  /// **'No backup file found'**
  String get no_backup_file_found;

  /// No description provided for @invalid_file_id.
  ///
  /// In en, this message translates to:
  /// **'Invalid file id'**
  String get invalid_file_id;

  /// No description provided for @error_importing_from_link.
  ///
  /// In en, this message translates to:
  /// **'Error importing from link: {error}'**
  String error_importing_from_link(Object error);

  /// No description provided for @failed_import_backup_from_link.
  ///
  /// In en, this message translates to:
  /// **'Failed to import backup from link: {error}'**
  String failed_import_backup_from_link(Object error);

  /// No description provided for @error_deleting_all_data.
  ///
  /// In en, this message translates to:
  /// **'Error deleting all data: {error}'**
  String error_deleting_all_data(Object error);

  /// No description provided for @failed_delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete all data: {error}'**
  String failed_delete_all_data(Object error);

  /// No description provided for @please_authenticate_faceid.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to enable FaceID/Fingerprint'**
  String get please_authenticate_faceid;

  /// No description provided for @pin_enter_title.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get pin_enter_title;

  /// No description provided for @pin_set_title.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get pin_set_title;

  /// No description provided for @pin_error.
  ///
  /// In en, this message translates to:
  /// **'PIN code is incorrect'**
  String get pin_error;

  /// No description provided for @pin_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter PIN code'**
  String get pin_empty_error;

  /// No description provided for @pin_placeholder.
  ///
  /// In en, this message translates to:
  /// **'•'**
  String get pin_placeholder;

  /// No description provided for @pin_button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pin_button_cancel;

  /// No description provided for @pin_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pin_dialog_title;

  /// No description provided for @pin_dialog_error.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get pin_dialog_error;

  /// No description provided for @select_tabbar_order_title.
  ///
  /// In en, this message translates to:
  /// **'Select TabBar Order'**
  String get select_tabbar_order_title;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @open_in_settings_app.
  ///
  /// In en, this message translates to:
  /// **'Open in \"Settings\" app'**
  String get open_in_settings_app;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @imprint.
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get imprint;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @sort_by_first_name.
  ///
  /// In en, this message translates to:
  /// **'Sort by first name'**
  String get sort_by_first_name;

  /// No description provided for @last_name_first.
  ///
  /// In en, this message translates to:
  /// **'Last name first'**
  String get last_name_first;

  /// No description provided for @data_management.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get data_management;

  /// No description provided for @import_contacts.
  ///
  /// In en, this message translates to:
  /// **'Import contacts'**
  String get import_contacts;

  /// No description provided for @create_backup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get create_backup;

  /// No description provided for @restore_from_backup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restore_from_backup;

  /// No description provided for @backup_to_google_drive.
  ///
  /// In en, this message translates to:
  /// **'Backup to Google Drive'**
  String get backup_to_google_drive;

  /// No description provided for @restore_from_google_drive.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get restore_from_google_drive;

  /// No description provided for @import_backup_from_link.
  ///
  /// In en, this message translates to:
  /// **'Import backup from link'**
  String get import_backup_from_link;

  /// No description provided for @app_customization_and_reset.
  ///
  /// In en, this message translates to:
  /// **'App Customization & Reset'**
  String get app_customization_and_reset;

  /// No description provided for @onboard_tour.
  ///
  /// In en, this message translates to:
  /// **'Onboard Tour'**
  String get onboard_tour;

  /// No description provided for @select_tabbar_order.
  ///
  /// In en, this message translates to:
  /// **'Select TabBar order'**
  String get select_tabbar_order;

  /// No description provided for @delete_all_app_data.
  ///
  /// In en, this message translates to:
  /// **'Delete all app data'**
  String get delete_all_app_data;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @use_pin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get use_pin;

  /// No description provided for @use_biometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics (Face ID/Fingerprint)'**
  String get use_biometrics;

  /// No description provided for @change_pin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get change_pin;

  /// No description provided for @powered_by_inappsettingkit.
  ///
  /// In en, this message translates to:
  /// **'Powered by InAppSettingKit'**
  String get powered_by_inappsettingkit;

  /// No description provided for @delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get delete_all_data;

  /// No description provided for @delete_all_data_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete ALL data from ContactSafe? This action cannot be undone.'**
  String get delete_all_data_confirm;

  /// No description provided for @successfully_imported_contacts.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} contacts!'**
  String successfully_imported_contacts(Object count);

  /// No description provided for @backup_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully at {fileName}'**
  String backup_created_successfully(Object fileName);

  /// No description provided for @failed_to_create_backup.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup: {error}'**
  String failed_to_create_backup(Object error);

  /// No description provided for @restored_contacts_from_backup.
  ///
  /// In en, this message translates to:
  /// **'Restored {count} contacts from backup!'**
  String restored_contacts_from_backup(Object count);

  /// No description provided for @failed_to_restore_backup.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore backup: {error}'**
  String failed_to_restore_backup(Object error);

  /// No description provided for @backup_uploaded_to_google_drive.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded to Google Drive'**
  String get backup_uploaded_to_google_drive;

  /// No description provided for @backup_failed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backup_failed(Object error);

  /// No description provided for @restored_contacts_from_google_drive.
  ///
  /// In en, this message translates to:
  /// **'Restored {count} contacts from Google Drive'**
  String restored_contacts_from_google_drive(Object count);

  /// No description provided for @restore_failed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restore_failed(Object error);

  /// No description provided for @imported_contacts_from_link.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} contacts from link'**
  String imported_contacts_from_link(Object count);

  /// No description provided for @import_failed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String import_failed(Object error);

  /// No description provided for @could_not_open_url.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String could_not_open_url(Object url);

  /// No description provided for @tabbar_order_updated.
  ///
  /// In en, this message translates to:
  /// **'TabBar order updated successfully!'**
  String get tabbar_order_updated;

  /// No description provided for @all_app_data_deleted.
  ///
  /// In en, this message translates to:
  /// **'All application data has been deleted.'**
  String get all_app_data_deleted;

  /// No description provided for @failed_to_delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete all data: {error}'**
  String failed_to_delete_all_data(Object error);

  /// No description provided for @pins_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Please try again.'**
  String get pins_do_not_match;

  /// No description provided for @pin_enabled.
  ///
  /// In en, this message translates to:
  /// **'PIN enabled.'**
  String get pin_enabled;

  /// No description provided for @pin_setup_canceled_or_invalid.
  ///
  /// In en, this message translates to:
  /// **'PIN setup canceled or invalid.'**
  String get pin_setup_canceled_or_invalid;

  /// No description provided for @pin_disabled.
  ///
  /// In en, this message translates to:
  /// **'PIN disabled.'**
  String get pin_disabled;

  /// No description provided for @pin_changed_successfully.
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully'**
  String get pin_changed_successfully;

  /// No description provided for @pin_change_canceled_or_invalid.
  ///
  /// In en, this message translates to:
  /// **'PIN change canceled or invalid.'**
  String get pin_change_canceled_or_invalid;

  /// No description provided for @biometrics_enabled.
  ///
  /// In en, this message translates to:
  /// **'Biometrics enabled.'**
  String get biometrics_enabled;

  /// No description provided for @authentication_failed_or_canceled.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed or canceled.'**
  String get authentication_failed_or_canceled;

  /// No description provided for @no_biometrics_available.
  ///
  /// In en, this message translates to:
  /// **'No biometrics available.'**
  String get no_biometrics_available;

  /// No description provided for @biometrics_disabled.
  ///
  /// In en, this message translates to:
  /// **'Biometrics disabled.'**
  String get biometrics_disabled;

  /// No description provided for @enter_backup_link.
  ///
  /// In en, this message translates to:
  /// **'Enter backup link'**
  String get enter_backup_link;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @create_a_4_digit_pin.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN'**
  String get create_a_4_digit_pin;

  /// No description provided for @confirm_your_pin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirm_your_pin;

  /// No description provided for @enter_your_pin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enter_your_pin;

  /// No description provided for @incorrect_pin_try_again.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get incorrect_pin_try_again;

  /// No description provided for @exampleContent.
  ///
  /// In en, this message translates to:
  /// **'Example content'**
  String get exampleContent;
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
