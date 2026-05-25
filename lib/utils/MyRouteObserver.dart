// lib/utils/my_route_observer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart'; // Import the navigator key

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _updateCurrentRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _updateCurrentRoute(previousRoute);
  }

  void _updateCurrentRoute(Route? route) {
    if (route is PageRoute) {
      String routeName = route.settings.name ?? '/';
      if (navigatorKey.currentContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<NavigationProvider>(navigatorKey.currentContext!,
                  listen: false)
              .updateCurrentRoute(routeName);
        });
      }
    }
  }
}
