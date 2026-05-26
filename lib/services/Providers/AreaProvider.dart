import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Area.dart';

class AreaProvider with ChangeNotifier {
  List<Area> _areas = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Area> get areas => _areas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Guard every notifyListeners call so that any lingering async callback
  /// that fires after dispose() is a no-op rather than a crash.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    _notify();
  }

  Future<void> fetchAreas(String language, String governateId) async {
    setLoading(true);
    _errorMessage = null;

    final url = Uri.parse(
        '${Config.fetchAreas}?language=$language&governate_id=$governateId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final areasData = responseData['data'];
          if (areasData is List) {
            _areas = areasData.map((area) => Area.fromJson(area)).toList();
          } else {
            _errorMessage = 'Invalid data format';
          }
        } else {
          _errorMessage = 'Invalid response format';
        }
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to load areas';
      }
    } catch (error) {
      _errorMessage = 'Error loading areas: $error';
    } finally {
      setLoading(false);
    }
  }
}
