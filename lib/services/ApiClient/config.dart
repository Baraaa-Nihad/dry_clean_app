import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get _defaultApiUrl =>
      defaultTargetPlatform == TargetPlatform.android
          ? 'http://127.0.0.1:3000/'
          : 'http://localhost:3000/';

  static String get apiUrl => dotenv.env['API_BASE_URL'] ?? _defaultApiUrl;

  static String get apiKeyPath =>
      dotenv.env['API_KEY_PATH'] ?? 'api/v1/private/';
  static String get apiKeyPathNoPrivate =>
      dotenv.env['API_KEY_PATH_NO_PRIVATE'] ?? 'api/v1/';

  static String get fullApiUrl => '$apiUrl$apiKeyPath';
  static String get fullApiUrlNoPrivate => '$apiUrl$apiKeyPathNoPrivate';

//APP APIS URLS
  static String get signInApi => '${fullApiUrl}userLogin/';
  static String get getUserApi => '${fullApiUrlNoPrivate}getUser/';

  static String get refreshTokenApi => '${fullApiUrl}refresh-token/';
  static String get getUserAddressApi =>
      '${fullApiUrlNoPrivate}users/getUserAddress/';
  static String get setDefaultAddressApi =>
      '${fullApiUrlNoPrivate}users/setDefaultAddress/';

  static String get updateUserAddressApi =>
      '${fullApiUrlNoPrivate}users/updateUserAddress/';

  static String get deleteAddressApi =>
      '${fullApiUrlNoPrivate}users/deleteAddress/';
  static String get sendUserMessageApi => '${fullApiUrlNoPrivate}users/sms/';
  static String get OtpApi => '${fullApiUrlNoPrivate}users/otp/send-otp';
  static String get ResendOtpApi =>
      '${fullApiUrlNoPrivate}users/otp/resend-otp';
  static String get verifyUserOtpApi =>
      '${fullApiUrlNoPrivate}users/otp/verify-otp';
  static String get resetPasswordApi => '${fullApiUrl}reset-passowrd';
  static String get CheckMobileApi =>
      '${fullApiUrlNoPrivate}users/otp/check-mobile';
  static String get CheckUserApi =>
      '${fullApiUrlNoPrivate}users/otp/check-user';
  static String get checkAttemptsApi =>
      '${fullApiUrlNoPrivate}users/otp/check-registration-attempts';
  static String get registerApi => '${fullApiUrl}register';
  static String get fetchAreas => '${fullApiUrlNoPrivate}fetchAreas';
  static String get createOrder => '${fullApiUrl}place-order';
  static String get getOrder => '${fullApiUrl}orders';

  static String get fetchProductsByServiceTypeID =>
      '${fullApiUrlNoPrivate}groupsWithProductsAndServices';
  static String get fetchDryCleanDetails => '${fullApiUrl}dryCleanDetails';
  static String get getDeliveryTimesApi => '${fullApiUrl}getDeliveryTimes';

  static String get updateUserNameApi => '${fullApiUrlNoPrivate}editUserName/';
  static String get updateUserEmailApi =>
      '${fullApiUrlNoPrivate}editUserEmail/';
  static String get getGovernatesApi => '${fullApiUrlNoPrivate}getGovernates/';
  static String get addAddressApi => '${fullApiUrlNoPrivate}users/addAddress/';
  static String get getAddressNamesApi =>
      '${fullApiUrlNoPrivate}getAddressNames/';
  static String get changePasswordApi => '${fullApiUrl}change-password';

  static String get getOrdersApi => '${fullApiUrlNoPrivate}users/UserOrders';
  static String get getOrderItemsApi => '${fullApiUrl}orders/items';
  static String get sendFeedbackApi => '${fullApiUrl}feedback/submit';
  static String get sendContactApi => '${fullApiUrl}contact/submit';
  static String get deviceRegistration => '${fullApiUrl}device/register';
  static String get deviceUnregistration => '${fullApiUrl}device/unregister';
  static String get getBanners => '${fullApiUrl}banners/getAll';
  static String get getOnboardingApi => '${fullApiUrlNoPrivate}app/onboarding';

  // Add the Change Password API endpoint

  static String get _placeholderUrl => 'assets/images/placeholder.jpg';

  static String resolveImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return _placeholderUrl;

    if (!imagePath.startsWith('http')) return imagePath;
    try {
      final serverUri = Uri.parse(apiUrl);
      final imageUri = Uri.parse(imagePath);
      final imgHost = imageUri.host;
      final serverHost = serverUri.host;

      // Old Firebase Storage URLs return 402 in production. The app is now
      // deployed with backend/webhosting uploads, so use the bundled fallback.
      if (imgHost == 'firebasestorage.googleapis.com' ||
          imgHost == 'firebasestorage.app') {
        return _placeholderUrl;
      }

      // Only rewrite URLs that point to the backend server itself
      // (same host, localhost, or a raw IP address).
      // Leave other external URLs (CDNs, etc.) untouched.
      final isBackendUrl = imgHost == serverHost ||
          imgHost == 'localhost' ||
          imgHost == '127.0.0.1' ||
          RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(imgHost);

      if (!isBackendUrl) return imagePath;

      return imageUri
          .replace(
            scheme: serverUri.scheme,
            host: serverUri.host,
            port: serverUri.port,
          )
          .toString();
    } catch (_) {
      return _placeholderUrl;
    }
  }

  static void printConfig() {
    print('API Base URL: $apiUrl');
    print('API Key Path: $apiKeyPath');
    print('Full API URL: $fullApiUrl');
    print('Sign In API: $signInApi');
    print('Refresh Token API: $refreshTokenApi');
  }
}
