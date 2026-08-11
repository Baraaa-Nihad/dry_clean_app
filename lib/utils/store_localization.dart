import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

String localizedTurnaround(BuildContext context, int? hours) {
  if (hours == null || hours <= 0) return '';
  final l10n = AppLocalizations.of(context);
  if (hours < 24) {
    return l10n.translate(
      'duration_hours',
      params: {'count': '$hours'},
    );
  }

  final days = (hours / 24).round();
  if (days == 1) return l10n.translate('duration_one_day');
  return l10n.translate(
    'duration_days',
    params: {'count': '$days'},
  );
}

String localizedProductSize(BuildContext context, ProductSize size) {
  final l10n = AppLocalizations.of(context);
  return l10n.translate(
    'size_preset_label',
    params: {
      'width': _number(size.width),
      'height': _number(size.height),
      'area': _number(size.area),
    },
  );
}

/// يترجم أسماء الكتالوج المخزّنة في السلة عند تبديل لغة التطبيق.
///
/// بيانات السلة قد تكون أُضيفت قبل تغيير اللغة؛ لهذا لا يكفي الاعتماد على
/// النص المحفوظ كما هو. الأسماء المعرّفة في ملفات اللغة تُترجم، والمقاسات
/// الديناميكية تحافظ على أرقامها مع تعريب وحدة المتر فقط.
String localizedCatalogValue(BuildContext context, String value) {
  final l10n = AppLocalizations.of(context);
  final translated = l10n.hasTranslation(value)
      ? l10n.translate(value)
      : value;
  if (Localizations.localeOf(context).languageCode != 'ar') return translated;

  return translated
      .replaceAll('m²', 'م²')
      .replaceAll(RegExp(r'\bm\b', caseSensitive: false), 'م');
}

String _number(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(2);
