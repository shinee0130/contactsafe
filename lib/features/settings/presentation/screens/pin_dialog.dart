import 'package:flutter/material.dart';

class PinDialog extends StatefulWidget {
  final String title;
  final String? error;
  final Function(String)? onCompleted;

  const PinDialog({
    super.key,
    required this.title,
    this.error,
    this.onCompleted,
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  String _enteredPin = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    });
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _controllers[_enteredPin.length - 1].text = '•';
        if (_enteredPin.length < 4) {
          FocusScope.of(context).requestFocus(_focusNodes[_enteredPin.length]);
        }
      });

      if (_enteredPin.length == 4) {
        Navigator.of(context).pop(_enteredPin); // Return the PIN
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _controllers[_enteredPin.length - 1].text = '';
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        FocusScope.of(context).requestFocus(_focusNodes[_enteredPin.length]);
      });
    }
  }

  Widget _buildPinInputField(int index, BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: false,
        keyboardType: TextInputType.none,
        decoration: InputDecoration(
          counterText: '',
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 20),
        onChanged: (value) {
          if (value.isNotEmpty) {
            _onDigitEntered(value);
          }
        },
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 64,
        height: 64,
        child: ElevatedButton(
          onPressed: () => _onDigitEntered(number),
          child: Text(number, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            if (widget.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => _buildPinInputField(index, context),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton('1'),
                    _buildNumberButton('2'),
                    _buildNumberButton('3'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton('4'),
                    _buildNumberButton('5'),
                    _buildNumberButton('6'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton('7'),
                    _buildNumberButton('8'),
                    _buildNumberButton('9'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 64, height: 64), // Empty space
                    _buildNumberButton('0'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: IconButton(
                          icon: const Icon(Icons.backspace, size: 28),
                          onPressed: _onBackspace,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
