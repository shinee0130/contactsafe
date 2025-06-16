// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([String locale = 'mn']) : super(locale);

  @override
  String get appTitle => 'contactSafe';

  @override
  String get contacts => 'Харилцагчид';

  @override
  String get search => 'Хайх';

  @override
  String get events => 'Үйл явдал';

  @override
  String get photos => 'Зураг';

  @override
  String get settings => 'Тохиргоо';

  @override
  String get group => 'Бүлэг';

  @override
  String get noPhotos => 'Зураг алга';

  @override
  String get deleteAll => 'Бүгдийг устгах';

  @override
  String get language => 'Хэл';

  @override
  String get noResults => 'Үр дүн олдсонгүй';

  @override
  String get addEvent => 'Үйл явдал нэмэх';

  @override
  String get newEvent => 'Шинэ үйл явдал';

  @override
  String get selectDate => 'Огноо сонгох';

  @override
  String get participants => 'Оролцогчид';

  @override
  String get none => 'Байхгүй';

  @override
  String get location => 'Байршил';

  @override
  String get description => 'Тайлбар';

  @override
  String get cancel => 'Цуцлах';

  @override
  String get create => 'Үүсгэх';

  @override
  String get title => 'Гарчиг';

  @override
  String get selectParticipants => 'Оролцогч сонгох';

  @override
  String get addParticipants => 'Оролцогч нэмэх';

  @override
  String get chooseLocationOnMap => 'Газрын зураг дээр сонгох';

  @override
  String get eventAdded => 'Үйл явдал амжилттай нэмэгдлээ!';

  @override
  String get failedToAddEvent => 'Үйл явдал нэмэхэд алдаа гарлаа';

  @override
  String get save => 'Хадгалах';

  @override
  String get createContact => 'Харилцагч үүсгэх';

  @override
  String get firstName => 'Нэр';

  @override
  String get lastName => 'Овог';

  @override
  String get company => 'Байгууллага';

  @override
  String get mobile => 'Гар утас';

  @override
  String get home => 'Гэр';

  @override
  String get work => 'Ажил';

  @override
  String get pager => 'Пэйжер';

  @override
  String get other => 'Бусад';

  @override
  String get custom => 'Өөрөө';

  @override
  String get phone => 'Утас';

  @override
  String get enterPhoneNumber => 'Утасны дугаар оруулна уу';

  @override
  String get addPhone => 'Утас нэмэх';

  @override
  String get email => 'Имэйл';

  @override
  String get addEmail => 'Имэйл нэмэх';

  @override
  String get address => 'Хаяг';

  @override
  String get addAddress => 'Хаяг нэмэх';

  @override
  String get enterAddress => 'Хаягаа оруулна уу';

  @override
  String get exampleEmail => 'jishoo@email.com';

  @override
  String get birthday => 'Төрсөн өдөр';

  @override
  String get addBirthday => 'Төрсөн өдөр нэмэх';

  @override
  String get changePicture => 'Зураг солих';

  @override
  String get addPicture => 'Зураг нэмэх';

  @override
  String get contactSafe => 'contactSafe';

  @override
  String get contactSavedDevice => 'Харилцагч төхөөрөмжид хадгалагдлаа!';

  @override
  String get contactPermissionDenied => 'Харилцагч хадгалах зөвшөөрөл байхгүй.';

  @override
  String get contactSavedCloud => 'Харилцагч үүлэнд хадгалагдлаа!';

  @override
  String failedToSaveContact(Object error) {
    return 'Харилцагч хадгалах үед алдаа гарлаа: $error';
  }

  @override
  String get photoPermissionDenied => 'Зураг авах зөвшөөрөл байхгүй.';

  @override
  String get photoPermissionPermanentlyDenied =>
      'Зургийн зөвшөөрөл бүрэн хаагдсан. Тохиргооноос идэвхжүүлнэ үү.';

  @override
  String get remove => 'Устгах';

  @override
  String get family => 'Гэр бүл';

  @override
  String get friends => 'Найзууд';

  @override
  String get emergency => 'Онцгой';

  @override
  String get notAssigned => 'Хуваарилаагүй';

  @override
  String assignToGroup(Object groupName) {
    return '\"$groupName\" бүлэгт хуваарилах';
  }

  @override
  String get noContactsFound => 'Таны төхөөрөмжид харилцагч олдсонгүй.';

  @override
  String contactsAssignedToGroup(Object groupName) {
    return '\"$groupName\" бүлэгт харилцагчид нэмэгдлээ.';
  }

  @override
  String get contactInformation => 'Харилцагчийн мэдээлэл';

  @override
  String get call => 'Залгах';

  @override
  String get message => 'Зурвас';

  @override
  String get files => 'Файл';

  @override
  String get notes => 'Тэмдэглэл';

  @override
  String get exportVcf => 'VCF рүү экспортлох';

  @override
  String get noPhoneNumber => 'Утасны дугаар байхгүй';

  @override
  String get noEmailAddress => 'Имэйл хаяг байхгүй';

  @override
  String calling(Object name) {
    return '$name-руу залгаж байна';
  }

  @override
  String messaging(Object name) {
    return '$name-д зурвас илгээж байна';
  }

  @override
  String emailing(Object name) {
    return '$name-д имэйл илгээж байна';
  }

  @override
  String favoriteStatusToggled(Object name) {
    return '$name дуртайд нэмэгдлээ!';
  }

  @override
  String contactExported(Object filePath) {
    return 'Харилцагч экспортлогдсон: $filePath';
  }

  @override
  String get errorAccessingStorage => 'Санах ойд хандахад алдаа гарлаа.';

  @override
  String errorSavingVcf(Object error) {
    return 'VCF хадгалах үед алдаа гарлаа: $error';
  }

  @override
  String get storagePermissionDenied =>
      'Санах ойн зөвшөөрөл байхгүй. Тохиргоогоор идэвхжүүлнэ үү.';

  @override
  String get couldNotLaunchPhone => 'Утасны дуудлага хийх боломжгүй';

  @override
  String get couldNotLaunchSms => 'Зурвас илгээх боломжгүй';

  @override
  String get couldNotLaunchEmail => 'Имэйл илгээх боломжгүй';

  @override
  String get noFilesAvailable => 'Файл байхгүй';

  @override
  String get tapToAddFiles => 'Файл нэмэхийн тулд + товч дарна уу';

  @override
  String get delete => 'Устгах';

  @override
  String get edit => 'Засах';

  @override
  String get add => 'Нэмэх';

  @override
  String get sortFilesBy => 'Файлыг эрэмбэлэх';

  @override
  String get nameAZ => 'Нэр (А-Я)';

  @override
  String get nameZA => 'Нэр (Я-А)';

  @override
  String get dateOldest => 'Огноо (Хуучнаас шинэ рүү)';

  @override
  String get dateNewest => 'Огноо (Шинэээс хуучин руу)';

  @override
  String get sizeSmallest => 'Хэмжээ (Багаас их рүү)';

  @override
  String get sizeLargest => 'Хэмжээ (Ихээс бага руу)';

  @override
  String get renameFile => 'Файлын нэр солих';

  @override
  String get enterNewName => 'Шинэ нэр оруулна уу';

  @override
  String get share => 'Хуваалцах';

  @override
  String get fileDeleted => 'Файл устгагдлаа';

  @override
  String fileDeleteFailed(Object error) {
    return 'Файл устгахад алдаа гарлаа: $error';
  }

  @override
  String failedToLoadFiles(Object error) {
    return 'Файл ачаалахад алдаа гарлаа: $error';
  }

  @override
  String fileUploadSuccess(Object count) {
    return '$count файл амжилттай нэмэгдлээ.';
  }

  @override
  String fileUploadFail(Object count) {
    return '$count файл нэмэхэд алдаа гарлаа.';
  }

  @override
  String get fileUploadNone => 'Файл сонгогдоогүй байна.';

  @override
  String get selectedFilesDeleted => 'Сонгосон файл устгагдлаа!';

  @override
  String failedToDeleteSelected(Object error) {
    return 'Файл устгахад алдаа гарлаа: $error';
  }

  @override
  String failedToRenameFile(Object error) {
    return 'Файлын нэр өөрчлөхөд алдаа гарлаа: $error';
  }

  @override
  String failedToShareFile(Object error) {
    return 'Файл хуваалцахад алдаа гарлаа: $error';
  }

  @override
  String get unableToRetrieveFile => 'Файл авах боломжгүй';

  @override
  String failedToOpenFile(Object error) {
    return 'Файл нээхэд алдаа гарлаа: $error';
  }

  @override
  String get couldNotDownloadFile => 'Файл татаж авч чадсангүй';

  @override
  String get couldNotOpenFile => 'Файл нээж чадсангүй';

  @override
  String get groups => 'Бүлгүүд';

  @override
  String get done => 'Дууссан';

  @override
  String get skip => 'Алгасах';

  @override
  String get selectAllGroups => 'Бүх бүлгийг сонгох';

  @override
  String get newGroup => 'Шинэ бүлэг';

  @override
  String get enterNewGroup => 'Шинэ бүлгийн нэрээ оруулна уу:';

  @override
  String get groupName => 'Бүлгийн нэр';

  @override
  String get ok => 'OK';

  @override
  String get okAddContacts => 'OK & харилцагч нэмэх';

  @override
  String groupExists(Object groupName) {
    return '\"$groupName\" бүлэг аль хэдийнээ бий.';
  }

  @override
  String get appName => 'contactSafe';

  @override
  String notesScreenTitle(Object contactName) {
    return '$contactName - Тэмдэглэл';
  }

  @override
  String get noNotesTitle => 'Тэмдэглэл алга';

  @override
  String get noNotesSubtitle => '+ товч дарж тэмдэглэл нэмнэ үү';

  @override
  String get addNewNote => 'Шинэ тэмдэглэл нэмэх';

  @override
  String get editNote => 'Тэмдэглэл засах';

  @override
  String get writeNoteHint => 'Тэмдэглэлээ энд бичнэ үү...';

  @override
  String get noteEdited => 'Зассан';

  @override
  String failedToLoadNotes(Object error) {
    return 'Тэмдэглэл ачаалахад алдаа: $error';
  }

  @override
  String failedToAddNote(Object error) {
    return 'Тэмдэглэл нэмэхэд алдаа: $error';
  }

  @override
  String failedToUpdateNote(Object error) {
    return 'Тэмдэглэл засахад алдаа: $error';
  }

  @override
  String failedToDeleteNote(Object error) {
    return 'Тэмдэглэл устгахад алдаа: $error';
  }

  @override
  String get editContact => 'Харилцагч засах';

  @override
  String get deleteContact => 'Харилцагч устгах';

  @override
  String get contactUpdated => 'Харилцагч амжилттай шинэчлэгдлээ!';

  @override
  String contactUpdateFailed(Object error) {
    return 'Харилцагч шинэчлэхэд алдаа: $error';
  }

  @override
  String get contactDeleted => 'Харилцагч устгагдлаа!';

  @override
  String contactDeleteFailed(Object error) {
    return 'Харилцагч устгахад алдаа: $error';
  }

  @override
  String get noteDetailTitle => 'Тэмдэглэл';

  @override
  String get deleteNote => 'Тэмдэглэл устгах';

  @override
  String get addContact => 'Харилцагч нэмэх';

  @override
  String get close => 'Хаах';

  @override
  String get emailAction => 'Имэйл';

  @override
  String get favorite => 'Дуртай';

  @override
  String get unfavorite => 'Дуртайгаас хасах';

  @override
  String get exportVCF => 'VCF рүү экспортлох';

  @override
  String get fileUploaded => 'Файл нэмэгдсэн';

  @override
  String get fileRenamed => 'Файлын нэр өөрчлөгдсөн';

  @override
  String get noFiles => 'Файл алга';

  @override
  String get noNotes => 'Тэмдэглэл алга';

  @override
  String get tapToAddNote => '+ товч дарж шинэ тэмдэглэл нэмнэ үү';

  @override
  String get note => 'Тэмдэглэл';

  @override
  String get addNote => 'Тэмдэглэл нэмэх';

  @override
  String get enterGroupName => 'Шинэ бүлгийн нэрээ оруулна уу';

  @override
  String get searchHint => 'Хайх';

  @override
  String get eventDetails => 'Үйл явдлын дэлгэрэнгүй';

  @override
  String get eventTitle => 'Үйл явдлын гарчиг';

  @override
  String get eventDate => 'Огноо';

  @override
  String get eventLocation => 'Байршил';

  @override
  String get eventDescription => 'Тайлбар';

  @override
  String get editEvent => 'Үйл явдал засах';

  @override
  String get deleteEvent => 'Үйл явдал устгах';

  @override
  String get noParticipants => 'Оролцогч нэмэгдээгүй.';

  @override
  String get mapUnavailable => 'Газрын байршил олдсонгүй.';

  @override
  String get permissionDenied =>
      'Зөвшөөрөл олгогдоогүй байна. Тохиргооноос идэвхжүүлнэ үү.';

  @override
  String get sortEventsBy => 'Үйл явдлыг эрэмбэлэх';

  @override
  String get titleAz => 'Гарчиг (А-Я)';

  @override
  String get titleZa => 'Гарчиг (Я-А)';

  @override
  String get descriptionOptional => 'Тайлбар (заавал биш)';

  @override
  String get date => 'Огноо';

  @override
  String get noContactsAvailable => 'Харилцагч нэмэх боломжгүй байна.';

  @override
  String get select => 'Сонгох';

  @override
  String get locationPermissionRecommended =>
      'Газрын зүйн зөвшөөрөл шаардагдана.';

  @override
  String get locationPermissionDenied => 'Байршлын зөвшөөрөл олгогдоогүй.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Байршлын зөвшөөрөл бүрэн хаагдсан. Тохиргооноос идэвхжүүлнэ үү.';

  @override
  String get contactsPermissionRequired =>
      'Оролцогч нэмэхийн тулд харилцагчийн зөвшөөрөл хэрэгтэй.';

  @override
  String get errorFetchingContacts => 'Харилцагч ачаалах үед алдаа гарлаа';

  @override
  String get errorLoadingEvents => 'Үйл явдал ачаалахад алдаа гарлаа';

  @override
  String get locationColon => 'Байршил:';

  @override
  String get dateColon => 'Огноо:';

  @override
  String get participantsColon => 'Оролцогчид:';

  @override
  String get descriptionColon => 'Тайлбар:';

  @override
  String get pleaseFillAllEventFields => 'Гарчиг, огноо, байршил сонгоно уу.';

  @override
  String get chooseEventLocation => 'Үйл явдлын байршил сонгох';

  @override
  String get locationPermissionNeeded =>
      'Байршлыг үзүүлэхэд зөвшөөрөл хэрэгтэй.';

  @override
  String get couldNotGetCurrentLocation => 'Одоогийн байршлыг тогтооход алдаа.';

  @override
  String get pickedLocation => 'Сонгосон байршил';

  @override
  String get tapToPickLocation => 'Газрын зураг дээр дарж байршил сонгоно уу';

  @override
  String get selectThisLocation => 'Энэ байршлыг сонгох';

  @override
  String get failedToLoadPhotos => 'Зураг ачаалахад алдаа гарлаа';

  @override
  String get from => 'Хэнээс';

  @override
  String get user_pin => 'PIN код';

  @override
  String get usePassword => 'Нууц үг ашиглах';

  @override
  String get useFaceId => 'FaceID ашиглах';

  @override
  String get tabBarOrder => 'Tab Bar дараалал';

  @override
  String get sortByFirstName => 'Нэрээр эрэмбэлэх';

  @override
  String get lastNameFirst => 'Овгоор эхлэх';

  @override
  String saved_useFaceId(Object value) {
    return 'FaceID ашиглах тохиргоо хадгалагдлаа: $value';
  }

  @override
  String get no_saved_tabBar_order =>
      'TabBar-ийн дараалал олдсонгүй, анхны тохиргоо байна.';

  @override
  String error_decoding_tabBar_order(Object error) {
    return 'TabBar дараалал уншихад алдаа: $error';
  }

  @override
  String saved_tabBar_order(Object labels) {
    return 'TabBar-ийн дараалал хадгалагдлаа: $labels';
  }

  @override
  String error_importing_contacts(Object error) {
    return 'Харилцагч импортлоход алдаа: $error';
  }

  @override
  String failed_import_contacts(Object error) {
    return 'Харилцагч импортлоход алдаа: $error';
  }

  @override
  String error_creating_backup(Object error) {
    return 'Нөөцлөлт үүсгэхэд алдаа: $error';
  }

  @override
  String failed_create_backup(Object error) {
    return 'Нөөц үүсгэхэд алдаа: $error';
  }

  @override
  String get failed_to_download_file => 'Файл татаж авахад алдаа гарлаа';

  @override
  String error_restoring_backup(Object error) {
    return 'Нөөц сэргээхэд алдаа: $error';
  }

  @override
  String failed_restore_backup(Object error) {
    return 'Нөөц сэргээхэд алдаа: $error';
  }

  @override
  String get google_sign_in_failed => 'Google нэвтрэлт амжилтгүй';

  @override
  String get no_backup_file_found => 'Нөөц файл олдсонгүй';

  @override
  String get invalid_file_id => 'Файлын ID буруу байна';

  @override
  String error_importing_from_link(Object error) {
    return 'Линкээр импортлох үед алдаа: $error';
  }

  @override
  String failed_import_backup_from_link(Object error) {
    return 'Линкээр нөөц импортлоход алдаа: $error';
  }

  @override
  String error_deleting_all_data(Object error) {
    return 'Бүх өгөгдөл устгахад алдаа: $error';
  }

  @override
  String failed_delete_all_data(Object error) {
    return 'Бүх өгөгдөл устгахад алдаа: $error';
  }

  @override
  String get please_authenticate_faceid =>
      'FaceID/Хурууны хээг идэвхжүүлэхийн тулд нэвтэрнэ үү';

  @override
  String get pin_enter_title => 'PIN оруулах';

  @override
  String get pin_set_title => 'PIN үүсгэх';

  @override
  String get pin_error => 'PIN буруу байна';

  @override
  String get pin_empty_error => 'PIN код оруулна уу';

  @override
  String get pin_placeholder => '•';

  @override
  String get pin_button_cancel => 'Цуцлах';

  @override
  String get pin_dialog_title => 'PIN кодоо оруулна уу';

  @override
  String get pin_dialog_error => 'PIN буруу байна. Дахин оролдоно уу.';

  @override
  String get select_tabbar_order_title => 'TabBar дараалал сонгох';

  @override
  String get privacy => 'Хувийн нууцлал';

  @override
  String get open_in_settings_app => '\"Тохиргоо\" апп руу нээх';

  @override
  String get about => 'Апп-ын тухай';

  @override
  String get version => 'Хувилбар';

  @override
  String get imprint => 'Импрессум';

  @override
  String get privacy_policy => 'Нууцлалын бодлого';

  @override
  String get general => 'Ерөнхий';

  @override
  String get sort_by_first_name => 'Нэрээр эрэмбэлэх';

  @override
  String get last_name_first => 'Овгоор эхлэх';

  @override
  String get data_management => 'Өгөгдлийн менежмент';

  @override
  String get import_contacts => 'Харилцагч импортлох';

  @override
  String get create_backup => 'Нөөц үүсгэх';

  @override
  String get restore_from_backup => 'Нөөцөөс сэргээх';

  @override
  String get backup_to_google_drive => 'Google Drive руу нөөцлөх';

  @override
  String get restore_from_google_drive => 'Google Drive-с сэргээх';

  @override
  String get import_backup_from_link => 'Линкээр нөөц импортлох';

  @override
  String get app_customization_and_reset =>
      'Апп тохиргоо болон дахин тохируулах';

  @override
  String get onboard_tour => 'Танилцуулга';

  @override
  String get select_tabbar_order => 'TabBar дараалал сонгох';

  @override
  String get delete_all_app_data => 'Бүх өгөгдлийг устгах';

  @override
  String get security => 'Аюулгүй байдал';

  @override
  String get use_pin => 'PIN ашиглах';

  @override
  String get use_biometrics => 'Биометрик (FaceID/Хурууны хээ)';

  @override
  String get change_pin => 'PIN өөрчлөх';

  @override
  String get powered_by_inappsettingkit => 'InAppSettingKit ашигласан';

  @override
  String get delete_all_data => 'Бүх өгөгдлийг устгах уу?';

  @override
  String get delete_all_data_confirm =>
      'ContactSafe-ийн бүх өгөгдлийг устгахдаа итгэлтэй байна уу? Энэ үйлдлийг буцаах боломжгүй.';

  @override
  String successfully_imported_contacts(Object count) {
    return '$count харилцагч амжилттай импортлогдлоо!';
  }

  @override
  String backup_created_successfully(Object fileName) {
    return 'Нөөц амжилттай үүслээ: $fileName';
  }

  @override
  String failed_to_create_backup(Object error) {
    return 'Нөөц үүсгэхэд алдаа: $error';
  }

  @override
  String restored_contacts_from_backup(Object count) {
    return '$count харилцагч нөөцөөс сэргээгдлээ!';
  }

  @override
  String failed_to_restore_backup(Object error) {
    return 'Нөөцөөс сэргээхэд алдаа: $error';
  }

  @override
  String get backup_uploaded_to_google_drive =>
      'Google Drive руу амжилттай нөөцлөв';

  @override
  String backup_failed(Object error) {
    return 'Нөөцлөхөд алдаа гарлаа: $error';
  }

  @override
  String restored_contacts_from_google_drive(Object count) {
    return '$count харилцагч Google Drive-с сэргээгдлээ';
  }

  @override
  String restore_failed(Object error) {
    return 'Сэргээхэд алдаа: $error';
  }

  @override
  String imported_contacts_from_link(Object count) {
    return '$count харилцагч линкээр импортлогдлоо';
  }

  @override
  String import_failed(Object error) {
    return 'Импортлоход алдаа: $error';
  }

  @override
  String could_not_open_url(Object url) {
    return '$url нээж чадсангүй';
  }

  @override
  String get tabbar_order_updated => 'TabBar дараалал амжилттай шинэчлэгдлээ!';

  @override
  String get all_app_data_deleted => 'Бүх өгөгдөл устгагдлаа.';

  @override
  String failed_to_delete_all_data(Object error) {
    return 'Бүх өгөгдөл устгахад алдаа: $error';
  }

  @override
  String get pins_do_not_match => 'PIN таарахгүй байна. Дахин оролдоно уу.';

  @override
  String get pin_enabled => 'PIN идэвхжлээ.';

  @override
  String get pin_setup_canceled_or_invalid =>
      'PIN тохиргоо цуцлагдсан эсвэл буруу байна.';

  @override
  String get pin_disabled => 'PIN идэвхгүй боллоо.';

  @override
  String get pin_changed_successfully => 'PIN амжилттай солигдлоо';

  @override
  String get pin_change_canceled_or_invalid =>
      'PIN солих цуцлагдсан эсвэл буруу байна.';

  @override
  String get biometrics_enabled => 'Биометрик идэвхжлээ.';

  @override
  String get authentication_failed_or_canceled =>
      'Баталгаажуулалт амжилтгүй эсвэл цуцлагдсан.';

  @override
  String get no_biometrics_available => 'Биометрик боломжгүй.';

  @override
  String get biometrics_disabled => 'Биометрик идэвхгүй.';

  @override
  String get enter_backup_link => 'Нөөц линк оруулах';

  @override
  String get import => 'Импортлох';

  @override
  String get confirm => 'Батлах';

  @override
  String get create_a_4_digit_pin => '4 оронтой PIN үүсгэнэ үү';

  @override
  String get confirm_your_pin => 'PIN-ээ баталгаажуулна уу';

  @override
  String get enter_your_pin => 'PIN оруулна уу';

  @override
  String get incorrect_pin_try_again => 'PIN буруу байна. Дахин оролдоно уу.';

  @override
  String get exampleContent => 'Жишээ агуулга';
}
