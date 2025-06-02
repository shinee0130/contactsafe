import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:contactsafe/features/settings/presentation/screens/pin_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:contactsafe/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController();
  final pinEnabled = await settingsController.hasPinEnabled();

  runApp(
    MaterialApp(
      home:
          pinEnabled
              ? PinVerificationGate(
                controller: settingsController,
                child: const ContactSafeApp(),
              )
              : const ContactSafeApp(),
    ),
  );
}
