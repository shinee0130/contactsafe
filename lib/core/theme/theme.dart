import 'package:flutter/material.dart';
import 'colors.dart';

final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
  seedColor: kIOSPrimaryBlue,
  brightness: Brightness.light,
);

final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
  seedColor: kIOSPrimaryBlue,
  brightness: Brightness.dark,
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  scaffoldBackgroundColor: kIOSBackground,
  primaryColor: kIOSPrimaryBlue,
  appBarTheme: AppBarTheme(
    backgroundColor: kIOSWhite,
    foregroundColor: kIOSText,
    elevation: 0,
    iconTheme: IconThemeData(color: kIOSPrimaryBlue),
    titleTextStyle: TextStyle(
      color: kIOSText,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  dividerColor: kIOSDivider,
  iconTheme: IconThemeData(color: kIOSPrimaryBlue),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kIOSWhite,
    selectedItemColor: _lightColorScheme.primary,
    unselectedItemColor: kIOSSecondaryText,
    selectedIconTheme: IconThemeData(color: _lightColorScheme.primary),
    unselectedIconTheme: IconThemeData(color: kIOSSecondaryText),
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: kIOSText),
    bodyMedium: TextStyle(color: kIOSText),
    titleLarge: TextStyle(color: kIOSText, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(color: kIOSSecondaryText),
  ),
  cardColor: kIOSWhite,
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) => kIOSWhite),
    trackColor: MaterialStateProperty.resolveWith(
      (states) =>
          states.contains(MaterialState.selected)
              ? kIOSPrimaryBlue
              : kIOSDivider,
    ),
  ),
  shadowColor: Colors.black.withOpacity(0.2),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  scaffoldBackgroundColor: kIOSDarkBackground,
  primaryColor: kIOSPrimaryBlue,
  appBarTheme: AppBarTheme(
    backgroundColor: kIOSDarkCard,
    foregroundColor: kIOSDarkText,
    elevation: 0,
    iconTheme: IconThemeData(color: kIOSPrimaryBlue),
    titleTextStyle: TextStyle(
      color: kIOSDarkText,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  dividerColor: kIOSDarkDivider,
  iconTheme: IconThemeData(color: kIOSPrimaryBlue),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kIOSDarkCard,
    selectedItemColor: _darkColorScheme.primary,
    unselectedItemColor: kIOSDarkSecondaryText,
    selectedIconTheme: IconThemeData(color: _darkColorScheme.primary),
    unselectedIconTheme: IconThemeData(color: kIOSDarkSecondaryText),
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: kIOSDarkText),
    bodyMedium: TextStyle(color: kIOSDarkText),
    titleLarge: TextStyle(color: kIOSDarkText, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(color: kIOSDarkSecondaryText),
  ),
  cardColor: kIOSDarkCard,
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) => kIOSDarkCard),
    trackColor: MaterialStateProperty.resolveWith(
      (states) =>
          states.contains(MaterialState.selected)
              ? kIOSPrimaryBlue
              : kIOSDarkDivider,
    ),
  ),
  shadowColor: Colors.black.withOpacity(0.2),
);
