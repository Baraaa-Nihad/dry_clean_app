import 'package:flutter/services.dart';

class CustomLengthFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (newValue.text.startsWith('0') && newValue.text.length > 10) {
      return oldValue;
    } else if (newValue.text.startsWith('5') && newValue.text.length > 9) {
      return oldValue;
    } else if (!newValue.text.startsWith('0') &&
        !newValue.text.startsWith('5') &&
        newValue.text.length > 1) {
      return oldValue;
    }

    return newValue;
  }
  // class DynamicLengthLimitingTextInputFormatter extends TextInputFormatter {
//   final int maxLength0;
//   final int maxLength5;

//   DynamicLengthLimitingTextInputFormatter({
//     required this.maxLength0,
//     required this.maxLength5,
//   });

//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     String newText = newValue.text;

//     int maxLength = newText.startsWith('0')
//         ? maxLength0
//         : newText.startsWith('5')
//             ? maxLength5
//             : newText.length; // Allow full length if validation is disabled

//     if (newText.length > maxLength && maxLength != 0) {
//       return oldValue;
//     }

//     return newValue;
//   }
// }
}
