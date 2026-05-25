import 'package:intl/intl.dart';

class ValidationUtils {
  static bool validateInput(String input, bool isRequired) {
    if (!isRequired) return true;
    if (input.isEmpty) return false;

    // Check for valid length based on the starting digit
    if (input.startsWith('0') && input.length == 10) {
      return true;
    } else if (input.startsWith('5') && input.length == 9) {
      return true;
    }

    return false;
  }

  static String removeLeadingPlus(String phoneNumber) {
    if (phoneNumber.startsWith('+')) {
      return phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  bool validateMobileNumber(String mobileNumber) {
    if (mobileNumber.startsWith('0') && mobileNumber.length == 10) {
      return true;
    } else if (mobileNumber.startsWith('5') && mobileNumber.length == 9) {
      return true;
    } else if ((mobileNumber.startsWith('972') ||
            mobileNumber.startsWith('970')) &&
        mobileNumber.length == 12) {
      return true;
    } else if (mobileNumber.startsWith('+') && mobileNumber.length == 13) {
      return true;
    }
    return false;
  }

  String cleanPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  // Method to format the date and time string
  String formatDateTime(String dateString) {
    print(dateString);
    try {
      // Assuming dateString is in the format "05/08/2024"
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(dateString);

      // Format it without the year
      String formattedDate = DateFormat('dd/MM').format(parsedDate);

      return formattedDate;
    } catch (e) {
      // Print the exception for debugging
      print('Error formatting date: $e');
      return "Invalid date format";
    }
  }

  String formatGeneralDateTime(String dateString) {
    try {
      // Parse the date string to a DateTime object
      DateTime parsedDate = DateTime.parse(dateString);

      // Format the time to "h:mm a" (e.g., "7:23 PM")
      String formattedTime = DateFormat('h:mm a').format(parsedDate);

      // Format the date to "dd/MM/yyyy" (e.g., "30/06/2023")
      String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

      // Combine time and date with "•" separator
      return '$formattedTime • $formattedDate';
    } catch (e) {
      // Handle the exception and return a default message
      print('Error formatting date: $e');
      return "Invalid date format";
    }
  }

  static String formatTime(String time) {
    final DateFormat inputFormat = DateFormat('HH:mm');
    final DateFormat outputFormat = DateFormat('h:mm');
    final DateTime parsedTime = inputFormat.parse(time);
    return outputFormat.format(parsedTime);
  }

  static String translateAmPm(String time, String lang) {
    if (lang == 'ar') {
      return time.replaceAll('AM', 'ص').replaceAll('PM', 'م');
    }
    return time;
  }

  String formatOrderId(int orderId) {
    return '#${orderId.toString().padLeft(5, '0')}';
  }
}
