import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خيار موقع — محافظة أو منطقة. كلاهما رقم واسم.
class LocationOption {
  const LocationOption(this.id, this.name);
  final int id;
  final String name;

  factory LocationOption.fromJson(Map<String, dynamic> j) => LocationOption(
        int.tryParse('${j['id']}') ?? 0,
        (j['name'] ?? '').toString(),
      );
}

/// نطاق الزبون: مدينته ومنطقته.
///
/// ★ لماذا يُحفظ محلياً لا في الحساب ★
///
/// الاختيار يقع **بعد الأونبوردينج وقبل التسجيل** (٢.١) — لا حساب بعد
/// ليُحفظ فيه. والزبون قد يتصفّح المغاسل ويقارن الأسعار قبل أن يقرّر
/// التسجيل أصلاً، وإجباره على حساب ليرى مغاسل حيّه يفقده عند البوّابة.
///
/// وبعد التسجيل يبقى العنوان هو المرجع عند الطلب — هذا للتصفّح.
class LocationScopeProvider with ChangeNotifier {
  static const _kGovId = 'scope_governate_id';
  static const _kGovName = 'scope_governate_name';
  static const _kAreaId = 'scope_area_id';
  static const _kAreaName = 'scope_area_name';

  final http.Client _client = http.Client();

  LocationOption? _governate;
  LocationOption? _area;

  List<LocationOption> _governates = [];
  List<LocationOption> _areas = [];

  bool _isLoading = false;
  String? _error;
  bool _restored = false;

  LocationOption? get governate => _governate;
  LocationOption? get area => _area;
  List<LocationOption> get governates => _governates;
  List<LocationOption> get areas => _areas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// هل انتهى الزبون من الاختيار؟ المنطقة هي المعيار لا المحافظة:
  /// المغاسل تُرشَّح بالمنطقة، والمحافظة وحدها لا تكفي لعرض قائمة.
  bool get isChosen => _area != null;

  /// هل قُرئ المحفوظ من القرص بعد؟ الشاشة تنتظره كي لا تُظهر شاشة
  /// اختيار لمن اختار أمس.
  bool get isRestored => _restored;

  /// استرجاع الاختيار المحفوظ — يُنادى مرّة عند الإقلاع.
  Future<void> restore() async {
    if (_restored) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final gid = prefs.getInt(_kGovId);
      final aid = prefs.getInt(_kAreaId);
      if (gid != null) {
        _governate = LocationOption(gid, prefs.getString(_kGovName) ?? '');
      }
      if (aid != null) {
        _area = LocationOption(aid, prefs.getString(_kAreaName) ?? '');
      }
    } catch (_) {
      // قرص لا يُقرأ لا يمنع التطبيق: الزبون يختار من جديد
    } finally {
      _restored = true;
      notifyListeners();
    }
  }

  Future<void> loadGovernates({String lang = 'ar'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(Config.getGovernatesApi)
          .replace(queryParameters: {'lang': lang});
      final res = await _client.get(uri);

      if (res.statusCode != 200) {
        _error = 'تعذّر جلب المدن';
        return;
      }

      final body = jsonDecode(res.body);
      final list = (body is Map ? body['data'] : body) as List? ?? const [];
      _governates = list
          .map((e) => LocationOption.fromJson(Map<String, dynamic>.from(e as Map)))
          // المحافظة المعطَّلة لا تُعرض: اختيارها يقود إلى قائمة مناطق
          // فارغة بلا تفسير
          .where((g) => g.name.isNotEmpty)
          .toList();
    } catch (_) {
      _error = 'تعذّر الاتصال بالخادم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAreas(int governateId, {String lang = 'ar'}) async {
    _isLoading = true;
    _error = null;
    _areas = [];
    notifyListeners();

    try {
      final uri = Uri.parse(Config.fetchAreas).replace(queryParameters: {
        'governate_id': '$governateId',
        'language': lang,
      });
      final res = await _client.get(uri);

      if (res.statusCode != 200) {
        _error = 'تعذّر جلب المناطق';
        return;
      }

      final body = jsonDecode(res.body);
      final list = (body is Map ? body['data'] : body) as List? ?? const [];
      _areas = list
          .map((e) => LocationOption.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      _error = 'تعذّر الاتصال بالخادم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// اختيار المحافظة يُبطل المنطقة السابقة.
  ///
  /// منطقة من رام الله تحت محافظة الخليل تُنتج قائمة مغاسل لا تخدم
  /// الزبون، وهو لا يرى الخطأ لأن اسم المنطقة وحده معروض.
  Future<void> selectGovernate(LocationOption g) async {
    _governate = g;
    _area = null;
    notifyListeners();
    await _persist();
    await loadAreas(g.id);
  }

  Future<void> selectArea(LocationOption a) async {
    _area = a;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_governate == null) {
        await prefs.remove(_kGovId);
        await prefs.remove(_kGovName);
      } else {
        await prefs.setInt(_kGovId, _governate!.id);
        await prefs.setString(_kGovName, _governate!.name);
      }
      if (_area == null) {
        await prefs.remove(_kAreaId);
        await prefs.remove(_kAreaName);
      } else {
        await prefs.setInt(_kAreaId, _area!.id);
        await prefs.setString(_kAreaName, _area!.name);
      }
    } catch (_) {
      // الحفظ يفشل ⇐ يُعاد السؤال في الجلسة القادمة، لا أكثر
    }
  }
}
