import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const HeaderBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: actions ?? []);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
