// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'contactSafe';

  @override
  String get contacts => 'Contacts';

  @override
  String get search => 'Search';

  @override
  String get events => 'Events';

  @override
  String get photos => 'Photos';

  @override
  String get settings => 'Settings';

  @override
  String get group => 'Group';

  @override
  String get noPhotos => 'No photos';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get language => 'Language';

  @override
  String get noResults => 'No results found';

  @override
  String get addEvent => 'Add Event';

  @override
  String get newEvent => 'New Event';

  @override
  String get selectDate => 'Select Date';

  @override
  String get participants => 'Participants';

  @override
  String get none => 'None';

  @override
  String get location => 'Location';

  @override
  String get description => 'Description';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get title => 'Title';

  @override
  String get selectParticipants => 'Select Participants';

  @override
  String get addParticipants => 'Add Participants';

  @override
  String get chooseLocationOnMap => 'Choose Location on Map';

  @override
  String get eventAdded => 'Event added successfully!';

  @override
  String get failedToAddEvent => 'Failed to add event';

  @override
  String get save => 'Save';

  @override
  String get createContact => 'Create contact';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get company => 'Company';

  @override
  String get mobile => 'Mobile';

  @override
  String get home => 'Home';

  @override
  String get work => 'Work';

  @override
  String get pager => 'Pager';

  @override
  String get other => 'Other';

  @override
  String get custom => 'Custom';

  @override
  String get phone => 'Phone';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get addPhone => 'Add phone';

  @override
  String get email => 'Email';

  @override
  String get addEmail => 'Add email';

  @override
  String get address => 'Address';

  @override
  String get addAddress => 'Add address';

  @override
  String get enterAddress => 'Enter address';

  @override
  String get exampleEmail => 'example@email.com';

  @override
  String get birthday => 'Birthday';

  @override
  String get addBirthday => 'Add birthday';

  @override
  String get changePicture => 'Change picture';

  @override
  String get addPicture => 'Add picture';

  @override
  String get contactSafe => 'contactSafe';

  @override
  String get contactSavedDevice => 'Contact saved to device!';

  @override
  String get contactPermissionDenied =>
      'Contact permission denied. Cannot save to device.';

  @override
  String get contactSavedCloud => 'Contact saved to Cloud Firestore!';

  @override
  String failedToSaveContact(Object error) {
    return 'Failed to save contact: $error';
  }

  @override
  String get photoPermissionDenied => 'Photo library permission denied.';

  @override
  String get photoPermissionPermanentlyDenied =>
      'Photo library permission permanently denied. Please enable in settings.';

  @override
  String get remove => 'Remove';

  @override
  String get family => 'Family';

  @override
  String get friends => 'Friends';

  @override
  String get emergency => 'Emergency';

  @override
  String get notAssigned => 'Not assigned';

  @override
  String assignToGroup(Object groupName) {
    return 'Assign to \"$groupName\"';
  }

  @override
  String get noContactsFound => 'No contacts found on your device.';

  @override
  String contactsAssignedToGroup(Object groupName) {
    return 'Contacts assigned to \"$groupName\"';
  }

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get call => 'Call';

  @override
  String get message => 'Message';

  @override
  String get files => 'Files';

  @override
  String get notes => 'Notes';

  @override
  String get exportVcf => 'Export VCF';

  @override
  String get noPhoneNumber => 'No phone number available';

  @override
  String get noEmailAddress => 'No email address available';

  @override
  String calling(Object name) {
    return 'Calling $name';
  }

  @override
  String messaging(Object name) {
    return 'Messaging $name';
  }

  @override
  String emailing(Object name) {
    return 'Emailing $name';
  }

  @override
  String favoriteStatusToggled(Object name) {
    return '$name favorite status toggled!';
  }

  @override
  String contactExported(Object filePath) {
    return 'Contact exported to: $filePath';
  }

  @override
  String get errorAccessingStorage => 'Error accessing storage.';

  @override
  String errorSavingVcf(Object error) {
    return 'Error saving VCF file: $error';
  }

  @override
  String get storagePermissionDenied =>
      'Storage permission denied. Please enable in settings.';

  @override
  String get couldNotLaunchPhone => 'Could not launch phone call';

  @override
  String get couldNotLaunchSms => 'Could not launch messaging app';

  @override
  String get couldNotLaunchEmail => 'Could not launch email app';

  @override
  String get noFilesAvailable => 'No files available';

  @override
  String get tapToAddFiles => 'Tap the + button to add files';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get sortFilesBy => 'Sort Files By';

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String get nameZA => 'Name (Z-A)';

  @override
  String get dateOldest => 'Date (Oldest first)';

  @override
  String get dateNewest => 'Date (Newest first)';

  @override
  String get sizeSmallest => 'Size (Smallest first)';

  @override
  String get sizeLargest => 'Size (Largest first)';

  @override
  String get renameFile => 'Rename File';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get share => 'Share';

  @override
  String get fileDeleted => 'File deleted';

  @override
  String fileDeleteFailed(Object error) {
    return 'Failed to delete file: $error';
  }

  @override
  String failedToLoadFiles(Object error) {
    return 'Failed to load files: $error';
  }

  @override
  String fileUploadSuccess(Object count) {
    return '$count file(s) uploaded successfully.';
  }

  @override
  String fileUploadFail(Object count) {
    return '$count file(s) failed to upload.';
  }

  @override
  String get fileUploadNone => 'No files selected or processed.';

  @override
  String get selectedFilesDeleted => 'Selected files deleted successfully!';

  @override
  String failedToDeleteSelected(Object error) {
    return 'Failed to delete selected files: $error';
  }

  @override
  String failedToRenameFile(Object error) {
    return 'Failed to rename file: $error';
  }

  @override
  String failedToShareFile(Object error) {
    return 'Failed to share file: $error';
  }

  @override
  String get unableToRetrieveFile => 'Unable to retrieve file data';

  @override
  String failedToOpenFile(Object error) {
    return 'Failed to open file: $error';
  }

  @override
  String get couldNotDownloadFile => 'Could not download file data';

  @override
  String get couldNotOpenFile => 'Could not open file';

  @override
  String get groups => 'Groups';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get selectAllGroups => 'Select all groups';

  @override
  String get newGroup => 'New Group';

  @override
  String get enterNewGroup => 'Enter the name for your new group:';

  @override
  String get groupName => 'Group name';

  @override
  String get ok => 'OK';

  @override
  String get okAddContacts => 'Ok & add contacts';

  @override
  String groupExists(Object groupName) {
    return 'Group \"$groupName\" already exists.';
  }

  @override
  String get appName => 'contactSafe';

  @override
  String notesScreenTitle(Object contactName) {
    return '$contactName - Notes';
  }

  @override
  String get noNotesTitle => 'No notes yet';

  @override
  String get noNotesSubtitle => 'Tap the + button to add your first note';

  @override
  String get addNewNote => 'Add New Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get writeNoteHint => 'Write your note here...';

  @override
  String get noteEdited => 'Edited';

  @override
  String failedToLoadNotes(Object error) {
    return 'Failed to load notes: $error';
  }

  @override
  String failedToAddNote(Object error) {
    return 'Failed to add note: $error';
  }

  @override
  String failedToUpdateNote(Object error) {
    return 'Failed to update note: $error';
  }

  @override
  String failedToDeleteNote(Object error) {
    return 'Failed to delete note: $error';
  }

  @override
  String get editContact => 'Edit contact';

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String get contactUpdated => 'Contact updated successfully!';

  @override
  String contactUpdateFailed(Object error) {
    return 'Failed to update contact: $error';
  }

  @override
  String get contactDeleted => 'Contact deleted successfully!';

  @override
  String contactDeleteFailed(Object error) {
    return 'Failed to delete contact: $error';
  }

  @override
  String get noteDetailTitle => 'Note';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get addContact => 'Add Contact';

  @override
  String get close => 'Close';

  @override
  String get emailAction => 'Email';

  @override
  String get favorite => 'Favorite';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get exportVCF => 'Export VCF';

  @override
  String get fileUploaded => 'File uploaded';

  @override
  String get fileRenamed => 'File renamed';

  @override
  String get noFiles => 'No files available';

  @override
  String get noNotes => 'No notes yet';

  @override
  String get tapToAddNote => 'Tap the + button to add your first note';

  @override
  String get note => 'Note';

  @override
  String get addNote => 'Add Note';

  @override
  String get enterGroupName => 'Enter the name for your new group';

  @override
  String get searchHint => 'Search';

  @override
  String get eventDetails => 'Event Details';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get eventDate => 'Date';

  @override
  String get eventLocation => 'Location';

  @override
  String get eventDescription => 'Description';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get noParticipants => 'No participants added.';

  @override
  String get mapUnavailable =>
      'Map location unavailable. Could not geocode address.';

  @override
  String get permissionDenied =>
      'Permission denied. Please enable in settings.';

  @override
  String get sortEventsBy => 'Sort Events By';

  @override
  String get titleAz => 'Title (A-Z)';

  @override
  String get titleZa => 'Title (Z-A)';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get date => 'Date';

  @override
  String get noContactsAvailable => 'No contacts available to add.';

  @override
  String get select => 'Select';

  @override
  String get locationPermissionRecommended =>
      'Location permission is recommended for map features.';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission permanently denied. Please enable it in app settings.';

  @override
  String get contactsPermissionRequired =>
      'Contacts permission is required to add participants.';

  @override
  String get errorFetchingContacts => 'Error fetching contacts';

  @override
  String get errorLoadingEvents => 'Error loading events';

  @override
  String get locationColon => 'Location:';

  @override
  String get dateColon => 'Date:';

  @override
  String get participantsColon => 'Participants:';

  @override
  String get descriptionColon => 'Description:';

  @override
  String get pleaseFillAllEventFields =>
      'Please enter a title, select a date, and select a location.';

  @override
  String get chooseEventLocation => 'Choose Event Location';

  @override
  String get locationPermissionNeeded =>
      'Location permission is needed to show your current location.';

  @override
  String get couldNotGetCurrentLocation => 'Could not get current location.';

  @override
  String get pickedLocation => 'Picked Location';

  @override
  String get tapToPickLocation => 'Tap on the map to pick a location';

  @override
  String get selectThisLocation => 'Select This Location';

  @override
  String get failedToLoadPhotos => 'Failed to load photos';

  @override
  String get from => 'From';

  @override
  String get user_pin => 'PIN code';

  @override
  String get usePassword => 'Use Password';

  @override
  String get useFaceId => 'Use FaceID';

  @override
  String get tabBarOrder => 'Tab Bar Order';

  @override
  String get sortByFirstName => 'Sort by First Name';

  @override
  String get lastNameFirst => 'Show Last Name First';

  @override
  String saved_useFaceId(Object value) {
    return 'Saved useFaceId: $value';
  }

  @override
  String get no_saved_tabBar_order =>
      'No saved TabBar order found, using default.';

  @override
  String error_decoding_tabBar_order(Object error) {
    return 'Error decoding saved TabBar order: $error';
  }

  @override
  String saved_tabBar_order(Object labels) {
    return 'Saved TabBar order: $labels';
  }

  @override
  String error_importing_contacts(Object error) {
    return 'Error importing contacts: $error';
  }

  @override
  String failed_import_contacts(Object error) {
    return 'Failed to import contacts: $error';
  }

  @override
  String error_creating_backup(Object error) {
    return 'Error creating backup: $error';
  }

  @override
  String failed_create_backup(Object error) {
    return 'Failed to create backup: $error';
  }

  @override
  String get failed_to_download_file => 'Failed to download file';

  @override
  String error_restoring_backup(Object error) {
    return 'Error restoring backup: $error';
  }

  @override
  String failed_restore_backup(Object error) {
    return 'Failed to restore backup: $error';
  }

  @override
  String get google_sign_in_failed => 'Google sign in failed';

  @override
  String get no_backup_file_found => 'No backup file found';

  @override
  String get invalid_file_id => 'Invalid file id';

  @override
  String error_importing_from_link(Object error) {
    return 'Error importing from link: $error';
  }

  @override
  String failed_import_backup_from_link(Object error) {
    return 'Failed to import backup from link: $error';
  }

  @override
  String error_deleting_all_data(Object error) {
    return 'Error deleting all data: $error';
  }

  @override
  String failed_delete_all_data(Object error) {
    return 'Failed to delete all data: $error';
  }

  @override
  String get please_authenticate_faceid =>
      'Please authenticate to enable FaceID/Fingerprint';

  @override
  String get pin_enter_title => 'Enter PIN';

  @override
  String get pin_set_title => 'Set PIN';

  @override
  String get pin_error => 'PIN code is incorrect';

  @override
  String get pin_empty_error => 'Please enter PIN code';

  @override
  String get pin_placeholder => '•';

  @override
  String get pin_button_cancel => 'Cancel';

  @override
  String get pin_dialog_title => 'Enter your PIN';

  @override
  String get pin_dialog_error => 'Incorrect PIN. Please try again.';

  @override
  String get select_tabbar_order_title => 'Select TabBar Order';

  @override
  String get privacy => 'Privacy';

  @override
  String get open_in_settings_app => 'Open in \"Settings\" app';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get imprint => 'Imprint';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get general => 'General';

  @override
  String get sort_by_first_name => 'Sort by first name';

  @override
  String get last_name_first => 'Last name first';

  @override
  String get data_management => 'Data Management';

  @override
  String get import_contacts => 'Import contacts';

  @override
  String get create_backup => 'Create backup';

  @override
  String get restore_from_backup => 'Restore from backup';

  @override
  String get backup_to_google_drive => 'Backup to Google Drive';

  @override
  String get restore_from_google_drive => 'Restore from Google Drive';

  @override
  String get import_backup_from_link => 'Import backup from link';

  @override
  String get app_customization_and_reset => 'App Customization & Reset';

  @override
  String get onboard_tour => 'Onboard Tour';

  @override
  String get select_tabbar_order => 'Select TabBar order';

  @override
  String get delete_all_app_data => 'Delete all app data';

  @override
  String get security => 'Security';

  @override
  String get use_pin => 'Use PIN';

  @override
  String get use_biometrics => 'Use Biometrics (Face ID/Fingerprint)';

  @override
  String get change_pin => 'Change PIN';

  @override
  String get powered_by_inappsettingkit => 'Powered by InAppSettingKit';

  @override
  String get delete_all_data => 'Delete All Data?';

  @override
  String get delete_all_data_confirm =>
      'Are you sure you want to delete ALL data from ContactSafe? This action cannot be undone.';

  @override
  String successfully_imported_contacts(Object count) {
    return 'Successfully imported $count contacts!';
  }

  @override
  String backup_created_successfully(Object fileName) {
    return 'Backup created successfully at $fileName';
  }

  @override
  String failed_to_create_backup(Object error) {
    return 'Failed to create backup: $error';
  }

  @override
  String restored_contacts_from_backup(Object count) {
    return 'Restored $count contacts from backup!';
  }

  @override
  String failed_to_restore_backup(Object error) {
    return 'Failed to restore backup: $error';
  }

  @override
  String get backup_uploaded_to_google_drive =>
      'Backup uploaded to Google Drive';

  @override
  String backup_failed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String restored_contacts_from_google_drive(Object count) {
    return 'Restored $count contacts from Google Drive';
  }

  @override
  String restore_failed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String imported_contacts_from_link(Object count) {
    return 'Imported $count contacts from link';
  }

  @override
  String import_failed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String could_not_open_url(Object url) {
    return 'Could not open $url';
  }

  @override
  String get tabbar_order_updated => 'TabBar order updated successfully!';

  @override
  String get all_app_data_deleted => 'All application data has been deleted.';

  @override
  String failed_to_delete_all_data(Object error) {
    return 'Failed to delete all data: $error';
  }

  @override
  String get pins_do_not_match => 'PINs do not match. Please try again.';

  @override
  String get pin_enabled => 'PIN enabled.';

  @override
  String get pin_setup_canceled_or_invalid => 'PIN setup canceled or invalid.';

  @override
  String get pin_disabled => 'PIN disabled.';

  @override
  String get pin_changed_successfully => 'PIN changed successfully';

  @override
  String get pin_change_canceled_or_invalid =>
      'PIN change canceled or invalid.';

  @override
  String get biometrics_enabled => 'Biometrics enabled.';

  @override
  String get authentication_failed_or_canceled =>
      'Authentication failed or canceled.';

  @override
  String get no_biometrics_available => 'No biometrics available.';

  @override
  String get biometrics_disabled => 'Biometrics disabled.';

  @override
  String get enter_backup_link => 'Enter backup link';

  @override
  String get import => 'Import';

  @override
  String get confirm => 'Confirm';

  @override
  String get create_a_4_digit_pin => 'Create a 4-digit PIN';

  @override
  String get confirm_your_pin => 'Confirm your PIN';

  @override
  String get enter_your_pin => 'Enter your PIN';

  @override
  String get incorrect_pin_try_again => 'Incorrect PIN. Please try again.';

  @override
  String get exampleContent => 'Example content';
}
