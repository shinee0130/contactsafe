import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../l10n/app_localizations.dart';

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
      items: [
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.person_2),
          label: context.loc.translate('contacts'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.search),
          label: context.loc.translate('search'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.calendar),
          label: context.loc.translate('events'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.photo),
          label: context.loc.translate('photos'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.settings),
          label: context.loc.translate('settings'),
        ),
      ],
    );
  }
}
