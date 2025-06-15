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
        Future.delayed(const Duration(milliseconds: 120), () {
          Navigator.of(context).pop(_enteredPin); // Return the PIN
        });
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
    final isActive = _enteredPin.length == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.ease,
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(15),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [],
        border: Border.all(
          color:
              isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
          width: isActive ? 2 : 1.1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          maxLength: 1,
          obscureText: false,
          keyboardType: TextInputType.none,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          enableInteractiveSelection: false,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _onDigitEntered(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: SizedBox(
        width: 62,
        height: 62,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0.5,
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
            shadowColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.08),
          ),
          onPressed: () => _onDigitEntered(number),
          child: Text(number),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            if (widget.error != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  vertical: 7,
                  horizontal: 12,
                ),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 22,
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        widget.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => _buildPinInputField(index, context),
              ),
            ),
            const SizedBox(height: 26),
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
                    const SizedBox(width: 80, height: 80), // Empty space
                    _buildNumberButton('0'),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: SizedBox(
                        width: 62,
                        height: 62,
                        child: Material(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _onBackspace,
                            child: const Center(
                              child: Icon(Icons.backspace_outlined, size: 26),
                            ),
                          ),
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
