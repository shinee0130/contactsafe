import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:contactsafe/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Settings screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    expect(find.text('Settings'), findsOneWidget);
  });

  test('SettingsController pin operations', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = SettingsController();

    await controller.savePin('1234');
    expect(await controller.verifyPin('1234'), isTrue);
    expect(await controller.hasPinEnabled(), isTrue);
    await controller.deletePin();
    expect(await controller.hasPin(), isFalse);
  });
}
