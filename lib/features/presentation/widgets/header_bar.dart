import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('ContactSafe'),
      actions: [IconButton(icon: Icon(Icons.add), onPressed: () {})],
    );
  }
}
