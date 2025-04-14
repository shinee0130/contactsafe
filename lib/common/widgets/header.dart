import 'package:flutter/material.dart';
import 'package:contactsafe/common/theme/app_colors.dart';
import 'package:contactsafe/common/theme/app_styles.dart';

class ContactSafeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final VoidCallback? onGroupsPressed;
  final VoidCallback? onAddPressed;
  final Widget? logo;

  const ContactSafeHeader({
    Key? key,
    required this.titleText,
    this.onGroupsPressed,
    this.onAddPressed,
    this.logo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titleText,
            style: AppStyles.headlineSmall.copyWith(
              // Adjust based on Figma size
              fontWeight: FontWeight.w500, // Adjust based on Figma weight
              fontSize: 18, // Example: Adjust font size
            ),
          ),
          SizedBox(width: 10),
          if (logo != null) logo!,
        ],
      ),
      leadingWidth: 100.0, // Adjust width for "Groups" text
      leading:
          onGroupsPressed != null
              ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextButton(
                  onPressed: onGroupsPressed,
                  child: Text(
                    'Groups',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 17, // Adjust based on Figma size
                      fontWeight:
                          FontWeight.w500, // Adjust based on Figma weight
                    ),
                  ),
                ),
              )
              : null,
      actions: [
        if (onAddPressed != null)
          IconButton(
            icon: Icon(
              Icons.add,
              color: AppColors.primary,
              size: 30, // Adjust icon size if needed
            ),
            onPressed: onAddPressed,
          ),
        SizedBox(width: 16),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
