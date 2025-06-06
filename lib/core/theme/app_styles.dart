import 'package:flutter/material.dart';
import 'package:contactsafe/core/theme/app_colors.dart'; // Import your colors

class AppStyles {
  // Base Text Style
  static const TextStyle baseTextStyle = TextStyle(
    fontFamily: 'Roboto', // You can set a default font family here
    color: AppColors.textPrimary,
  );

  // Headlines
  static final TextStyle headlineLarge = baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineMedium = baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineSmall = baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body Text
  static final TextStyle bodyLarge = baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodyMedium = baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodySmall = baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Label Text
  static final TextStyle labelLarge = baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final TextStyle labelMedium = baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final TextStyle labelSmall = baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Button Text
  // static final TextStyle buttonText = baseTextStyle.copyWith(
  //   fontSize: 16,
  //   fontWeight: FontWeight.w500,
  //   color: AppColors.textLight,
  // );

  // You can add more custom text styles as needed
}
