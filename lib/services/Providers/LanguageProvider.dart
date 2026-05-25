import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('en');
  VoidCallback? onLocaleChanged;

  Locale get locale => _locale;

  LanguageProvider({this.onLocaleChanged}) {
    _loadLocale();
  }

  // Load the locale from shared preferences or use the system locale
  Future<void> _loadLocale() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? languageCode = prefs.getString('language_code');

      if (languageCode != null) {
        _locale = Locale(languageCode);
      } else {
        _locale = WidgetsBinding.instance.window.locale ?? Locale('en');
        await _saveLocale(_locale.languageCode);
      }
    } catch (e) {
      // Handle any potential errors gracefully
      print("Error loading locale: $e");
    }

    notifyListeners();
  }

  // Update the locale and save it to shared preferences
  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;

    _locale = locale;
    await _saveLocale(locale.languageCode);
    notifyListeners();

    // Notify other components that might be listening for locale changes
    onLocaleChanged?.call();
  }

  // Toggle between English and Arabic
  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      _locale = Locale('ar');
    } else {
      _locale = Locale('en');
    }
    notifyListeners();
  }

  // Save the selected locale to shared preferences
  Future<void> _saveLocale(String languageCode) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (e) {
      // Handle any potential errors during saving
      print("Error saving locale: $e");
    }
  }
}
