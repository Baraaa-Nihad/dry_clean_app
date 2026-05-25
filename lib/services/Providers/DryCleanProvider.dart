import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/Models/DryClean.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DryCleanProvider with ChangeNotifier {
  DryClean? _dryClean;

  DryClean? get dryClean => _dryClean;

  void setDryClean(DryClean newDryClean) async {
    _dryClean = newDryClean;
    notifyListeners();

    // Save to session storage
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode({
      'id': newDryClean.id,
      'drycleanNameAr': newDryClean.drycleanNameAr,
      'phone': newDryClean.phone,
      'email': newDryClean.email,
      'deliveryFees': newDryClean.deliveryFees,
    });
    await prefs.setString('dryClean', jsonString);
  }

  void clearDryClean() async {
    _dryClean = null;
    notifyListeners();

    // Remove from session storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dryClean');
  }

  Future<void> loadDryClean() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('dryClean');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _dryClean = DryClean.fromJson(jsonMap);
      notifyListeners();
    }
  }
}
