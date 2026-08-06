import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

/// كتالوج محل واحد بأسعاره هو.
///
/// ★ ما الذي تغيّر عن ServiceTypeProvider ★
///
/// ذاك ينادي groupsWithProductsAndServices بلا معرّف محل، فيردّ كتالوج
/// المنصّة بسعر واحد لكل صنف. وهذا كان صحيحاً حين كانت سليم هي من تغسل.
///
/// وهذا ينادي /customer/drycleans/:id/products فيردّ ما سعّره هذا المحل
/// وحده: منتج لم يسعّره لا يظهر أصلاً — محل لا يغسل سجاداً لا يعرض
/// سجاداً، بدل أن يعرضه ثم يرفض الطلب عند الدفع.
class StoreCatalogProvider with ChangeNotifier {
  StoreCatalogProvider(TokenService tokenService)
      : _client = ApiClient.createClient(tokenService);

  final http.Client _client;

  int? _storeId;
  List<StoreService> _services = [];
  bool _isLoading = false;
  String? _error;

  int? _selectedServiceId;
  String _search = '';

  int? get storeId => _storeId;
  List<StoreService> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  int? get selectedServiceId => _selectedServiceId;

  /// الخدمة المعروضة الآن — أول خدمة ما لم يختر الزبون غيرها.
  StoreService? get selectedService {
    if (_services.isEmpty) return null;
    for (final s in _services) {
      if (s.serviceId == _selectedServiceId) return s;
    }
    return _services.first;
  }

  /// أصناف الخدمة المختارة بعد البحث، مجمّعة بالمجموعة.
  ///
  /// البحث محلي: الكتالوج محمَّل كاملاً في الذاكرة، ونداء الخادم عند كل
  /// حرف يجعل الكتابة متقطّعة على شبكة بطيئة.
  Map<String, List<StoreProduct>> get visibleGroups {
    final svc = selectedService;
    if (svc == null) return const {};

    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return svc.byGroup;

    final map = <String, List<StoreProduct>>{};
    for (final entry in svc.byGroup.entries) {
      final hits =
          entry.value.where((p) => p.name.toLowerCase().contains(q)).toList();
      if (hits.isNotEmpty) map[entry.key] = hits;
    }
    return map;
  }

  bool get isEmptyAfterSearch =>
      !_isLoading && _error == null && visibleGroups.isEmpty;

  void selectService(int serviceId) {
    if (_selectedServiceId == serviceId) return;
    _selectedServiceId = serviceId;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> load(int storeId, {String lang = 'ar', bool force = false}) async {
    // نفس المحل ومحمَّل: لا نعيد النداء عند كل دخول للشاشة
    if (!force && _storeId == storeId && _services.isNotEmpty) return;

    // محل مختلف: نُفرغ القديم فوراً كي لا تُعرض أسعار محل تحت اسم آخر
    if (_storeId != storeId) {
      _services = [];
      _selectedServiceId = null;
      _search = '';
    }

    _storeId = storeId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('${Config.storeDetailsApi}/$storeId/products')
          .replace(queryParameters: {'lang': lang});

      final res = await _client.get(uri);
      if (res.statusCode != 200) {
        _error = 'تعذّر جلب أصناف المغسلة';
        return;
      }

      final body = jsonDecode(res.body);
      final raw = (body is Map ? body['services'] : null) as List? ?? const [];
      _services = raw
          .map((e) => StoreService.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      _selectedServiceId ??=
          _services.isEmpty ? null : _services.first.serviceId;
    } catch (_) {
      _error = 'تعذّر الاتصال بالخادم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _storeId = null;
    _services = [];
    _selectedServiceId = null;
    _search = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
