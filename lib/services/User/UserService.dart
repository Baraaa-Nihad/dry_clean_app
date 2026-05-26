// lib/services/User/UserService.dart

import 'dart:convert';

import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/utils/CustomLengthFormatter/DateUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  final _secureStorage = FlutterSecureStorage();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  Future<bool> isUserSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSignedIn') ?? false;
  }

  Future<void> signIn(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // All keys are independent — write them in parallel
    await Future.wait([
      prefs.setBool('isSignedIn', true),
      prefs.setString('firstName', user.firstName),
      prefs.setString('lastName', user.lastName),
      prefs.setString('email', user.email),
      prefs.setString('phoneNumber', user.phoneNumber),
      prefs.setString('id', user.id),
      prefs.setString('gender', user.gender),
      prefs.setString('dateOfBirth', user.dateOfBirth),
      prefs.setBool('isVerified', user.isVerified),
      prefs.setString('addresses', json.encode(user.addresses)),
      prefs.setString('deviceTokens', json.encode(user.deviceTokens)),
    ]);
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }

  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final email = prefs.getString('email');
    final phoneNumber = prefs.getString('phoneNumber');
    final id = prefs.getString('id');
    final gender = prefs.getString('gender');
    final dateOfBirth = prefs.getString('dateOfBirth');
    final isVerified = prefs.getBool('isVerified');
    final addressJson = prefs.getString('addresses');
    final deviceTokensJson =
        prefs.getString('deviceTokens'); // Retrieve device tokens

    if (firstName != null &&
        lastName != null &&
        email != null &&
        phoneNumber != null &&
        id != null &&
        gender != null &&
        dateOfBirth != null &&
        isVerified != null &&
        addressJson != null &&
        deviceTokensJson != null) {
      final addresses =
          List<Map<String, dynamic>>.from(json.decode(addressJson));
      final deviceTokens = List<String>.from(
          json.decode(deviceTokensJson)); // Decode device tokens

      return User(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        id: id,
        gender: gender,
        dateOfBirth: dateOfBirth,
        isVerified: isVerified,
        addresses: addresses,
        deviceTokens: deviceTokens, // Assign device tokens
      );
    }
    return null;
  }

  // Optional: Update device tokens without modifying other user data
  Future<void> updateDeviceTokens(List<String> deviceTokens) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceTokens', json.encode(deviceTokens));
  }
}
