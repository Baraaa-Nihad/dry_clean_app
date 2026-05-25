import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print("Request: ${data.method} ${data.url}");
    print("Headers: ${data.headers}");
    print("Body: ${data.body}");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print("Response: ${data.statusCode}");
    print("Headers: ${data.headers}");
    print("Body: ${data.body}");
    return data;
  }
}
