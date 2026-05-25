import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class MobileInputStyles {
  static InputDecoration getInputDecoration(
    BuildContext context,
    bool isFocused,
    bool isValid,
    bool isDisabled,
    String labelTextPrimary, {
    String? labelTextSecondary,
    bool isEmpty = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    double fem = 1.0,
    bool hasError = false,
    bool isRtl = true,
    bool showDropdown = true, // Dropdown visibility
  }) {
    // Define text direction based on isRtl flag
    TextDirection textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;

    return InputDecoration(
      border: _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      enabledBorder:
          _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      focusedBorder:
          _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      disabledBorder:
          _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: EdgeInsets.all(12.0), // Use dynamic padding here
      label: Align(
        alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
        child: Directionality(
          textDirection: textDirection,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: labelTextPrimary,
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      height: 0,
                      color: AppColors.gray50,
                    ),
                  ),
                ),
                if (labelTextSecondary != null)
                  TextSpan(
                    text: ' $labelTextSecondary',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        height: 0,
                        color: AppColors.gray50,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      labelStyle: AppTextStyles.regular16Gray80(context).copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        color: AppColors.gray50,
      ),
      prefixIcon: prefixIcon != null
          ? Container(
              padding: EdgeInsets.only(
                right: isRtl ? 0.0 : 12.0,
                left: isRtl ? 12.0 : 0.0,
              ),
              alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              width: 90,
              child: prefixIcon,
            )
          : null,
      suffixIcon: suffixIcon != null
          ? SizedBox(
              width: 24,
              height: 24,
              child: FittedBox(
                fit: BoxFit.contain,
                child: suffixIcon,
              ),
            )
          : null,
    );
  }

  static OutlineInputBorder _getBorder(
    bool isFocused,
    bool isValid,
    bool isEmpty,
    bool isDisabled,
    bool hasError,
  ) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        width: 1,
        color:
            _getBorderColor(isFocused, isValid, isEmpty, isDisabled, hasError),
      ),
    );
  }

  static Color _getBorderColor(
    bool isFocused,
    bool isValid,
    bool isEmpty,
    bool isDisabled,
    bool hasError,
  ) {
    if (hasError) {
      return AppColors.red; // Error state color
    }
    if (isDisabled) {
      return AppColors.gray20; // Handle disabled state color first
    }
    if (!isFocused && isEmpty) {
      return AppColors.gray20;
    }
    if (isEmpty) {
      return AppColors.gray80;
    }
    if (!isValid) {
      return AppColors.red;
    }
    if (isFocused) {
      return AppColors.gray80;
    }

    return AppColors.gray20;
  }
}
