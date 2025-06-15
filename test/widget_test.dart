// Basic widget test for ContactSafeApp.
// Pumps the app and verifies the Contacts screen loads.

import 'package:contactsafe/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:contactsafe/l10n/app_localizations.dart';

void main() {
  testWidgets('Contacts screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('de'), Locale('mn')],
        home: const ContactSafeApp(),
      ),
    );

    expect(find.text('Contacts'), findsOneWidget);
  });
}
