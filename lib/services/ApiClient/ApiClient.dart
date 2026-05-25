import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/interceptors/AuthInterceptor.dart';

class ApiClient {
  static http.Client createClient(TokenService tokenService) {
    return InterceptedClient.build(
      interceptors: [AuthInterceptor(tokenService)],
      retryPolicy: ExpiredTokenRetryPolicy(),
    );
  }
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    return response.statusCode == 401;
  }
}
