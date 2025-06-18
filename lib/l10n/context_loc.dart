import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// Shortcut to access the localized strings through the [BuildContext].
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
