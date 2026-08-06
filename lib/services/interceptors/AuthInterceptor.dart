import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

class _Tokens {
  const _Tokens(this.accessToken, this.refreshToken);
  final String accessToken;
  final String refreshToken;
}

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
      // ★ لا ترويسة أصلاً للزائر ★
      //
      // كان يُرسَل `Bearer <معرّف الجهاز>` — نصّ ليس توكناً. والخادم
      // يحاول التحقّق منه فيردّ 401 مع `logout: true`، أي أن الزائر
      // يُطرد من جلسة لم يبدأها. والمسارات العامة كانت تُرفض هي الأخرى
      // لأن الترويسة موجودة وفاسدة.
      //
      // ومعرّف الجهاز يُرسَل في ترويسته الخاصة لمن يحتاجه.
      data.headers.remove("Authorization");
      data.headers["X-Device-Id"] = await _getCachedDeviceId();
    }

    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode == 401) {
      final refreshToken = await tokenService.getRefreshToken();
      if (refreshToken != null) {
        final renewed = await _refreshTokens(refreshToken);
        if (renewed != null) {
          final newAccessToken = renewed.accessToken;
          // ★ التوكن المدوَّر يُحفظ ★
          //
          // كان يُحفظ التوكن القديم مع الوصول الجديد. والخادم يُبطل
          // توكن التجديد فور استعماله (تدوير)، فالتجديد التالي يفشل
          // دائماً — تنجح مرّة واحدة ثم يُطرد المستخدم.
          await tokenService.saveTokens(newAccessToken, renewed.refreshToken);

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

  /// تجديد التوكنين.
  ///
  /// ★ ثلاثة أعطال كانت هنا ★
  ///
  /// المسار كان `${Config.apiUrl}/refresh-token` — وapiUrl ينتهي بشرطة
  /// مائلة، فالناتج `//refresh-token` على جذر الخادم لا تحت
  /// `/api/v1/private`. أي أن التجديد لم يقع مرّة واحدة منذ كُتب.
  ///
  /// والقراءة كانت `data['accessToken']` والخادم يردّ
  /// `{tokens: {accessToken, refreshToken}}` — فحتى لو صحّ المسار لعاد
  /// null.
  ///
  /// والثالث أعلاه: التوكن المدوَّر كان يُهمَل.
  Future<_Tokens?> _refreshTokens(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(Config.refreshTokenApi),
        body: jsonEncode({'refreshToken': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      final tokens = body is Map ? body['tokens'] : null;
      if (tokens is! Map) return null;

      final access = tokens['accessToken'];
      if (access is! String || access.isEmpty) return null;

      final refreshed = tokens['refreshToken'];
      return _Tokens(
        access,
        // الخادم قد لا يدوّر التوكن في كل ردّ — عندها يبقى القديم صالحاً
        refreshed is String && refreshed.isNotEmpty ? refreshed : refreshToken,
      );
    } catch (_) {
      // انقطاع الشبكة أثناء التجديد ليس انتهاء جلسة: نعيد null فيبقى
      // الردّ 401 كما هو، ولا نمحو توكناً ما زال صالحاً
      return null;
    }
  }

  Future<String> _getDeviceMacAddress() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // id غير قابل للعدم في هذا الإصدار — `?? "guest"` كان شيفرة ميتة
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "guest";
    } else {
      return "guest";
    }
  }
}
