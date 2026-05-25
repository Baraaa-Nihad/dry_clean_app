import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color blue = Color(0xFF00B4DB);
  static const Color green = Color(0xFF00E213);
  static const Gradient gradient = LinearGradient(
    colors: [blue, green],
  );

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFF44336);
  static const Color redAccent = Color(0xFFFF5252);

  static const Color transparent = Color(0x00000000);
  static const Color backgroundColor = Color(0xFFF9F9FF);
  static const Color primaryColor = Color(0xFF1D4ED8);
  static const Color primaryTextColor = Color(0xFF1D4ED8);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color inActiveColor = Color(0xFFC5D4E6);

  static const Color inactiveColor = Color(0xFF9CA3AF);
  static const Color shadowColor = Color(0x1A8B84CB);
  static const Color gradientStart = Color(0xFF01B5CF);
  static const Color gradientEnd = Color(0xFF00E213);
  static const Color activeTextColor = Color(0xFF00E213);
  static const Color inactiveTextColor = Color(0xFFACBED4);

  //service cards color
  static const Color prpuleCard = Color(0xFF642DD9);
  static const Color greenCard = Color(0xFF01C58E);
  static const Color blueCard = Color(0xFF01B5CF);
  static const Color orangeCard = Color(0xFFFFA500);
  //services card background
  static const Color purbleCardBackgourd = Color(0xFFF3EDFF);
  static const Color greenCardBackgourd = Color(0xFFEFFFF0);
  static const Color blueCardBackgourd = Color(0xFFE5FAFF);
  static const Color orangeCardBackgourd = Color(0xFFFFF9EF);

  // Grays
  static const Color gray80 = Color(0xFF02295A);
  static const Color gray70 = Color(0xFF033371);
  static const Color gray60 = Color(0xFF335B8D);
  static const Color gray50 = Color(0xFF6382AA);
  static const Color gray40 = Color(0xFF96A3C8);
  static const Color gray30 = Color(0xFFC4D1E3);
  static const Color gray20 = Color(0xFFE5EAF6);
  static const Color gray10 =
      Color(0xFFF9F9FF); // Replace with your desired color

  static const Color stroke = Color(0xFFE5EAF6);
  static const Color background = Color(0xFFFAFCFF);
  static const Color grey = Color(0xFFE0E0E0);

  // Status colors
  static const Color statusGreen = Color(0xFF49C00F);
  static const Color statusRed = Color(0xFFF44336);
  static const Color cta = Color(0xFF2477E1);
  static const Color pending = Color(0xFFFFA500);

  static const Color notificationColor = Color(0xFFE3342F);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  // Shadow colors
  static const Color _secondaryButtonShadowBase = Color(0xFF000000);
  static const Color _primaryButtonShadowBase = Color(0x3301C58E);

  //loding Dots
  static const Color loadingInActive = Color.fromARGB(255, 208, 218, 229);
  static const Color lodingActive = Color.fromARGB(255, 213, 222, 233);

//cards Sections
  static const Color laundryCardColor = Color(0xFFFFF0F0);
  static const Color carpetsCardColor = Color(0xFFE0FFE0);
  static const Color curtainsCardColor = Color(0xFFE0F7FF);
  static const Color beddingCardColor = Color(0xFFFFE0FF);
  static const Color errorBackground = Color(0xFFFFF5F5);
  static const Color errorBorder = Color(0xFFFFE5E5);
  static const Color errorIconColor = Colors.red;

  static const Color warningBackground = Color(0xFFFFFDF6);
  static const Color warningBorder = Color(0xFFFFF6E5);
  static const Color warningIconColor = Colors.orange;

  static const Color successBackground = Color(0xFFF6FFF8);
  static const Color successBorder = Color(0xFFE5FFF6);
  static const Color successIconColor = Colors.green;

  static const Color infoBackground = Color(0xFFFFFDFA);
  static const Color infoBorder = Color(0xFFFFF6E5);
  static const Color infoIconColor = Colors.orange;
  static Color get secondaryButtonShadow =>
      _secondaryButtonShadowBase.withOpacity(0.03);
  static Color get primaryButtonShadow =>
      _primaryButtonShadowBase.withOpacity(0.2);
}
