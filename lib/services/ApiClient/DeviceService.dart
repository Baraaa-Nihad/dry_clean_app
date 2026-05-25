// lib/services/DeviceService.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Device.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';

class DeviceService {
  final TokenService tokenService;
  final http.Client _client;

  DeviceService(this.tokenService)
      : _client = ApiClient.createClient(tokenService);

  /// Registers the device token with the backend.
  Future<bool> registerDevice(Device device) async {
    final url = Uri.parse('${Config.deviceRegistration}');

    try {
      final jwtToken = await tokenService.getAccessToken();
      if (jwtToken == null) {
        print('registerDevice: JWT Token is null. Skipping registration.');
        return false; // Gracefully handle the absence of a token
      }

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode(device.toJson()),
      );

      if (response.statusCode == 200) {
        print('Device registered successfully.');
        return true;
      } else {
        print('Failed to register device: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error registering device: $e');
      return false;
    }
  }

  /// Unregisters the device token from the backend (if needed).
  Future<bool> unregisterDevice(String deviceToken) async {
    final url = Uri.parse('${Config.deviceUnregistration}');

    try {
      final jwtToken = await tokenService.getAccessToken();
      if (jwtToken == null) {
        print('unregisterDevice: JWT Token is null. Skipping unregistration.');
        return false; // Gracefully handle the absence of a token
      }

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'deviceToken': deviceToken}),
      );

      if (response.statusCode == 200) {
        print('Device unregistered successfully.');
        return true;
      } else {
        print('Failed to unregister device: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error unregistering device: $e');
      return false;
    }
  }
}
