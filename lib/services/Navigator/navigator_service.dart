// lib/services/navigator_service.dart

import 'dart:async';

import 'package:flutter/material.dart';

class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _isNavigatorLockedError(Object error) {
    final errorText = error.toString();
    return errorText.contains('_debugLocked') ||
        errorText.contains('navigator._debugLocked');
  }

  static Future<dynamic>? _runAfterFrame(
    Future<dynamic>? Function(NavigatorState navigator) action,
  ) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      print('NavigatorService: Unable to navigate, navigatorKey is null');
      return null;
    }

    final completer = Completer<dynamic>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }

      try {
        action(navigator)?.then(
          completer.complete,
          onError: completer.completeError,
        );
      } catch (error, stackTrace) {
        if (_isNavigatorLockedError(error)) {
          print('NavigatorService: navigation skipped while navigator locked');
          if (!completer.isCompleted) completer.complete(null);
        } else if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });

    return completer.future;
  }

  static Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return _runAfterFrame(
        (navigator) => navigator.pushNamed(routeName, arguments: arguments),
      );
    }

    try {
      return navigator.pushNamed(routeName, arguments: arguments);
    } catch (error) {
      if (_isNavigatorLockedError(error)) {
        return _runAfterFrame(
          (navigator) => navigator.pushNamed(routeName, arguments: arguments),
        );
      }
      rethrow;
    }
  }

  static Future<dynamic>? navigateToAndRemoveUntil(String routeName,
      {Object? arguments}) {
    return _runAfterFrame(
      (navigator) => navigator.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      ),
    );
  }

  static void goBack() {
    navigatorKey.currentState?.pop();
  }

  static void replaceWith(String routeName, {Object? arguments}) {
    _runAfterFrame(
      (navigator) => navigator.pushReplacementNamed(
        routeName,
        arguments: arguments,
      ),
    );
  }
}
