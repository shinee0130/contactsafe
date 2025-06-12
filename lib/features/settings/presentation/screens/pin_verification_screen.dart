// pin_verification_screen.dart
import 'package:contactsafe/features/settings/controller/settings_controller.dart';
import 'package:contactsafe/features/settings/presentation/screens/pin_dialog.dart';
import 'package:flutter/material.dart';

class PinVerificationGate extends StatefulWidget {
  final Widget child;
  final SettingsController controller;

  const PinVerificationGate({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<PinVerificationGate> createState() => _PinVerificationGateState();
}

class _PinVerificationGateState extends State<PinVerificationGate> {
  bool _isVerified = false;
  String? _error;

  Future<void> _verifyPin() async {
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => PinDialog(title: 'Enter your PIN', error: _error),
    );

    if (pin != null) {
      final verified = await widget.controller.verifyPin(pin);
      if (verified) {
        setState(() => _isVerified = true);
      } else {
        setState(() => _error = 'Incorrect PIN. Please try again.');
        await _verifyPin(); // Retry
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyPin());
  }

  @override
  Widget build(BuildContext context) {
    return _isVerified
        ? widget.child
        : Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        );
  }
}
