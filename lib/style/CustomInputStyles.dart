import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CustomInputStyles {
  static InputDecoration getInputDecoration(
    bool isFocused,
    bool isValid,
    bool isDisabled,
    BuildContext context,
    String labelTextPrimary, {
    String? labelTextSecondary,
    bool hasError = false,
    bool isEmpty = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    double fem = 1.0,
    bool filled = false, // Added filled property
    Color fillColor = AppColors.white, // Added fillColor propert
    Color? labelTextColor, // Optional label text color
  }) {
    return InputDecoration(
      border: _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      enabledBorder:
          _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      focusedBorder:
          _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      disabledBorder:
          _getBorder(isFocused, isValid, isEmpty, isDisabled, hasError),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: filled, // Set filled property
      fillColor: fillColor, // Set fillColor property
      labelStyle: TextStyle(
        color:
            labelTextColor ?? AppColors.gray60, // Use provided color or default
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      label: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: labelTextPrimary,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray50),
              ),
            ),
            if (labelTextSecondary != null)
              TextSpan(
                text: ' $labelTextSecondary',
                style: AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray50),
              ),
          ],
        ),
      ),

      prefixIcon: prefixIcon != null
          ? SizedBox(
              width: 24,
              height: 24,
              child: FittedBox(
                fit: BoxFit.contain,
                child: prefixIcon,
              ),
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
      return AppColors.red; // Handle disabled state color first
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
