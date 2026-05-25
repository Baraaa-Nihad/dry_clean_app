import 'package:flutter/material.dart';

class MobileNumberProvider with ChangeNotifier {
  TextEditingController mobileNumberController = TextEditingController();
  FocusNode mobileFocusNode = FocusNode();
  String selectedCountryCode = '+970';
  bool isButtonDisabled = true;

  // Handle country code change
  void onCountryCodeChanged(String countryCode) {
    selectedCountryCode = countryCode;
    notifyListeners();
  }

  // Handle mobile number input validation
  void onInputChange(bool isValid) {
    isButtonDisabled = !isValid;
    notifyListeners();
  }

  // Method to send the mobile number (Placeholder logic)
  Future<void> sendMobileNumber() async {
    // Logic for sending the mobile number
    String mobileNumber =
        selectedCountryCode + mobileNumberController.text.trim();
    // Add your logic to send the mobile number to the backend
    print("Sending mobile number: $mobileNumber");

    // Example: Simulating a network call delay
    await Future.delayed(Duration(seconds: 2));
  }

  // Clean up the controller and focus node
  @override
  void dispose() {
    mobileNumberController.dispose();
    mobileFocusNode.dispose();
    super.dispose();
  }
}
