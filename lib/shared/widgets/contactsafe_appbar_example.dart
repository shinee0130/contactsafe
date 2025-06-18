import 'package:flutter/material.dart';
import 'contactsafe_appbar.dart';

/// Example screen demonstrating the [ContactSafeAppBar].
class ContactSafeAppBarExample extends StatelessWidget {
  const ContactSafeAppBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ContactSafeAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {},
        ),
        actions: [
          IconButton(icon: const Icon(Icons.sort), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Center(child: Text(context.loc.exampleContent)),
    );
  }
}
