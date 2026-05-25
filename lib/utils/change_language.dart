import 'package:flutter/material.dart';
import '../utils/localization.dart';

Future<void> changeLanguage(
    BuildContext context,
    Locale locale,
    Future<void> Function(Locale) onLocaleChange,
    VoidCallback setLoadingTrue,
    VoidCallback setLoadingFalse) async {
  setLoadingTrue();

  await Future.wait([
    onLocaleChange(locale),
    AppLocalizations(locale).load(),
    Future.delayed(Duration(milliseconds: 1000)),
  ]);

  setLoadingFalse();
}
