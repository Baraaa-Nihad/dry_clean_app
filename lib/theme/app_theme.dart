import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.transparent,
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.blue,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.white, // Set to white for both themes
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.blue,
    ),
  );

  static LinearGradient getPrimaryGradient(BuildContext context) {
    return LinearGradient(
      colors: [AppColors.green, AppColors.blue],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient getHorizontalPrimaryGradient(BuildContext context) {
    return LinearGradient(
      stops: [0.1, 1.0],
      colors: [AppColors.gradientStart, AppColors.gradientEnd],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  static LinearGradient getPrimaryDisabledGradient(BuildContext context) {
    return LinearGradient(
      colors: [
        Color(0xFFB2EBF2), // Light Cyan
        Color(0xFF80DEEA), // Cyan
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient getSecondaryGradient(BuildContext context) {
    return LinearGradient(
      colors: [
        Color(0xFF00B4DB), // Light Blue
        Color(0xFF0083B0), // Dark Blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static Color getSecondaryDisabledColor(BuildContext context) {
    return Colors.grey.shade300;
  }
}
