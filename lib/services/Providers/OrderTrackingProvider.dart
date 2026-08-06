import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/OrderTracking.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

/// تتبّع الطلب والتقييم ومطالبات التلف.
///
/// ★ لماذا الثلاثة في مزوّد واحد ★
///
/// جميعها تدور حول طلب واحد بعد إنشائه، ويقرؤها المستعمل في الشاشة
/// نفسها: يفتح التتبّع، فإن كان مسلَّماً ظهر له التقييم وزرّ الإبلاغ عن
/// تلف. فصلها إلى ثلاثة مزوّدات يعني ثلاثة استدعاءات وثلاث حالات تحميل
/// لشاشة واحدة.
///
/// والحالة مفهرسة بمعرّف الطلب لا مفردة: شاشة الطلبات قد تفتح طلبين
/// بالتتابع، ومزوّد يحمل طلباً واحداً يعرض بيانات السابق لحظةَ فتح
/// التالي.
class OrderTrackingProvider with ChangeNotifier {
  OrderTrackingProvider(TokenService tokenService)
      : _client = ApiClient.createClient(tokenService);

  final http.Client _client;

  final Map<int, OrderTracking> _tracking = {};
  final Map<int, RatableOrder> _ratable = {};
  final Set<int> _loading = {};
  final Map<int, String> _errors = {};

  bool _submitting = false;

  OrderTracking? trackingOf(int orderId) => _tracking[orderId];
  RatableOrder? ratableOf(int orderId) => _ratable[orderId];
  bool isLoading(int orderId) => _loading.contains(orderId);
  String? errorOf(int orderId) => _errors[orderId];

  /// قيد الإرسال — يمنع تقييمين بضغطتين متتاليتين
  bool get isSubmitting => _submitting;

  /// جلب التتبّع وجهات التقييم معاً.
  ///
  /// النداءان متوازيان لا متتاليان: كلاهما مستقلّ، والتتابع يضاعف زمن
  /// فتح الشاشة على شبكة بطيئة.
  Future<void> load(int orderId, {String lang = 'ar', bool force = false}) async {
    if (_loading.contains(orderId)) return;
    if (!force && _tracking.containsKey(orderId)) return;

    _loading.add(orderId);
    _errors.remove(orderId);
    notifyListeners();

    try {
      final results = await Future.wait([
        _client.get(Uri.parse('${Config.orderTrackingApi}/$orderId/tracking')
            .replace(queryParameters: {'lang': lang})),
        _client.get(Uri.parse('${Config.ratableTargetsApi}/$orderId/ratable')),
      ]);

      final tRes = results[0];
      if (tRes.statusCode == 200) {
        final body = jsonDecode(tRes.body);
        final data = body is Map && body['data'] is Map ? body['data'] : body;
        _tracking[orderId] =
            OrderTracking.fromJson(Map<String, dynamic>.from(data as Map));
      } else if (tRes.statusCode == 404) {
        // الخادم يردّ 404 لا 403 على طلب ليس لك — إخفاء الوجود مقصود،
        // فلا نترجمها إلى «ممنوع»
        _errors[orderId] = 'الطلب غير موجود';
      } else {
        _errors[orderId] = 'تعذّر جلب حالة الطلب';
      }

      // التقييم إضافة على الشاشة لا شرط لها: فشله لا يمنع عرض التتبّع
      final rRes = results[1];
      if (rRes.statusCode == 200) {
        final body = jsonDecode(rRes.body);
        final data = body is Map && body['data'] is Map ? body['data'] : body;
        _ratable[orderId] =
            RatableOrder.fromJson(Map<String, dynamic>.from(data as Map));
      }
    } catch (_) {
      _errors[orderId] = 'تعذّر الاتصال بالخادم';
    } finally {
      _loading.remove(orderId);
      notifyListeners();
    }
  }

  /// إرسال تقييم لجهة واحدة.
  ///
  /// يعيد رسالة الخطأ أو null عند النجاح — الشاشة هي من تقرّر كيف تعرضها.
  Future<String?> submitRating({
    required int orderId,
    required String targetType,
    required int score,
    String? comment,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    notifyListeners();

    try {
      final res = await _client.post(
        Uri.parse('${Config.ratableTargetsApi}/$orderId/ratings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'targetType': targetType,
          'score': score,
          if ((comment ?? '').trim().isNotEmpty) 'comment': comment!.trim(),
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // إعادة الجلب لا التعديل محلياً: الخادم يمنع التقييم المكرّر،
        // وحالته هي الحقيقة
        await _reloadRatable(orderId);
        return null;
      }
      return _messageOf(res.body) ?? 'تعذّر إرسال التقييم';
    } catch (_) {
      return 'تعذّر الاتصال بالخادم';
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// رفع مطالبة تلف على صنف من الطلب.
  Future<String?> submitClaim({
    required int orderId,
    int? orderItemId,
    required String description,
    double? claimedAmount,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    notifyListeners();

    try {
      final res = await _client.post(
        Uri.parse(Config.damageClaimsApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          if (orderItemId != null) 'orderItemId': orderItemId,
          'description': description.trim(),
          if (claimedAmount != null) 'claimedAmount': claimedAmount,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) return null;
      return _messageOf(res.body) ?? 'تعذّر رفع المطالبة';
    } catch (_) {
      return 'تعذّر الاتصال بالخادم';
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> _reloadRatable(int orderId) async {
    try {
      final res = await _client
          .get(Uri.parse('${Config.ratableTargetsApi}/$orderId/ratable'));
      if (res.statusCode != 200) return;
      final body = jsonDecode(res.body);
      final data = body is Map && body['data'] is Map ? body['data'] : body;
      _ratable[orderId] =
          RatableOrder.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      // فشل التحديث لا يُبطل تقييماً وصل — الشاشة تُحدَّث عند فتحها تالياً
    }
  }

  /// رسالة الخادم العربية أفضل من رسالة عامة: «تقييمك مسجّل مسبقاً»
  /// تشرح للزبون ما حدث، و«تعذّر الإرسال» تجعله يعيد المحاولة بلا طائل.
  String? _messageOf(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map && j['message'] is String) return j['message'] as String;
    } catch (_) {}
    return null;
  }
}
