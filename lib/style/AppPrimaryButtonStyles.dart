import 'package:flutter/material.dart';
import '../theme/AppColors.dart';
import '../style/AppTextStyles.dart';

class AppPrimaryButtonStyles {
  static final Gradient buttonGradient = LinearGradient(
    begin: Alignment(-1.00, -0.00),
    end: Alignment(4, 0),
    colors: [AppColors.blue, AppColors.green],
  );

  static final Gradient disabledButtonGradient = LinearGradient(
    begin: Alignment(-1.00, -0.00),
    end: Alignment(4, 0),
    colors: [
      AppColors.blue.withOpacity(0.3),
      AppColors.green.withOpacity(0.3),
    ],
  );

  static final List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x3301C58E),
      blurRadius: 16,
      offset: Offset(0, 4),
    )
  ];

  static Decoration getDecoration(bool isDisabled) {
    return BoxDecoration(
      gradient: isDisabled ? disabledButtonGradient : buttonGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: !isDisabled ? buttonShadow : null,
    );
  }

  static ButtonStyle getButtonStyle(BuildContext context, bool isDisabled) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 24)),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      foregroundColor: MaterialStateProperty.all(
          isDisabled ? AppColors.grey : AppColors.white),
      backgroundColor: MaterialStateProperty.all(AppColors.transparent),
      elevation: MaterialStateProperty.all(0),
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.grey.withOpacity(0.3);
          }
          return null;
        },
      ),
    );
  }
}
