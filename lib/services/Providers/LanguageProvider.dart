import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('en');
  int _localeVersion = 0;
  VoidCallback? onLocaleChanged;

  Locale get locale => _locale;

  LanguageProvider({this.onLocaleChanged}) {
    _loadLocale();
  }

  // Load the locale from shared preferences or use the system locale
  Future<void> _loadLocale() async {
    final loadVersion = _localeVersion;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? languageCode = prefs.getString('language_code');

      final loadedLocale = languageCode != null
          ? Locale(languageCode)
          : () {
              const supportedCodes = ['en', 'ar'];
              final systemCode =
                  PlatformDispatcher.instance.locale.languageCode;
              return Locale(
                  supportedCodes.contains(systemCode) ? systemCode : 'en');
            }();

      // Do not overwrite a language selected by the user while the stored
      // preference was still loading.
      if (loadVersion != _localeVersion) return;

      _locale = loadedLocale;
      if (languageCode == null) {
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
    _localeVersion++;
    notifyListeners();

    await _saveLocale(locale.languageCode);

    // Notify other components that might be listening for locale changes
    onLocaleChanged?.call();
  }

  // Toggle between English and Arabic
  Future<void> toggleLanguage() =>
      setLocale(Locale(_locale.languageCode == 'en' ? 'ar' : 'en'));

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
