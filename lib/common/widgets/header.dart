import 'package:flutter/material.dart';

class ContactSafeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final Widget? leading;
  final List<Widget>? actions;

  const ContactSafeHeader({
    Key? key,
    required this.titleText,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 80.0, // Give more width to the leading widget
      leading:
          leading != null
              ? Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                ), // Add some left padding
                child: leading,
              )
              : null,
      title: Text(titleText), // Simplified title
      centerTitle: true, // Center the title
      actions: actions,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
