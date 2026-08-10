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

String _number(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(2);
