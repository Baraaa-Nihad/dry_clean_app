import 'package:flutter/services.dart';

class DynamicLengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxLength0;
  final int maxLength5;

  DynamicLengthLimitingTextInputFormatter({
    required this.maxLength0,
    required this.maxLength5,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    int maxLength = newText.startsWith('0') ? maxLength0 : maxLength5;

    if (newText.length > maxLength) {
      return oldValue;
    }

    return newValue;
  }
}
