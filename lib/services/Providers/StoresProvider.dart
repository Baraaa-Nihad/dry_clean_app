import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

/// ترتيب قائمة المحلات.
///
/// الافتراضي «موصى به» لا «الأقرب»: القرب وحده يضع محلاً بلا أصناف ولا
/// تقييم في الصدارة لأنه على الشارع المجاور. والترتيب الموصى به يوازن
/// بين التقييم وعدد الطلبات وتوفّر الأصناف.
enum StoreSort { recommended, rating, priceLow, nearest }

/// قائمة المحلات — الشاشة الأولى في نموذج الوسيط.
///
/// ★ ما يميّزها عن DryCleanProvider ★
///
/// ذاك يحفظ المحل **المختار** ويصمد بين الجلسات. وهذا يجلب **القائمة**
/// ويرشّحها ويرتّبها. الفصل مقصود: اختيار المحل قرار يبقى، وقائمة
/// التصفّح حالة عابرة.
class StoresProvider with ChangeNotifier {
  StoresProvider(TokenService tokenService)
      : _client = ApiClient.createClient(tokenService);

  final http.Client _client;

  List<Store> _stores = [];
  bool _isLoading = false;
  String? _error;

  String _search = '';
  StoreSort _sort = StoreSort.recommended;
  bool _favoritesOnly = false;
  int? _areaId;

  List<Store> get stores => _visible;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  StoreSort get sort => _sort;
  bool get favoritesOnly => _favoritesOnly;

  /// المحلات بعد الترشيح والترتيب.
  ///
  /// الترشيح والترتيب محلياً لا بنداء جديد: القائمة صغيرة (عشرات لا
  /// آلاف)، ونداء الخادم عند كل حرف يُكتب في البحث يجعل الكتابة متقطّعة
  /// على شبكة بطيئة.
  List<Store> get _visible {
    var list = _stores;

    if (_favoritesOnly) {
      list = list.where((s) => s.isFavorite).toList();
    }

    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              (s.description ?? '').toLowerCase().contains(q))
          .toList();
    }

    final sorted = [...list];
    switch (_sort) {
      case StoreSort.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case StoreSort.priceLow:
        // المحل بلا سعر متوسّط يذهب آخراً لا أولاً: غياب السعر ليس رخصاً
        sorted.sort((a, b) => (a.averagePrice ?? double.infinity)
            .compareTo(b.averagePrice ?? double.infinity));
        break;
      case StoreSort.nearest:
        sorted.sort((a, b) => (a.latitude == null ? 1 : 0)
            .compareTo(b.latitude == null ? 1 : 0));
        break;
      case StoreSort.recommended:
        sorted.sort((a, b) {
          // المروَّج أولاً — إعلان مدفوع، والمحل يدفع مقابل الظهور
          if (a.isPromoted != b.isPromoted) return a.isPromoted ? -1 : 1;
          // ثم القادر على تنفيذ طلب
          if (a.canOrder != b.canOrder) return a.canOrder ? -1 : 1;
          // ثم التقييم، ثم عدد الطلبات فاصلاً عند التساوي
          final r = b.rating.compareTo(a.rating);
          if (r != 0) return r;
          return b.ordersCount.compareTo(a.ordersCount);
        });
        break;
    }
    return sorted;
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setSort(StoreSort value) {
    _sort = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  Future<void> load({int? areaId, String lang = 'ar', bool force = false}) async {
    if (_isLoading) return;
    if (_stores.isNotEmpty && !force && areaId == _areaId) return;

    _areaId = areaId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(Config.storesApi).replace(queryParameters: {
        'lang': lang,
        if (areaId != null) 'areaId': '$areaId',
      });

      final res = await _client.get(uri);
      if (res.statusCode != 200) {
        _error = 'تعذّر جلب المغاسل';
        return;
      }

      final body = jsonDecode(res.body);
      final list = (body is Map ? body['drycleans'] : null) as List? ?? const [];
      _stores = list
          .map((e) => Store.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      _error = 'تعذّر الاتصال بالخادم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// المفضّلة — تبديل متفائل ثم تراجع عند الفشل.
  ///
  /// انتظار الخادم قبل تلوين القلب يجعل الضغطة تبدو غير مستجيبة على
  /// شبكة بطيئة. والتراجع عند الفشل يمنع كذبة دائمة.
  Future<void> toggleFavorite(int storeId) async {
    final i = _stores.indexWhere((s) => s.id == storeId);
    if (i < 0) return;

    final was = _stores[i].isFavorite;
    _stores[i] = _copyWithFavorite(_stores[i], !was);
    notifyListeners();

    try {
      final uri = Uri.parse('${Config.storeDetailsApi}/$storeId/favorite');
      final res = was
          ? await _client.delete(uri)
          : await _client.post(uri, headers: {'Content-Type': 'application/json'});

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _stores[i] = _copyWithFavorite(_stores[i], was);
        notifyListeners();
      }
    } catch (_) {
      _stores[i] = _copyWithFavorite(_stores[i], was);
      notifyListeners();
    }
  }

  Store _copyWithFavorite(Store s, bool fav) => Store(
        id: s.id,
        name: s.name,
        description: s.description,
        logoUrl: s.logoUrl,
        coverUrl: s.coverUrl,
        rating: s.rating,
        ratingCount: s.ratingCount,
        ordersCount: s.ordersCount,
        productsCount: s.productsCount,
        averagePrice: s.averagePrice,
        minOrderTotal: s.minOrderTotal,
        turnaroundHours: s.turnaroundHours,
        hasActiveOffer: s.hasActiveOffer,
        isPromoted: s.isPromoted,
        isFavorite: fav,
        address: s.address,
        phone: s.phone,
        latitude: s.latitude,
        longitude: s.longitude,
      );
}
