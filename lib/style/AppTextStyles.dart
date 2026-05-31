import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class AppTextStyles {
  static const TextStyle poppinsBold = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w900,
  );

  static const TextStyle sfarabicBold = TextStyle(
    fontFamily: 'BalooBhaijaan',
    fontWeight: FontWeight.w900,
  );

  static const TextStyle poppinsSemiBold = TextStyle(
    fontFamily: 'BalooBhaijaan',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle poppinsMedium = TextStyle(
    fontFamily: 'BalooBhaijaan',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle poppinsRegular = TextStyle(
    fontFamily: 'BalooBhaijaan',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle sfarabicSemiBold = TextStyle(
    fontFamily: 'BalooBhaijaan',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sfarabicMedium = TextStyle(
    fontFamily: 'BalooBhaijaan',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sfarabicRegular = TextStyle(
    fontFamily: 'BalooBhaijaan',
    fontWeight: FontWeight.w400,
  );

  static TextStyle bold16White(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    );
  }

  static TextStyle bold16Gray(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: AppColors.grey,
    );
  }

  static TextStyle bold16Red(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: AppColors.red,
    );
  }

  static TextStyle regular16Red(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w400,
      color: AppColors.red,
    );
  }

  static TextStyle regular14RedW400(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w400,
      color: AppColors.red,
    );
  }

  static TextStyle regular14RedW500(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w500,
      color: AppColors.red,
    );
  }

  static TextStyle regular16White(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle bold16Gray80(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: AppColors.gray80,
    );
  }

  static TextStyle bold16Gray70(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: AppColors.gray70,
    );
  }

  static TextStyle regular16Gray80(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w500,
      color: AppColors.gray80,
    );
  }

  static TextStyle regular16Gray70(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w900,
      color: AppColors.gray70,
    );
  }

  static TextStyle regular16Gray60(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w900,
      color: AppColors.gray60,
    );
  }

  static TextStyle regular16Gray50(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w500,
      color: AppColors.gray50,
    );
  }

  static TextStyle regular16Gray40(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w500,
      color: AppColors.gray40,
    );
  }

  static TextStyle bold16Gray50(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: AppColors.gray50,
    );
  }

  static TextStyle semibold16Gray50(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: AppColors.gray50,
    );
  }

  static TextStyle semibold16Gray60(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: AppColors.gray60,
    );
  }

  static TextStyle bold16Gradient(BuildContext context) {
    return TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = const LinearGradient(
          begin: Alignment(-1.00, -0.00),
          end: Alignment(7, 0),
          colors: [AppColors.blue, AppColors.green],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
    );
  }

  static TextStyle bold16GradientSmall(BuildContext context) {
    return TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = const LinearGradient(
          begin: Alignment(1.00, -0.00),
          end: Alignment(1, 0),
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
    );
  }

  static TextStyle getFontFamily(BuildContext context, TextStyle style) {
    Locale locale = Localizations.localeOf(context);
    String fontFamily = 'Poppins';

    if (locale.languageCode == 'ar') {
      fontFamily = 'BalooBhaijaan';
    }

    return style.copyWith(fontFamily: fontFamily);
  }

  static TextStyle getFontFamilyReverse(BuildContext context, TextStyle style) {
    Locale locale = Localizations.localeOf(context);
    String fontFamily = 'BalooBhaijaan';

    if (locale.languageCode == 'ar') {
      fontFamily = 'Poppins';
    }

    return style.copyWith(fontFamily: fontFamily);
  }
}
