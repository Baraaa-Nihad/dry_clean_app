import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

class AuthInterceptor implements InterceptorContract {
  final TokenService tokenService;

  AuthInterceptor(this.tokenService);

  // Cache device ID — querying native APIs on every request adds 100-500 ms.
  // The device ID never changes during an app session, so fetch once and reuse.
  String? _cachedDeviceId;
  Future<String> _getCachedDeviceId() async {
    _cachedDeviceId ??= await _getDeviceMacAddress();
    return _cachedDeviceId!;
  }

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    // Only read access token (one secure-storage read instead of two).
    // Refresh token is read lazily only when a 401 is received.
    final accessToken = await tokenService.getAccessToken();

    if (accessToken != null) {
      data.headers["Authorization"] = "Bearer $accessToken";
    } else {
      final deviceId = await _getCachedDeviceId();
      data.headers["Authorization"] = "Bearer $deviceId";
    }

    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode == 401) {
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final newAccessToken = await _refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await tokenService.saveTokens(newAccessToken, refreshToken);

          final retryRequest = data.request;
          if (retryRequest != null) {
            final updatedHeaders = {
              ...retryRequest.headers,
              "Authorization": "Bearer $newAccessToken"
            };

            final retryResponse = await http.Response.fromStream(
              await http.Client().send(
                http.Request(
                    retryRequest.method.toString(), Uri.parse(retryRequest.url))
                  ..headers.addAll(updatedHeaders)
                  ..body = retryRequest.body,
              ),
            );
            return ResponseData.fromHttpResponse(retryResponse);
          }
        }
      }
    }
    return data;
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/refresh-token'),
      body: jsonEncode({'refreshToken': refreshToken}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['accessToken'];
    } else {
      return null;
    }
  }

  Future<String> _getDeviceMacAddress() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? "guest";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "guest";
    } else {
      return "guest";
    }
  }
}
