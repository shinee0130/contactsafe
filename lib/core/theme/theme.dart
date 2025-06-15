import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
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
    selectedItemColor: kIOSPrimaryBlue,
    unselectedItemColor: kIOSSecondaryText,
    selectedIconTheme: IconThemeData(color: kIOSPrimaryBlue),
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
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
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
    selectedItemColor: kIOSPrimaryBlue,
    unselectedItemColor: kIOSDarkSecondaryText,
    selectedIconTheme: IconThemeData(color: kIOSPrimaryBlue),
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
);
