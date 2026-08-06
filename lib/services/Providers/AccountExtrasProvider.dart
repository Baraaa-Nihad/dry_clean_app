import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

/// تقييم سابق للزبون.
class MyRating {
  const MyRating({
    required this.orderId,
    required this.target,
    required this.score,
    this.targetName,
    this.comment,
    this.at,
  });

  final int orderId;

  /// `dryclean` أو `driver_pickup` أو `driver_delivery`
  final String target;
  final String? targetName;
  final int score;
  final String? comment;
  final DateTime? at;

  /// اسم الجهة كما يقرؤه الزبون. اسم المحل يأتي من الخادم، والسائقان
  /// لا يأتيان باسم — عرض معرّفهما لا يفيد الزبون بشيء.
  String get label {
    if ((targetName ?? '').isNotEmpty) return targetName!;
    switch (target) {
      case 'driver_pickup':
        return 'سائق الاستلام';
      case 'driver_delivery':
        return 'سائق التوصيل';
      default:
        return 'المغسلة';
    }
  }

  factory MyRating.fromJson(Map<String, dynamic> j) => MyRating(
        orderId: int.tryParse('${j['orderId']}') ?? 0,
        target: (j['target'] ?? '').toString(),
        targetName: j['targetName'] as String?,
        score: int.tryParse('${j['score'] ?? 0}') ?? 0,
        comment: j['comment'] as String?,
        at: j['at'] == null ? null : DateTime.tryParse(j['at'].toString()),
      );
}

/// تفضيلات الإشعارات — ثلاثة مفاتيح معتمدة وقناتان.
class NotificationPrefs {
  const NotificationPrefs({
    this.orderUpdates = true,
    this.promotions = true,
    this.driverUpdates = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
  });

  final bool orderUpdates;
  final bool promotions;
  final bool driverUpdates;
  final bool pushEnabled;
  final bool smsEnabled;

  NotificationPrefs copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? driverUpdates,
    bool? pushEnabled,
    bool? smsEnabled,
  }) =>
      NotificationPrefs(
        orderUpdates: orderUpdates ?? this.orderUpdates,
        promotions: promotions ?? this.promotions,
        driverUpdates: driverUpdates ?? this.driverUpdates,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        smsEnabled: smsEnabled ?? this.smsEnabled,
      );

  Map<String, dynamic> toJson() => {
        'orderUpdates': orderUpdates,
        'promotions': promotions,
        'driverUpdates': driverUpdates,
        'pushEnabled': pushEnabled,
        'smsEnabled': smsEnabled,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic> j) =>
      NotificationPrefs(
        orderUpdates: j['orderUpdates'] != false,
        promotions: j['promotions'] != false,
        driverUpdates: j['driverUpdates'] != false,
        pushEnabled: j['pushEnabled'] != false,
        smsEnabled: j['smsEnabled'] == true,
      );
}

/// إضافات صفحة الحساب (٢.١.٨): سجلّ التقييمات وتفضيلات الإشعارات.
///
/// ★ لماذا معاً ★
///
/// كلاهما يخصّ الحساب لا الطلب، وكلاهما شاشة صغيرة تُفتح من More.
/// ومزوّدان لشاشتين بهذا الحجم تكلفة بلا مقابل.
///
/// والمفضّلة ليست هنا: قائمتها هي قائمة المغاسل نفسها مرشَّحة، وتعيش
/// في StoresProvider حيث حالة القلب محفوظة أصلاً.
class AccountExtrasProvider with ChangeNotifier {
  AccountExtrasProvider(TokenService tokenService)
      : _client = ApiClient.createClient(tokenService);

  final http.Client _client;

  List<MyRating> _ratings = [];
  bool _loadingRatings = false;
  String? _ratingsError;

  NotificationPrefs _prefs = const NotificationPrefs();
  bool _loadingPrefs = false;
  bool _savingPrefs = false;
  String? _prefsError;

  List<MyRating> get ratings => _ratings;
  bool get isLoadingRatings => _loadingRatings;
  String? get ratingsError => _ratingsError;

  NotificationPrefs get prefs => _prefs;
  bool get isLoadingPrefs => _loadingPrefs;
  bool get isSavingPrefs => _savingPrefs;
  String? get prefsError => _prefsError;

  Future<void> loadRatings({bool force = false}) async {
    if (_loadingRatings) return;
    if (_ratings.isNotEmpty && !force) return;

    _loadingRatings = true;
    _ratingsError = null;
    notifyListeners();

    try {
      final res = await _client.get(Uri.parse(Config.myRatingsApi));
      if (res.statusCode != 200) {
        _ratingsError = 'تعذّر جلب تقييماتك';
        return;
      }
      final body = jsonDecode(res.body);
      final list = (body is Map ? body['ratings'] : null) as List? ?? const [];
      _ratings = list
          .map((e) => MyRating.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      _ratingsError = 'تعذّر الاتصال بالخادم';
    } finally {
      _loadingRatings = false;
      notifyListeners();
    }
  }

  Future<void> loadPrefs({bool force = false}) async {
    if (_loadingPrefs) return;

    _loadingPrefs = true;
    _prefsError = null;
    notifyListeners();

    try {
      final res = await _client.get(Uri.parse(Config.notificationPrefsApi));
      if (res.statusCode != 200) {
        _prefsError = 'تعذّر جلب إعداداتك';
        return;
      }
      final body = jsonDecode(res.body);
      final data = body is Map && body['preferences'] is Map
          ? body['preferences']
          : body;
      _prefs = NotificationPrefs.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      _prefsError = 'تعذّر الاتصال بالخادم';
    } finally {
      _loadingPrefs = false;
      notifyListeners();
    }
  }

  /// تبديل مفتاح واحد — متفائل مع تراجع.
  ///
  /// انتظار الخادم قبل تحريك المفتاح يجعل الضغطة تبدو معطَّلة، والتراجع
  /// عند الفشل يمنع مفتاحاً يبدو مطفأً بينما الإشعارات تصل.
  Future<void> togglePref(String key, bool value) async {
    final previous = _prefs;

    switch (key) {
      case 'orderUpdates':
        _prefs = _prefs.copyWith(orderUpdates: value);
        break;
      case 'promotions':
        _prefs = _prefs.copyWith(promotions: value);
        break;
      case 'driverUpdates':
        _prefs = _prefs.copyWith(driverUpdates: value);
        break;
      case 'pushEnabled':
        _prefs = _prefs.copyWith(pushEnabled: value);
        break;
      case 'smsEnabled':
        _prefs = _prefs.copyWith(smsEnabled: value);
        break;
      default:
        return;
    }

    _savingPrefs = true;
    _prefsError = null;
    notifyListeners();

    try {
      final res = await _client.patch(
        Uri.parse(Config.notificationPrefsApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({key: value}),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _prefs = previous;
        _prefsError = 'تعذّر حفظ الإعداد';
      }
    } catch (_) {
      _prefs = previous;
      _prefsError = 'تعذّر الاتصال بالخادم';
    } finally {
      _savingPrefs = false;
      notifyListeners();
    }
  }
}
