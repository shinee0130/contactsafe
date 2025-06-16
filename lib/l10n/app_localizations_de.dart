// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'contactSafe';

  @override
  String get contacts => 'Kontakte';

  @override
  String get search => 'Suchen';

  @override
  String get events => 'Termine';

  @override
  String get photos => 'Fotos';

  @override
  String get settings => 'Einstellungen';

  @override
  String get group => 'Gruppe';

  @override
  String get noPhotos => 'Keine Fotos';

  @override
  String get deleteAll => 'Alles löschen';

  @override
  String get language => 'Sprache';

  @override
  String get noResults => 'Keine Ergebnisse gefunden';

  @override
  String get addEvent => 'Termin hinzufügen';

  @override
  String get newEvent => 'Neuer Termin';

  @override
  String get selectDate => 'Datum wählen';

  @override
  String get participants => 'Teilnehmer';

  @override
  String get none => 'Keine';

  @override
  String get location => 'Standort';

  @override
  String get description => 'Beschreibung';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get title => 'Titel';

  @override
  String get selectParticipants => 'Teilnehmer auswählen';

  @override
  String get addParticipants => 'Teilnehmer hinzufügen';

  @override
  String get chooseLocationOnMap => 'Standort auf Karte wählen';

  @override
  String get eventAdded => 'Termin erfolgreich hinzugefügt!';

  @override
  String get failedToAddEvent => 'Termin konnte nicht hinzugefügt werden';

  @override
  String get save => 'Speichern';

  @override
  String get createContact => 'Kontakt erstellen';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get company => 'Firma';

  @override
  String get mobile => 'Mobil';

  @override
  String get home => 'Privat';

  @override
  String get work => 'Arbeit';

  @override
  String get pager => 'Pager';

  @override
  String get other => 'Sonstiges';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get phone => 'Telefon';

  @override
  String get enterPhoneNumber => 'Telefonnummer eingeben';

  @override
  String get addPhone => 'Telefon hinzufügen';

  @override
  String get email => 'E-Mail';

  @override
  String get addEmail => 'E-Mail hinzufügen';

  @override
  String get address => 'Adresse';

  @override
  String get addAddress => 'Adresse hinzufügen';

  @override
  String get enterAddress => 'Adresse eingeben';

  @override
  String get exampleEmail => 'beispiel@email.com';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get addBirthday => 'Geburtstag hinzufügen';

  @override
  String get changePicture => 'Bild ändern';

  @override
  String get addPicture => 'Bild hinzufügen';

  @override
  String get contactSafe => 'contactSafe';

  @override
  String get contactSavedDevice => 'Kontakt auf dem Gerät gespeichert!';

  @override
  String get contactPermissionDenied =>
      'Keine Berechtigung zum Speichern von Kontakten.';

  @override
  String get contactSavedCloud => 'Kontakt in der Cloud gespeichert!';

  @override
  String failedToSaveContact(Object error) {
    return 'Fehler beim Speichern des Kontakts: $error';
  }

  @override
  String get photoPermissionDenied => 'Keine Berechtigung für Fotos.';

  @override
  String get photoPermissionPermanentlyDenied =>
      'Foto-Zugriff dauerhaft verweigert. Bitte in den Einstellungen aktivieren.';

  @override
  String get remove => 'Entfernen';

  @override
  String get family => 'Familie';

  @override
  String get friends => 'Freunde';

  @override
  String get emergency => 'Notfall';

  @override
  String get notAssigned => 'Nicht zugeordnet';

  @override
  String assignToGroup(Object groupName) {
    return 'In Gruppe \"$groupName\" zuordnen';
  }

  @override
  String get noContactsFound => 'Keine Kontakte auf Ihrem Gerät gefunden.';

  @override
  String contactsAssignedToGroup(Object groupName) {
    return 'Kontakte der Gruppe \"$groupName\" zugeordnet.';
  }

  @override
  String get contactInformation => 'Kontaktinformation';

  @override
  String get call => 'Anrufen';

  @override
  String get message => 'Nachricht';

  @override
  String get files => 'Dateien';

  @override
  String get notes => 'Notizen';

  @override
  String get exportVcf => 'Als VCF exportieren';

  @override
  String get noPhoneNumber => 'Keine Telefonnummer verfügbar';

  @override
  String get noEmailAddress => 'Keine E-Mail-Adresse verfügbar';

  @override
  String calling(Object name) {
    return 'Rufe $name an';
  }

  @override
  String messaging(Object name) {
    return 'Sende Nachricht an $name';
  }

  @override
  String emailing(Object name) {
    return 'Sende E-Mail an $name';
  }

  @override
  String favoriteStatusToggled(Object name) {
    return 'Favoritenstatus für $name geändert!';
  }

  @override
  String contactExported(Object filePath) {
    return 'Kontakt exportiert nach: $filePath';
  }

  @override
  String get errorAccessingStorage => 'Fehler beim Zugriff auf Speicher.';

  @override
  String errorSavingVcf(Object error) {
    return 'Fehler beim Speichern der VCF-Datei: $error';
  }

  @override
  String get storagePermissionDenied =>
      'Kein Speicherzugriff. Bitte in den Einstellungen aktivieren.';

  @override
  String get couldNotLaunchPhone => 'Telefonanruf nicht möglich';

  @override
  String get couldNotLaunchSms => 'Nachricht kann nicht gesendet werden';

  @override
  String get couldNotLaunchEmail => 'E-Mail kann nicht gesendet werden';

  @override
  String get noFilesAvailable => 'Keine Dateien verfügbar';

  @override
  String get tapToAddFiles => 'Tippen Sie auf das +, um Dateien hinzuzufügen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get sortFilesBy => 'Dateien sortieren nach';

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String get nameZA => 'Name (Z-A)';

  @override
  String get dateOldest => 'Datum (älteste zuerst)';

  @override
  String get dateNewest => 'Datum (neueste zuerst)';

  @override
  String get sizeSmallest => 'Größe (kleinste zuerst)';

  @override
  String get sizeLargest => 'Größe (größte zuerst)';

  @override
  String get renameFile => 'Datei umbenennen';

  @override
  String get enterNewName => 'Neuen Namen eingeben';

  @override
  String get share => 'Teilen';

  @override
  String get fileDeleted => 'Datei gelöscht';

  @override
  String fileDeleteFailed(Object error) {
    return 'Datei konnte nicht gelöscht werden: $error';
  }

  @override
  String failedToLoadFiles(Object error) {
    return 'Dateien konnten nicht geladen werden: $error';
  }

  @override
  String fileUploadSuccess(Object count) {
    return '$count Datei(en) erfolgreich hochgeladen.';
  }

  @override
  String fileUploadFail(Object count) {
    return '$count Datei(en) konnten nicht hochgeladen werden.';
  }

  @override
  String get fileUploadNone => 'Keine Datei ausgewählt.';

  @override
  String get selectedFilesDeleted => 'Ausgewählte Dateien wurden gelöscht!';

  @override
  String failedToDeleteSelected(Object error) {
    return 'Ausgewählte Dateien konnten nicht gelöscht werden: $error';
  }

  @override
  String failedToRenameFile(Object error) {
    return 'Datei konnte nicht umbenannt werden: $error';
  }

  @override
  String failedToShareFile(Object error) {
    return 'Datei konnte nicht geteilt werden: $error';
  }

  @override
  String get unableToRetrieveFile => 'Datei kann nicht abgerufen werden';

  @override
  String failedToOpenFile(Object error) {
    return 'Datei konnte nicht geöffnet werden: $error';
  }

  @override
  String get couldNotDownloadFile =>
      'Datei konnte nicht heruntergeladen werden';

  @override
  String get couldNotOpenFile => 'Datei konnte nicht geöffnet werden';

  @override
  String get groups => 'Gruppen';

  @override
  String get done => 'Fertig';

  @override
  String get skip => 'Überspringen';

  @override
  String get selectAllGroups => 'Alle Gruppen auswählen';

  @override
  String get newGroup => 'Neue Gruppe';

  @override
  String get enterNewGroup => 'Geben Sie den Namen für die neue Gruppe ein:';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get ok => 'OK';

  @override
  String get okAddContacts => 'OK & Kontakte hinzufügen';

  @override
  String groupExists(Object groupName) {
    return 'Gruppe \"$groupName\" existiert bereits.';
  }

  @override
  String get appName => 'contactSafe';

  @override
  String notesScreenTitle(Object contactName) {
    return '$contactName - Notizen';
  }

  @override
  String get noNotesTitle => 'Noch keine Notizen';

  @override
  String get noNotesSubtitle => 'Tippen Sie auf +, um eine Notiz hinzuzufügen';

  @override
  String get addNewNote => 'Neue Notiz hinzufügen';

  @override
  String get editNote => 'Notiz bearbeiten';

  @override
  String get writeNoteHint => 'Schreiben Sie hier Ihre Notiz...';

  @override
  String get noteEdited => 'Bearbeitet';

  @override
  String failedToLoadNotes(Object error) {
    return 'Notizen konnten nicht geladen werden: $error';
  }

  @override
  String failedToAddNote(Object error) {
    return 'Notiz konnte nicht hinzugefügt werden: $error';
  }

  @override
  String failedToUpdateNote(Object error) {
    return 'Notiz konnte nicht aktualisiert werden: $error';
  }

  @override
  String failedToDeleteNote(Object error) {
    return 'Notiz konnte nicht gelöscht werden: $error';
  }

  @override
  String get editContact => 'Kontakt bearbeiten';

  @override
  String get deleteContact => 'Kontakt löschen';

  @override
  String get contactUpdated => 'Kontakt erfolgreich aktualisiert!';

  @override
  String contactUpdateFailed(Object error) {
    return 'Kontakt konnte nicht aktualisiert werden: $error';
  }

  @override
  String get contactDeleted => 'Kontakt gelöscht!';

  @override
  String contactDeleteFailed(Object error) {
    return 'Kontakt konnte nicht gelöscht werden: $error';
  }

  @override
  String get noteDetailTitle => 'Notiz';

  @override
  String get deleteNote => 'Notiz löschen';

  @override
  String get addContact => 'Kontakt hinzufügen';

  @override
  String get close => 'Schließen';

  @override
  String get emailAction => 'E-Mail';

  @override
  String get favorite => 'Favorit';

  @override
  String get unfavorite => 'Kein Favorit';

  @override
  String get exportVCF => 'Als VCF exportieren';

  @override
  String get fileUploaded => 'Datei hochgeladen';

  @override
  String get fileRenamed => 'Datei umbenannt';

  @override
  String get noFiles => 'Keine Dateien';

  @override
  String get noNotes => 'Keine Notizen';

  @override
  String get tapToAddNote => 'Tippen Sie auf +, um eine Notiz hinzuzufügen';

  @override
  String get note => 'Notiz';

  @override
  String get addNote => 'Notiz hinzufügen';

  @override
  String get enterGroupName => 'Namen der neuen Gruppe eingeben';

  @override
  String get searchHint => 'Suchen';

  @override
  String get eventDetails => 'Termindetails';

  @override
  String get eventTitle => 'Titel des Termins';

  @override
  String get eventDate => 'Datum';

  @override
  String get eventLocation => 'Standort';

  @override
  String get eventDescription => 'Beschreibung';

  @override
  String get editEvent => 'Termin bearbeiten';

  @override
  String get deleteEvent => 'Termin löschen';

  @override
  String get noParticipants => 'Keine Teilnehmer hinzugefügt.';

  @override
  String get mapUnavailable => 'Standort konnte nicht bestimmt werden.';

  @override
  String get permissionDenied =>
      'Berechtigung verweigert. Bitte in den Einstellungen aktivieren.';

  @override
  String get sortEventsBy => 'Termine sortieren nach';

  @override
  String get titleAz => 'Titel (A-Z)';

  @override
  String get titleZa => 'Titel (Z-A)';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get date => 'Datum';

  @override
  String get noContactsAvailable => 'Keine Kontakte zum Hinzufügen verfügbar.';

  @override
  String get select => 'Auswählen';

  @override
  String get locationPermissionRecommended =>
      'Standortberechtigung wird für Kartenfunktionen empfohlen.';

  @override
  String get locationPermissionDenied => 'Standortberechtigung verweigert.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Standortberechtigung dauerhaft verweigert. Bitte in den Einstellungen aktivieren.';

  @override
  String get contactsPermissionRequired =>
      'Kontakte-Berechtigung wird für Teilnehmer benötigt.';

  @override
  String get errorFetchingContacts => 'Fehler beim Laden der Kontakte';

  @override
  String get errorLoadingEvents => 'Fehler beim Laden der Termine';

  @override
  String get locationColon => 'Standort:';

  @override
  String get dateColon => 'Datum:';

  @override
  String get participantsColon => 'Teilnehmer:';

  @override
  String get descriptionColon => 'Beschreibung:';

  @override
  String get pleaseFillAllEventFields =>
      'Bitte geben Sie Titel, Datum und Standort an.';

  @override
  String get chooseEventLocation => 'Terminstandort wählen';

  @override
  String get locationPermissionNeeded =>
      'Standortberechtigung ist erforderlich, um Ihren aktuellen Standort anzuzeigen.';

  @override
  String get couldNotGetCurrentLocation =>
      'Aktueller Standort konnte nicht ermittelt werden.';

  @override
  String get pickedLocation => 'Gewählter Standort';

  @override
  String get tapToPickLocation =>
      'Tippen Sie auf die Karte, um einen Standort zu wählen';

  @override
  String get selectThisLocation => 'Diesen Standort auswählen';

  @override
  String get failedToLoadPhotos => 'Fotos konnten nicht geladen werden';

  @override
  String get from => 'Von';

  @override
  String get user_pin => 'PIN-Code';

  @override
  String get usePassword => 'Passwort verwenden';

  @override
  String get useFaceId => 'FaceID verwenden';

  @override
  String get tabBarOrder => 'Tab Bar Reihenfolge';

  @override
  String get sortByFirstName => 'Nach Vornamen sortieren';

  @override
  String get lastNameFirst => 'Nachname zuerst anzeigen';

  @override
  String saved_useFaceId(Object value) {
    return 'FaceID-Einstellung gespeichert: $value';
  }

  @override
  String get no_saved_tabBar_order =>
      'Keine gespeicherte TabBar-Reihenfolge gefunden, Standard verwendet.';

  @override
  String error_decoding_tabBar_order(Object error) {
    return 'Fehler beim Laden der TabBar-Reihenfolge: $error';
  }

  @override
  String saved_tabBar_order(Object labels) {
    return 'TabBar-Reihenfolge gespeichert: $labels';
  }

  @override
  String error_importing_contacts(Object error) {
    return 'Fehler beim Importieren der Kontakte: $error';
  }

  @override
  String failed_import_contacts(Object error) {
    return 'Fehler beim Importieren der Kontakte: $error';
  }

  @override
  String error_creating_backup(Object error) {
    return 'Fehler beim Erstellen des Backups: $error';
  }

  @override
  String failed_create_backup(Object error) {
    return 'Fehler beim Erstellen des Backups: $error';
  }

  @override
  String get failed_to_download_file => 'Fehler beim Herunterladen der Datei';

  @override
  String error_restoring_backup(Object error) {
    return 'Fehler beim Wiederherstellen des Backups: $error';
  }

  @override
  String failed_restore_backup(Object error) {
    return 'Fehler beim Wiederherstellen des Backups: $error';
  }

  @override
  String get google_sign_in_failed => 'Google-Anmeldung fehlgeschlagen';

  @override
  String get no_backup_file_found => 'Keine Backup-Datei gefunden';

  @override
  String get invalid_file_id => 'Ungültige Datei-ID';

  @override
  String error_importing_from_link(Object error) {
    return 'Fehler beim Importieren über Link: $error';
  }

  @override
  String failed_import_backup_from_link(Object error) {
    return 'Fehler beim Importieren des Backups über Link: $error';
  }

  @override
  String error_deleting_all_data(Object error) {
    return 'Fehler beim Löschen aller Daten: $error';
  }

  @override
  String failed_delete_all_data(Object error) {
    return 'Fehler beim Löschen aller Daten: $error';
  }

  @override
  String get please_authenticate_faceid =>
      'Bitte authentifizieren Sie sich für FaceID/Fingerabdruck';

  @override
  String get pin_enter_title => 'PIN eingeben';

  @override
  String get pin_set_title => 'PIN festlegen';

  @override
  String get pin_error => 'PIN ist falsch';

  @override
  String get pin_empty_error => 'Bitte PIN-Code eingeben';

  @override
  String get pin_placeholder => '•';

  @override
  String get pin_button_cancel => 'Abbrechen';

  @override
  String get pin_dialog_title => 'PIN eingeben';

  @override
  String get pin_dialog_error => 'PIN ist falsch. Bitte erneut versuchen.';

  @override
  String get select_tabbar_order_title => 'TabBar-Reihenfolge auswählen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get open_in_settings_app => 'In \"Einstellungen\" öffnen';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get imprint => 'Impressum';

  @override
  String get privacy_policy => 'Datenschutzerklärung';

  @override
  String get general => 'Allgemein';

  @override
  String get sort_by_first_name => 'Nach Vornamen sortieren';

  @override
  String get last_name_first => 'Nachname zuerst';

  @override
  String get data_management => 'Datenverwaltung';

  @override
  String get import_contacts => 'Kontakte importieren';

  @override
  String get create_backup => 'Backup erstellen';

  @override
  String get restore_from_backup => 'Aus Backup wiederherstellen';

  @override
  String get backup_to_google_drive => 'Backup auf Google Drive speichern';

  @override
  String get restore_from_google_drive => 'Aus Google Drive wiederherstellen';

  @override
  String get import_backup_from_link => 'Backup von Link importieren';

  @override
  String get app_customization_and_reset => 'App-Anpassung & Zurücksetzen';

  @override
  String get onboard_tour => 'Onboarding-Tour';

  @override
  String get select_tabbar_order => 'TabBar-Reihenfolge wählen';

  @override
  String get delete_all_app_data => 'Alle App-Daten löschen';

  @override
  String get security => 'Sicherheit';

  @override
  String get use_pin => 'PIN verwenden';

  @override
  String get use_biometrics => 'Biometrie (FaceID/Fingerabdruck)';

  @override
  String get change_pin => 'PIN ändern';

  @override
  String get powered_by_inappsettingkit => 'Powered by InAppSettingKit';

  @override
  String get delete_all_data => 'Alle Daten löschen?';

  @override
  String get delete_all_data_confirm =>
      'Möchten Sie wirklich ALLE Daten aus ContactSafe löschen? Dieser Vorgang kann nicht rückgängig gemacht werden.';

  @override
  String successfully_imported_contacts(Object count) {
    return '$count Kontakte erfolgreich importiert!';
  }

  @override
  String backup_created_successfully(Object fileName) {
    return 'Backup erfolgreich erstellt unter $fileName';
  }

  @override
  String failed_to_create_backup(Object error) {
    return 'Backup konnte nicht erstellt werden: $error';
  }

  @override
  String restored_contacts_from_backup(Object count) {
    return '$count Kontakte aus Backup wiederhergestellt!';
  }

  @override
  String failed_to_restore_backup(Object error) {
    return 'Backup konnte nicht wiederhergestellt werden: $error';
  }

  @override
  String get backup_uploaded_to_google_drive =>
      'Backup auf Google Drive hochgeladen';

  @override
  String backup_failed(Object error) {
    return 'Backup fehlgeschlagen: $error';
  }

  @override
  String restored_contacts_from_google_drive(Object count) {
    return '$count Kontakte aus Google Drive wiederhergestellt';
  }

  @override
  String restore_failed(Object error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String imported_contacts_from_link(Object count) {
    return '$count Kontakte per Link importiert';
  }

  @override
  String import_failed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String could_not_open_url(Object url) {
    return 'URL konnte nicht geöffnet werden: $url';
  }

  @override
  String get tabbar_order_updated =>
      'TabBar-Reihenfolge erfolgreich aktualisiert!';

  @override
  String get all_app_data_deleted => 'Alle Anwendungsdaten wurden gelöscht.';

  @override
  String failed_to_delete_all_data(Object error) {
    return 'Fehler beim Löschen aller Daten: $error';
  }

  @override
  String get pins_do_not_match =>
      'PINs stimmen nicht überein. Bitte erneut versuchen.';

  @override
  String get pin_enabled => 'PIN aktiviert.';

  @override
  String get pin_setup_canceled_or_invalid =>
      'PIN-Einrichtung abgebrochen oder ungültig.';

  @override
  String get pin_disabled => 'PIN deaktiviert.';

  @override
  String get pin_changed_successfully => 'PIN erfolgreich geändert';

  @override
  String get pin_change_canceled_or_invalid =>
      'PIN-Änderung abgebrochen oder ungültig.';

  @override
  String get biometrics_enabled => 'Biometrie aktiviert.';

  @override
  String get authentication_failed_or_canceled =>
      'Authentifizierung fehlgeschlagen oder abgebrochen.';

  @override
  String get no_biometrics_available => 'Keine Biometrie verfügbar.';

  @override
  String get biometrics_disabled => 'Biometrie deaktiviert.';

  @override
  String get enter_backup_link => 'Backup-Link eingeben';

  @override
  String get import => 'Importieren';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get create_a_4_digit_pin => 'Erstellen Sie eine 4-stellige PIN';

  @override
  String get confirm_your_pin => 'Bestätigen Sie Ihre PIN';

  @override
  String get enter_your_pin => 'PIN eingeben';

  @override
  String get incorrect_pin_try_again =>
      'PIN ist falsch. Bitte erneut versuchen.';

  @override
  String get exampleContent => 'Beispielinhalt';
}
