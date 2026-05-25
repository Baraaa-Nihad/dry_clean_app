import 'package:flutter/services.dart';

class BackspaceDetectingTextInputFormatter extends TextInputFormatter {
  final void Function() onBackspace;

  BackspaceDetectingTextInputFormatter({required this.onBackspace});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.isNotEmpty && newValue.text.isEmpty) {
      onBackspace();
    }
    return newValue;
  }
}
