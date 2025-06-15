import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ContactSafeNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ContactSafeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      backgroundColor: colorScheme.surface,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_2),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.calendar),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.photo),
          label: 'Photos',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
