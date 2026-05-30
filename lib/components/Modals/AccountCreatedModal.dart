// lib/components/Modals/AccountCreatedModal.dart

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/app_version_helper.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class AccountCreatedModal extends StatefulWidget {
  final Map<String, dynamic> responseData;

  const AccountCreatedModal({
    Key? key,
    required this.responseData,
  }) : super(key: key);

  static void show(
    BuildContext context,
    Map<String, dynamic> responseData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Prevent swipe down to dismiss
      enableDrag: false, // Disable dragging the modal down
      builder: (context) => AccountCreatedModal(
        responseData: responseData,
      ),
    );
  }

  @override
  _AccountCreatedModalState createState() => _AccountCreatedModalState();
}

class _AccountCreatedModalState extends State<AccountCreatedModal> {
  bool _isLoading = false;

  // Future<void> _handleStart(BuildContext context) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   final tokens = widget.responseData['tokens'];
  //   final userJson = widget.responseData['user'];
  //   final String? accessToken = tokens?['accessToken'];
  //   final String? refreshToken = tokens?['refreshToken'];
  //
  //   if (accessToken == null || refreshToken == null) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     // Handle the error, show a message to the user, etc.
  //     return;
  //   }
  //
  //   // Save tokens using TokenService
  //   final TokenService tokenService = TokenService();
  //   await tokenService.saveTokens(accessToken, refreshToken);
  //
  //   // Retrieve user credentials from session storage
  //   final _secureStorage = FlutterSecureStorage();
  //   final String? phoneNumber = await _secureStorage.read(key: 'phoneNumber');
  //   final String? password = await _secureStorage.read(key: 'password');
  //   final String? role = await _secureStorage.read(key: 'role');
  //   print(phoneNumber);
  //   print(password);
  //   print(role);
  //
  //   if (phoneNumber == null || password == null || role == null) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     // Handle the error, show a message to the user, etc.
  //     return;
  //   }
  //
  //   // Get the device token from Firebase Messaging
  //   String? deviceToken = await FirebaseMessaging.instance.getToken();
  //   if (deviceToken == null) {
  //     print("Error fetching device token");
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return;
  //   }
  //
  //   // Retrieve device information
  //   String deviceType;
  //   String osVersion;
  //   String model;
  //
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
  //     deviceType = 'Android';
  //     osVersion = androidInfo.version.release ?? 'Unknown';
  //     model = androidInfo.model ?? 'Unknown';
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
  //     deviceType = 'iOS';
  //     osVersion = iosInfo.systemVersion ?? 'Unknown';
  //     model = iosInfo.utsname.machine ?? 'Unknown';
  //   } else {
  //     deviceType = 'Unknown';
  //     osVersion = 'Unknown';
  //     model = 'Unknown';
  //   }
  //
  //   // Fetch app version
  //   String appVersion = await AppVersionHelper.getAppVersion();
  //
  //   // Sign in the user
  //   final user = User.fromJson(userJson);
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);
  //   await userProvider.signIn(
  //     selectedCountryCode: '',
  //     phoneNumber: phoneNumber,
  //     password: password,
  //     context: context,
  //     deviceToken: deviceToken, // Pass the device token
  //     deviceType: deviceType, // Or 'ios' based on your app platform
  //     osVersion: osVersion,
  //     model: model,
  //     appVersion: appVersion,
  //   );
  //
  //   // Navigate to home page after saving tokens
  //   Future.delayed(Duration(seconds: 1), () {
  //     Navigator.pop(context); // Close the modal
  //
  //     NavigatorService.navigateTo(RouteNames.main);
  //   });
  //
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  Future<void> _handleStart(BuildContext context) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Capture context-dependent objects before any awaits
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final tokens = widget.responseData['tokens'];
    final userJson = widget.responseData['user'];
    final String? accessToken = tokens?['accessToken'];
    final String? refreshToken = tokens?['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Save tokens
    final TokenService tokenService = TokenService();
    await tokenService.saveTokens(accessToken, refreshToken);

    // Retrieve user credentials
    final _secureStorage = FlutterSecureStorage();
    final String? phoneNumber = await _secureStorage.read(key: 'phoneNumber');
    final String? password = await _secureStorage.read(key: 'password');
    final String? role = await _secureStorage.read(key: 'role');
    print(phoneNumber);
    print(password);
    print(role);

    if (phoneNumber == null || password == null || role == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Get FCM device token with timeout fallback (works on both simulator and real device)
    String deviceToken;
    try {
      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 10));
      deviceToken = token ?? 'no-token';
    } catch (_) {
      print("FCM getToken() failed — using fallback token");
      deviceToken = 'no-token';
    }
    print("Device token: $deviceToken");

    // Retrieve device information
    String deviceType;
    String osVersion;
    String model;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceType = 'android';
      osVersion = androidInfo.version.release ?? 'Unknown';
      model = androidInfo.model ?? 'Unknown';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceType = 'ios';
      osVersion = iosInfo.systemVersion ?? 'Unknown';
      model = iosInfo.utsname.machine ?? 'Unknown';
    } else {
      deviceType = 'unknown';
      osVersion = 'unknown';
      model = 'unknown';
    }

    // Fetch app version
    String appVersion = await AppVersionHelper.getAppVersion();

    // Sign in the user
    try {
      final user = User.fromJson(userJson);
      await userProvider.signIn(
        selectedCountryCode: '',
        phoneNumber: phoneNumber,
        password: password,
        context: context,
        deviceToken: deviceToken,
        deviceType: deviceType,
        osVersion: osVersion,
        model: model,
        appVersion: appVersion,
      );

      // Navigate to home
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pop(context);
        NavigatorService.navigateTo(RouteNames.main);
      });
    } catch (e) {
      print("signIn error: $e");
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 56,
        minHeight: MediaQuery.of(context).size.height - 56,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16.0),
                SvgPicture.asset(
                  'assets/vectors/success_icon.svg', // Replace with your success icon asset
                  width: 165.0,
                  height: 160.0,
                ),
                SizedBox(height: 24.0),
                Text(
                  localizations?.translate('account_created_success') ??
                      'Account created \nsuccessfully!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.bold16Gray80(context).copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  localizations?.translate('welcome_aboard_message') ??
                      'Welcome aboard! Your account has been successfully created. Let\'s make laundry hassle-free together!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray50(context).copyWith(
                      fontSize: 13.0,
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Container(
              width: double.infinity,
              child: LoadingButton(
                fem: 1,
                isLoading: _isLoading,
                buttonText: localizations?.translate('Start') ?? 'Start',
                onPressed: () {
                  _handleStart(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
