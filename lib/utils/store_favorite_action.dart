import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

Future<void> toggleStoreFavorite(
  BuildContext context, {
  required int storeId,
  bool? currentValue,
}) async {
  final result = await context.read<StoresProvider>().toggleFavorite(
        storeId,
        currentValue: currentValue,
      );

  if (!context.mounted) return;

  switch (result) {
    case FavoriteToggleResult.updated:
      return;
    case FavoriteToggleResult.authenticationRequired:
      NavigatorService.navigateTo(
        RouteNames.signIn,
        arguments: {'noticeKey': 'favorite_login_required'},
      );
      return;
    case FavoriteToggleResult.failed:
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.translate('favorite_update_failed'))),
        );
  }
}
