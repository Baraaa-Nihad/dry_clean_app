import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/services/Providers/LocationScopeProvider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/utils/OnboardingProvider.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

/// Resolves the first real screen without showing an intermediate route.
///
/// The caller keeps its current visual (the splash or the final onboarding
/// page) on screen while preferences and location data are prepared.
class StartupRouter {
  const StartupRouter._();

  static Future<String> resolve(BuildContext context) async {
    final onboarding = context.read<OnboardingProvider>();
    final location = context.read<LocationScopeProvider>();
    final stores = context.read<StoresProvider>();
    final order = context.read<OrderProvider>();
    final languageCode = context.read<LanguageProvider>().locale.languageCode;

    await onboarding.ready;

    if (onboarding.isActive && !onboarding.hasCompleted) {
      return RouteNames.onboarding;
    }

    await location.restore();

    if (!location.isChosen) {
      if (location.governatesLanguage != languageCode) {
        await location.loadGovernates(lang: languageCode);
      }
      return RouteNames.locationScope;
    }

    stores.setArea(location.area!.id);
    await order.ready;
    if (order.checkoutActive) {
      return RouteNames.checkout;
    }
    return RouteNames.main;
  }
}
