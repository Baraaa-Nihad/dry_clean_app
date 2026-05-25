import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saleem_dry_clean/components/Modals/AccountCreatedModal.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpProvider with ChangeNotifier {
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode otpFocusNode = FocusNode();

  String selectedCountryCode = '+970';
  bool agreedToTerms = false;
  bool isMobileNumberValid = false;
  bool isButtonEnabled = false;
  bool _isLoading = false;
  bool _isOtpVerified = false; // Add a flag for OTP verification
  String? _errorMessage;
  String mobileNumber = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOtpVerified =>
      _isOtpVerified; // Add getter for OTP verification flag

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setOtpVerified(bool verified) {
    _isOtpVerified = verified;
    notifyListeners();
  }

  void onCountryCodeChanged(String code) {
    selectedCountryCode = code;
    updateButtonState();
  }

  void toggleAgreement(bool value) {
    agreedToTerms = value;
    updateButtonState();
  }

  void onInputChange(bool isValid) {
    isMobileNumberValid = isValid;
    updateButtonState();
  }

  void updateButtonState() {
    bool isMobileNumberValid = ValidationUtils.validateInput(
      mobileNumberController.text,
      true,
    );

    isButtonEnabled = agreedToTerms && isMobileNumberValid;
    notifyListeners();
  }

  Future<void> saveMobileNumber() async {
    mobileNumber = selectedCountryCode + mobileNumberController.text;
    print("Mobile Number saved: $mobileNumber");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileNumber', mobileNumber);
  }

  Future<void> loadMobileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobileNumber = prefs.getString('mobileNumber') ?? '';
    notifyListeners();
  }

  Future<void> updateMobileNumber() async {
    mobileNumber = selectedCountryCode + mobileNumberController.text;
    print("Mobile Number updated: $mobileNumber");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileNumber', mobileNumber);
  }

  Future<void> checkRegistrationAttempts(String language) async {
    setLoading(true);

    await saveMobileNumber();

    try {
      final url = Uri.parse('${Config.checkAttemptsApi}');
      print('Request URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobileNumber, 'language': language}),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          await sendOtp(language); // Send OTP if no too many requests error
        } else {
          _errorMessage = responseData['message'];
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to check attempts';
        print('Failed to check attempts: $errorResponse');
      }
    } catch (error) {
      _errorMessage = 'Error checking attempts: $error';
      print(_errorMessage);
    } finally {
      setLoading(false);
    }
  }

  Future<bool> canSendOtp(String language) async {
    await saveMobileNumber();

    try {
      final url = Uri.parse('${Config.checkAttemptsApi}');
      print('Request URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobileNumber, 'language': language}),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          return true; // Can send OTP
        } else {
          _errorMessage = responseData['message'];
          return false; // Cannot send OTP
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = 'Failed to check attempts: ${response.statusCode}';
        print('Failed to check attempts: $errorResponse');
        throw Exception(_errorMessage);
      }
    } catch (error) {
      _errorMessage = 'Error checking attempts: $error';
      print(_errorMessage);
      return false;
    }
  }

  Future<void> sendOtp(String language) async {
    if (!agreedToTerms) {
      _errorMessage = 'You must agree to the terms and policy.';
      notifyListeners();
      return;
    }

    await saveMobileNumber();

    print("Sending OTP to $mobileNumber in $language");
    setLoading(true);

    try {
      final url = Uri.parse('${Config.OtpApi}');
      print('Request URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobileNumber, 'language': language}),
      );

      print('Response status: ${response.statusCode}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // OTP sent successfully
        print('OTP sent successfully: $responseData');
        _errorMessage = null; // Clear any previous error
      } else {
        // Check if the phone number is already registered
        if (response.statusCode == 400 &&
            responseData['code'] == 'USER_EXISTS') {
          _errorMessage = 'This phone number is already registered.';
        } else {
          _errorMessage = responseData['code'] ?? 'Failed to send OTP';
        }
        print('Failed to send OTP: $responseData');
      }
    } catch (error) {
      _errorMessage = 'Error sending OTP: $error';
      print(_errorMessage);
    } finally {
      setLoading(false);
      notifyListeners(); // Notify listeners to update the UI with the error message
    }
  }

  Future<void> verifyOtp(
      String language, BuildContext context, VoidCallback onSuccess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobileNumber = prefs.getString('mobileNumber') ?? '';
    print("Loaded mobile number: $mobileNumber");

    if (mobileNumber.isEmpty) {
      await saveMobileNumber();
      mobileNumber = prefs.getString('mobileNumber') ?? '';
      print("Saved and loaded new mobile number: $mobileNumber");
    }

    final String otp = otpController.text.trim();
    print("Verifying OTP for $mobileNumber with OTP: $otp");

    _errorMessage = null;
    setLoading(true);

    try {
      final url = Uri.parse('${Config.verifyUserOtpApi}');
      print('Request URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'mobile': mobileNumber, 'otp': otp, 'language': language}),
      );

      print('Response status: ${response.statusCode}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        print('OTP verified successfully: $responseData');
        _errorMessage = null;
        setOtpVerified(true);
        onSuccess(); // Call the callback function
      } else {
        _errorMessage = responseData['message'] ?? 'Failed to verify OTP';
        print('Failed to verify OTP: $_errorMessage');
      }
    } catch (error) {
      _errorMessage = 'Error verifying OTP: $error';
      print(_errorMessage);
    } finally {
      setLoading(false);
    }
  }

  Future<void> submitRegistrationForm(Map<String, String> formData,
      String language, BuildContext context) async {
    setLoading(true);
    print(formData);
    try {
      final url = Uri.parse('${Config.registerApi}');
      print('Request URL: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': formData['firstName'],
          'lastName': formData['lastName'],
          'area': formData['area'], // this should now be the area ID
          'mobile': formData['mobile'],
          'password': formData['password'],
          'dob': formData['dob'],
          'gender': formData['gender'],
          'language': language,
        }),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'Registration successful!') {
          print('Registration successful: $responseData');

          // Save user data into session storage
          final _secureStorage = FlutterSecureStorage();
          await _secureStorage.write(
              key: 'phoneNumber', value: formData['mobile']);
          await _secureStorage.write(
              key: 'password', value: formData['password']);
          await _secureStorage.write(
              key: 'role', value: 'user'); // Assuming the role is 'user'

          AccountCreatedModal.show(context, responseData);
        } else {
          _errorMessage = responseData['message'];
          print('Registration failed: $responseData');
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to register';
        print('Failed to register: $errorResponse');
      }
    } catch (error) {
      _errorMessage = 'Error registering: $error';
      print(_errorMessage);
    } finally {
      setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    mobileFocusNode.dispose();
    otpFocusNode.dispose();
    mobileNumberController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
