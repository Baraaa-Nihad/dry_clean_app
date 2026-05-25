// lib/utils/route_generator.dart

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/screens/BasketPage/basket_page.dart';
import 'package:saleem_dry_clean/screens/Checkout/Checkout.dart';
import 'package:saleem_dry_clean/screens/DecisionScreen.dart';
import 'package:saleem_dry_clean/screens/ErrorPage/ErrorPage.dart';
import 'package:saleem_dry_clean/screens/HomeScreen/home_screen.dart';
import 'package:saleem_dry_clean/screens/MorePage/more_page.dart';
import 'package:saleem_dry_clean/screens/NotificationPage/notificationPage.dart';
import 'package:saleem_dry_clean/screens/Onboarding/onboarding_screen.dart';
import 'package:saleem_dry_clean/screens/OrdersPage/OrderBasketDetails.dart';
import 'package:saleem_dry_clean/screens/OrdersPage/orders_page.dart';
import 'package:saleem_dry_clean/screens/Receipt/OrderReceiptPage.dart';
import 'package:saleem_dry_clean/screens/ServicePage/ServicePage.dart';
import 'package:saleem_dry_clean/screens/SignInPage/SignIn.dart';
import 'package:saleem_dry_clean/screens/main_navigation.dart';
import 'package:saleem_dry_clean/screens/splashScreen/splash_screen.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:saleem_dry_clean/utils/fade_route.dart'; // Ensure FadeRoute is correctly implemented

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final TokenService tokenService = TokenService();

    switch (settings.name) {
      case RouteNames.main:
        return MaterialPageRoute(builder: (_) => MainNavigation());
      case RouteNames.decision:
        return FadeRoute(page: DecisionScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => HomeScreen(fem: 1));
      case RouteNames.basket:
        return MaterialPageRoute(builder: (_) => BasketPage(fem: 1));
      case RouteNames.orders:
        return MaterialPageRoute(builder: (_) => OrdersPage(fem: 1));
      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => NotificationPage(fem: 1));
      case RouteNames.more:
        return MaterialPageRoute(builder: (_) => MorePage(fem: 1));
      case RouteNames.onboarding:
        return FadeRoute(page: OnboardingScreen());
      case RouteNames.signIn:
        return MaterialPageRoute(builder: (_) => SignIn(fem: 1));
      case RouteNames.checkout:
        return MaterialPageRoute(builder: (_) => CheckoutAddress(fem: 1));
      case RouteNames.splash:
        return FadeRoute(page: SplashScreen());

      // Handle OrderReceiptPage
      case RouteNames.receipt:
        if (args is Map<String, dynamic> && args.containsKey('orderId')) {
          return MaterialPageRoute(
            builder: (_) => OrderReceiptPage(
              orderId: args['orderId'],
              tokenService: tokenService,
            ),
          );
        } else if (args is Map<String, dynamic> && args.containsKey('order')) {
          return MaterialPageRoute(
            builder: (_) => OrderReceiptPage(
              order: args['order'],
              tokenService: tokenService,
            ),
          );
        }
        return _errorRoute('Invalid arguments for OrderReceiptPage');

      // Handle OrderBasketDetails
      case RouteNames.BasketDetails:
        if (args is Map<String, dynamic> && args.containsKey('order')) {
          return MaterialPageRoute(
            builder: (_) => OrderBasketDetails(
              order: args['order'],
            ),
          );
        }
        return _errorRoute('Invalid arguments for OrderBasketDetails');

      // Handle ServicePage
      case RouteNames.service:
        if (args is Map<String, dynamic>) {
          final requiredKeys = [
            'serviceName',
            'generalUnit',
            'pricePerUnit',
            'serviceTypeId',
          ];
          for (var key in requiredKeys) {
            if (!args.containsKey(key)) {
              return _errorRoute('Missing "$key" argument for ServicePage');
            }
          }
          return MaterialPageRoute(
            builder: (_) => ServicePage(
              serviceName: args['serviceName'],
              generalUnit: args['generalUnit'],
              pricePerUnit: args['pricePerUnit'],
              serviceTypeId: args['serviceTypeId'],
            ),
          );
        }
        return _errorRoute('Invalid arguments for ServicePage');

      // Handle ErrorPage
      case RouteNames.error:
        if (args is Map<String, dynamic> && args.containsKey('errorMessage')) {
          return FadeRoute(
            page: ErrorPage(
              errorMessage: args['errorMessage'],
            ),
          );
        }
        return FadeRoute(
          page: ErrorPage(
            errorMessage: "",
          ),
        );

      // Add more cases for additional routes

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    print('Error: $message'); // Optional: Log the error
    return FadeRoute(
      page: ErrorPage(
        errorMessage: message, // Pass the error message to ErrorPage
      ),
    );
  }
}
