import 'package:flutter/material.dart';
import '../theme/AppColors.dart';
import '../style/AppTextStyles.dart';

class AppSecondaryButtonStyles {
  static final Color borderColor = AppColors.gray20;

  static final Gradient buttonGradient = LinearGradient(
    begin: Alignment(-1.00, -0.00),
    end: Alignment(4, 0),
    colors: [AppColors.blue, AppColors.green],
  );

  static final Gradient disabledButtonGradient = LinearGradient(
    colors: [Colors.grey.shade300, const Color.fromRGBO(224, 224, 224, 1)],
  );

  static Decoration getDecoration(bool isDisabled) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDisabled ? borderColor : borderColor,
      ),
    );
  }

  static ButtonStyle getButtonStyle(BuildContext context, bool isDisabled) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 24)),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      )),
      backgroundColor: MaterialStateProperty.all(AppColors.white),
      elevation: MaterialStateProperty.all(0),
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.grey.withOpacity(0.1);
          }
          return null;
        },
      ),
    );
  }
}
