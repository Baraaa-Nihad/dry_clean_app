import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

class TimeSelectionProvider with ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;
  String? get errorMessage => _errorMessage;
  final TokenService _tokenService = TokenService();

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> fetchDryCleanDetails(
      int areaId, String lang) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final url =
        Uri.parse('${Config.fetchDryCleanDetails}?area_id=$areaId&lang=$lang');
    final client = ApiClient.createClient(_tokenService);

    print('Request URL: $url');

    try {
      final response = await client.get(url);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Dry clean details response: $responseData');

        if (responseData['success'] == true) {
          _isLoading = false;
          notifyListeners();
          return responseData['data'];
        } else {
          setErrorMessage('Invalid response format');
          return {};
        }
      } else {
        final errorResponse = json.decode(response.body);
        setErrorMessage(
            errorResponse['message'] ?? 'Failed to load dry clean details');
        return {};
      }
    } catch (error) {
      setErrorMessage('Error loading dry clean details: $error');
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches delivery time slots based on the selected pickup date and time.
  /// [areaId]    — the area of the selected delivery address
  /// [lang]      — "en" or "ar"
  /// [pickupDate] — "DD/MM/YYYY" (collectionDate from OrderProvider)
  /// [pickupTime] — "AM HH:MM - HH:MM" (period + formatted slot label)
  Future<Map<String, dynamic>> fetchDeliveryTimes(
      int areaId, String lang, String pickupDate, String pickupTime) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(Config.getDeliveryTimesApi);
    final client = ApiClient.createClient(_tokenService);

    print('fetchDeliveryTimes → $url  date=$pickupDate  time=$pickupTime');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'area_id': areaId,
          'lang': lang,
          'pickup_date': pickupDate,
          'pickup_time': pickupTime,
        }),
      );

      print('fetchDeliveryTimes status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          _isLoading = false;
          notifyListeners();
          return responseData['data'] ?? {};
        } else {
          setErrorMessage(responseData['message'] ?? 'Invalid delivery times response');
          return {};
        }
      } else {
        final errorResponse = json.decode(response.body);
        setErrorMessage(errorResponse['message'] ?? 'Failed to load delivery times');
        return {};
      }
    } catch (error) {
      setErrorMessage('Error loading delivery times: $error');
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
