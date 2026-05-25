// lib/utils/app_version_helper.dart

import 'package:package_info_plus/package_info_plus.dart';

/// A utility class to fetch application version details.
class AppVersionHelper {
  /// Retrieves the current app version.
  ///
  /// Returns a [Future] that resolves to the app version as a [String].
  /// If unable to fetch the version, it returns 'Unknown'.
  static Future<String> getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version; // e.g., "1.0.0"
    } catch (e) {
      print('Failed to get app version: $e');
      return 'Unknown';
    }
  }

  /// Retrieves the build number of the app.
  ///
  /// Returns a [Future] that resolves to the build number as a [String].
  /// If unable to fetch the build number, it returns 'Unknown'.
  static Future<String> getBuildNumber() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber; // e.g., "100"
    } catch (e) {
      print('Failed to get build number: $e');
      return 'Unknown';
    }
  }

  /// Retrieves the app name.
  ///
  /// Returns a [Future] that resolves to the app name as a [String].
  /// If unable to fetch the app name, it returns 'Unknown'.
  static Future<String> getAppName() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.appName; // e.g., "Saleem Dry Clean"
    } catch (e) {
      print('Failed to get app name: $e');
      return 'Unknown';
    }
  }

  /// Retrieves the package name.
  ///
  /// Returns a [Future] that resolves to the package name as a [String].
  /// If unable to fetch the package name, it returns 'Unknown'.
  static Future<String> getPackageName() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.packageName; // e.g., "com.example.saleemdryclean"
    } catch (e) {
      print('Failed to get package name: $e');
      return 'Unknown';
    }
  }
}
