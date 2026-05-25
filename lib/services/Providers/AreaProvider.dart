import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Area.dart';

class AreaProvider with ChangeNotifier {
  List<Area> _areas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Area> get areas => _areas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchAreas(String language, String governateId) async {
    setLoading(true);
    _errorMessage = null; // Reset error message

    final url = Uri.parse(
        '${Config.fetchAreas}?language=$language&governate_id=$governateId');
    print('Request URL: $url');

    try {
      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Ensure the responseData contains the 'data' list of areas
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final areasData =
              responseData['data']; // Get the 'data' field from the response
          if (areasData is List) {
            print('Areas fetched successfully: $areasData');
            _areas = areasData.map((area) => Area.fromJson(area)).toList();
          } else {
            _errorMessage = 'Invalid data format';
            print('Invalid data format: $responseData');
          }
        } else {
          _errorMessage = 'Invalid response format';
          print('Invalid response format: $responseData');
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to load areas';
        print('Failed to load areas: $errorResponse');
      }
    } catch (error) {
      _errorMessage = 'Error loading areas: $error';
      print(_errorMessage);
    } finally {
      setLoading(false);
    }
  }
}
