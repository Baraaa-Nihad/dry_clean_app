import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CountryCodeStyle {
  static InputDecoration getInputDecoration(
    bool isFocused,
    bool isValid,
    String labelText, {
    bool isEmpty = false,
    Widget? prefix,
  }) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: _getLabelColor(isFocused, isValid, isEmpty),
        fontWeight: _getLabelFontWeight(isFocused, isEmpty),
      ),
      prefixIcon: prefix,
    );
  }

  static Color _getLabelColor(bool isFocused, bool isValid, bool isEmpty) {
    return AppColors.gray80;
  }

  static FontWeight _getLabelFontWeight(bool isFocused, bool isEmpty) {
    return FontWeight.bold;
  }
}
