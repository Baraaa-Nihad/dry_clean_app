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
  bool _isOtpVerified = false;
  String? _errorMessage;
  String mobileNumber = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOtpVerified => _isOtpVerified;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileNumber', mobileNumber);
  }

  Future<void> checkRegistrationAttempts(String language) async {
    setLoading(true);

    await saveMobileNumber();

    try {
      final url = Uri.parse('${Config.checkAttemptsApi}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobileNumber, 'language': language}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          await sendOtp(language);
        } else {
          _errorMessage = responseData['message'];
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to check attempts';
      }
    } catch (error) {
      _errorMessage = 'Error checking attempts: $error';
    } finally {
      setLoading(false);
    }
  }

  Future<bool> canSendOtp(String language) async {
    await saveMobileNumber();

    try {
      final url = Uri.parse('${Config.checkAttemptsApi}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobileNumber, 'language': language}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          return true;
        } else {
          _errorMessage = responseData['message'];
          return false;
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = 'Failed to check attempts: ${response.statusCode}';
        throw Exception(_errorMessage);
      }
    } catch (error) {
      _errorMessage = 'Error checking attempts: $error';
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

    setLoading(true);

    try {
      final url = Uri.parse('${Config.OtpApi}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobileNumber, 'language': language}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _errorMessage = null;
      } else {
        if (response.statusCode == 400 &&
            responseData['code'] == 'USER_EXISTS') {
          _errorMessage = 'This phone number is already registered.';
        } else {
          _errorMessage = responseData['code'] ?? 'Failed to send OTP';
        }
      }
    } catch (error) {
      _errorMessage = 'Error sending OTP: $error';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> verifyOtp(
      String language, BuildContext context, VoidCallback onSuccess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobileNumber = prefs.getString('mobileNumber') ?? '';

    if (mobileNumber.isEmpty) {
      await saveMobileNumber();
      mobileNumber = prefs.getString('mobileNumber') ?? '';
    }

    final String otp = otpController.text.trim();

    _errorMessage = null;
    setLoading(true);

    try {
      final url = Uri.parse('${Config.verifyUserOtpApi}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'mobile': mobileNumber, 'otp': otp, 'language': language}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        _errorMessage = null;
        setOtpVerified(true);
        onSuccess();
      } else {
        _errorMessage = responseData['message'] ?? 'Failed to verify OTP';
      }
    } catch (error) {
      _errorMessage = 'Error verifying OTP: $error';
    } finally {
      setLoading(false);
    }
  }

  Future<void> submitRegistrationForm(Map<String, String> formData,
      String language, BuildContext context) async {
    setLoading(true);
    try {
      final url = Uri.parse('${Config.registerApi}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': formData['firstName'],
          'lastName': formData['lastName'],
          'area': formData['area'],
          'mobile': formData['mobile'],
          'password': formData['password'],
          'dob': formData['dob'],
          'gender': formData['gender'],
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'Registration successful!') {
          final _secureStorage = FlutterSecureStorage();
          await _secureStorage.write(
              key: 'phoneNumber', value: formData['mobile']);
          await _secureStorage.write(
              key: 'password', value: formData['password']);
          await _secureStorage.write(key: 'role', value: 'user');

          AccountCreatedModal.show(context, responseData);
        } else {
          _errorMessage = responseData['message'];
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to register';
      }
    } catch (error) {
      _errorMessage = 'Error registering: $error';
    } finally {
      setLoading(false);
      notifyListeners();
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
