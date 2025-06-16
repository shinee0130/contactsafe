import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// A reusable AppBar that keeps the [ContactSafe] title and logo perfectly
/// centered regardless of the width of the leading widget or action buttons.
class ContactSafeAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Widget displayed at the start of the bar (usually a back button).
  final Widget? leading;

  /// Widgets displayed at the end of the bar.
  final List<Widget>? actions;

  /// A widget to display below the bar (e.g. a [TabBar]).
  final PreferredSizeWidget? bottom;

  /// Background color of the bar.
  final Color? backgroundColor;

  /// Elevation of the bar.
  final double? elevation;

  const ContactSafeAppBar({
    super.key,
    this.leading,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor ?? theme.appBarTheme.backgroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation ?? 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (leading != null)
                    Align(alignment: Alignment.centerLeft, child: leading),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.loc.appTitle,
                          style: theme.appBarTheme.titleTextStyle,
                        ),
                        const SizedBox(width: 5),
                        Image.asset('assets/contactsafe_logo.png', height: 26),
                      ],
                    ),
                  ),
                  if (actions != null && actions!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}
