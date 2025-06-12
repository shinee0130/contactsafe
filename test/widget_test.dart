// Basic widget test for ContactSafeApp.
// Pumps the app and verifies the Contacts screen loads.

import 'package:contactsafe/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Contacts screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ContactSafeApp());

    expect(find.text('Contacts'), findsOneWidget);
  });
}
