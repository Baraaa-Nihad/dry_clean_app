// lib/utils/OnboardingProvider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/onboarding_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  bool _hasCompleted = false;
  bool _isActive = true;
  bool _isLoading = true;
  List<OnboardingStep> _steps = [];

  bool get hasCompleted => _hasCompleted;
  bool get isActive => _isActive;
  bool get isLoading => _isLoading;
  List<OnboardingStep> get steps => _steps;

  OnboardingProvider() {
    initialize();
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompleted = prefs.getBool('hasCompletedOnboarding') ?? false;

    if (!_hasCompleted) {
      await _fetchSteps();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSteps() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse(Config.getOnboardingApi))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _steps = data
            .map((e) => OnboardingStep.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('OnboardingProvider: fetch failed: $e');
    } finally {
      _isLoading = false;
      // No active steps from server → skip onboarding automatically
      if (_steps.isEmpty) {
        _hasCompleted = true;
      }
      notifyListeners();
    }
  }

  Future<void> completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    _hasCompleted = true;
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', false);
    _hasCompleted = false;
    _steps = [];
    notifyListeners();
  }

  void setHasCompleted(bool value) {
    _hasCompleted = value;
    notifyListeners();
  }
}
