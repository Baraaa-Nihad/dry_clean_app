// lib/screens/SignIn.dart

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/DividerWithText.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/ForgetPasswordModal.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/MobileNumberInput.dart'
    as Mobile;
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart'
    as TextInput;
import 'package:saleem_dry_clean/screens/SignUpPage/SignUp.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/NoSwipeBackPageRoute.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:saleem_dry_clean/utils/app_version_helper.dart'; // Import the app version helper

class SignIn extends StatefulWidget {
  final double fem;

  SignIn({
    required this.fem,
  });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  String _selectedCountryCode = '+970';
  bool _isPasswordVisible = false;
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool enableValidation = false;
  String _errorMessage = '';

  // Pre-fetched while the user is filling in the form — removes these calls
  // from the critical path so pressing Login is instant.
  late final Future<String?> _fcmTokenFuture;
  late final Future<Map<String, String>> _deviceInfoFuture;

  @override
  void initState() {
    super.initState();
    _setTransparentStatusBar();
    _mobileNumberController.addListener(() => _onInputChange(true));
    _passwordController.addListener(() => _onInputChange(true));
    // Start fetching in the background immediately — by the time the user
    // finishes typing and hits Login these will already be resolved.
    _fcmTokenFuture = FirebaseMessaging.instance.getToken();
    _deviceInfoFuture = _fetchDeviceInfo();
  }

  Future<Map<String, String>> _fetchDeviceInfo() async {
    String deviceType, osVersion, model;
    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      deviceType = 'Android';
      osVersion = info.version.release;
      model = info.model;
    } else if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;
      deviceType = 'iOS';
      osVersion = info.systemVersion;
      model = info.utsname.machine;
    } else {
      deviceType = 'Unknown';
      osVersion = 'Unknown';
      model = 'Unknown';
    }
    final appVersion = await AppVersionHelper.getAppVersion();
    return {
      'deviceType': deviceType,
      'osVersion': osVersion,
      'model': model,
      'appVersion': appVersion,
    };
  }

  void _setTransparentStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _onCountryCodeChanged(String code) {
    setState(() {
      _selectedCountryCode = code;
      _updateButtonState();
    });
  }

  void _onInputChange(bool isValid) {
    _updateButtonState();
  }

  void _updateButtonState() {
    bool isMobileNumberValid = enableValidation
        ? ValidationUtils.validateInput(_mobileNumberController.text, true)
        : _mobileNumberController.text.isNotEmpty;

    bool isPasswordValid = _passwordController.text.length >= 8;

    setState(() {
      _isButtonEnabled = isMobileNumberValid && isPasswordValid;
    });
  }

  void _unfocusAll() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleSignIn() async {
    if (!_isButtonEnabled) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Both futures were started in initState — await them together so
      // if either is still in-flight they finish in parallel, not sequentially.
      final results = await Future.wait([_fcmTokenFuture, _deviceInfoFuture]);
      final deviceToken = results[0] as String?;
      final deviceInfo = results[1] as Map<String, String>;

      if (deviceToken == null) {
        throw Exception('Failed to retrieve device token');
      }

      await userProvider.signIn(
        selectedCountryCode: _selectedCountryCode,
        phoneNumber: _mobileNumberController.text,
        password: _passwordController.text,
        context: context,
        deviceToken: deviceToken,
        deviceType: deviceInfo['deviceType']!,
        osVersion: deviceInfo['osVersion']!,
        model: deviceInfo['model']!,
        appVersion: deviceInfo['appVersion']!,
      );

      NavigatorService.navigateTo(RouteNames.main);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = AppLocalizations.of(context)
                ?.translate('password_or_mobile_incorrect') ??
            'Password or mobile number is incorrect';
      });
    }
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: _unfocusAll,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w, // Use ScreenUtil
                        vertical: 24.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 92.h), // Use ScreenUtil
                          Text(
                            localizations?.translate('sign_in') ?? 'Sign In',
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.bold16Gray80(context).copyWith(
                                fontSize: 24.sp, // Use ScreenUtil
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            localizations?.translate('welcome_back') ??
                                'Welcome back! Sign in to your account to access\n all our services',
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.regular16Gray50(context).copyWith(
                                fontSize: 13.sp,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 40.h),
                          Mobile.MobileNumberInput(
                            fem: 1,
                            controller: _mobileNumberController,
                            focusNode: _mobileFocusNode,
                            hasError: _hasError,
                            enableValidation: false,
                            labelTextPrimary:
                                localizations?.translate('mobile_number') ??
                                    'Mobile Number',
                            countryCodes: ['+970', '+972'],
                            onCountryCodeChanged: _onCountryCodeChanged,
                            onInputChange: _onInputChange,
                            isRtl: isRtl,
                          ),
                          SizedBox(height: 16.h),
                          TextInput.TextCustomInput(
                            fem: 1,
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            hasError: _hasError,
                            labelTextPrimary:
                                localizations?.translate('password') ??
                                    'Password',
                            inputType: _isPasswordVisible
                                ? TextInput.InputType.text
                                : TextInput.InputType.password,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              child: SvgPicture.asset(
                                _isPasswordVisible
                                    ? 'assets/vectors/textPassword.svg'
                                    : 'assets/vectors/showPassword.svg',
                                width: 24.w,
                                height: 24.h,
                              ),
                            ),
                            onInputChange: _onInputChange,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations
                                        ?.translate('enter_password') ??
                                    'Please enter a password';
                              } else if (value.length < 8) {
                                return localizations
                                        ?.translate('password_length') ??
                                    'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8.h),
                          if (_hasError)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _errorMessage,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular14RedW500(context)
                                      .copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            child: LoadingButton(
                              fem: 1,
                              isLoading: _isLoading,
                              buttonText: localizations?.translate('log_in') ??
                                  'Log in',
                              onPressed:
                                  _isButtonEnabled ? _handleSignIn : null,
                              isDisabled: !_isButtonEnabled,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          GestureDetector(
                            onTap: () {
                              BlankModal.show(
                                context,
                                /* fem */ 1.0, // Adjust as necessary or remove
                                ForgetPasswordModal(fem: 1.0),
                              );
                            },
                            child: Text(
                              localizations?.translate('forget_password') ??
                                  'Forget password?',
                              style: AppTextStyles.getFontFamily(
                                context,
                                AppTextStyles.bold16Gray80(context).copyWith(
                                  fontSize: 16.sp,
                                  color: AppColors.gray60,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 200.h),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 60.h,
                        left: 24.w,
                        right: 24.w,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DividerWithText(
                            text:
                                localizations?.translate('dont_have_account') ??
                                    'Don\'t have an account?',
                            fem: 1.0, // Adjust or remove fem
                          ),
                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.only(bottom: 60.h),
                            child: SecondaryButton(
                              fem: 1,
                              text: localizations?.translate('signup') ??
                                  'Sign up',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  NoSwipeBackPageRoute(
                                    builder: (context) => SignUp(
                                      fem: 1,
                                      setLocale: languageProvider.setLocale,
                                      currentLocale: languageProvider.locale,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -245.h,
              right: -161.w,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 428.w,
                  height: 428.h,
                  decoration: ShapeDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [AppColors.green, AppColors.blue.withOpacity(0)],
                      stops: [0.5, 1.0],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -20.h,
              left: -20.w,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 104.w,
                  height: 104.h,
                  decoration: ShapeDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [AppColors.green, AppColors.blue.withOpacity(0)],
                      stops: [0.5, 1.0],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
