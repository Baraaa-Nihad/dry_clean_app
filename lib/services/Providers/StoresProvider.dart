import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

/// ترتيب قائمة المحلات.
///
/// ★ الترتيب من الخادم لا محلياً ★
///
/// كان يرتّب الصفحة المحمَّلة وحدها، فـ«الأقلّ سعراً» يرتّب ثلاثين محلاً
/// من أصل مئة ويسمّي نتيجته الأرخص. والخادم يرتّب قبل التقطيع.
///
/// والقيم توافق مفاتيح `SORTS` في customerCatalogService حرفياً —
/// اختلاف حرف يُسقط الترتيب إلى الافتراضي بصمت.
enum StoreSort { rating, popular, priceLow, priceHigh }

extension StoreSortApi on StoreSort {
  String get apiKey {
    switch (this) {
      case StoreSort.popular:
        return 'popular';
      case StoreSort.priceLow:
        return 'price_asc';
      case StoreSort.priceHigh:
        return 'price_desc';
      case StoreSort.rating:
        return 'rating';
    }
  }

  String get label {
    switch (this) {
      case StoreSort.popular:
        return 'الأكثر شهرة';
      case StoreSort.priceLow:
        return 'الأقلّ سعراً';
      case StoreSort.priceHigh:
        return 'الأعلى سعراً';
      case StoreSort.rating:
        return 'الأعلى تقييماً';
    }
  }
}

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
  StoreSort _sort = StoreSort.rating;
  bool _favoritesOnly = false;
  int? _areaId;

  /// يُلغي نداءً سابقاً لم يعد يعني شيئاً — الزبون بدّل الفلتر مرّتين
  Timer? _debounce;
  int _requestSeq = 0;

  List<Store> get stores => _visible;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  StoreSort get sort => _sort;
  bool get favoritesOnly => _favoritesOnly;
  int? get areaId => _areaId;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// المفضّلة ترشيح محلي — القائمة محمَّلة وكل عنصر يحمل `isFavorite`،
  /// فنداء الخادم لأجلها رحلة بلا فائدة.
  List<Store> get _visible =>
      _favoritesOnly ? _stores.where((s) => s.isFavorite).toList() : _stores;

  /// البحث بمهلة: نداء عند كل حرف يُغرق الخادم ويجعل الكتابة متقطّعة.
  void setSearch(String value) {
    _search = value;
    notifyListeners();
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 350), () => load(force: true));
  }

  void setSort(StoreSort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
    load(force: true);
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  /// تبديل المنطقة يُبطل القائمة فوراً.
  ///
  /// إبقاء محلات المنطقة السابقة معروضة ريثما تصل الجديدة يجعل الزبون
  /// يضغط محلاً لا يخدم عنوانه.
  void setArea(int? areaId) {
    if (_areaId == areaId) return;
    _areaId = areaId;
    _stores = [];
    notifyListeners();
    load(force: true);
  }

  Future<void> load(
      {int? areaId, String lang = 'ar', bool force = false}) async {
    if (areaId != null) _areaId = areaId;
    if (!force && _stores.isNotEmpty) return;

    final seq = ++_requestSeq;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(Config.storesApi).replace(queryParameters: {
        'lang': lang,
        'sort': _sort.apiKey,
        if (_areaId != null) 'areaId': '$_areaId',
        if (_search.trim().isNotEmpty) 'search': _search.trim(),
      });

      final res = await _client.get(uri);

      // ردّ نداء تجاوزَه نداء أحدث يُهمل: وصولهما بترتيب معكوس يعرض
      // نتيجة فلتر ألغاه الزبون
      if (seq != _requestSeq) return;

      if (res.statusCode != 200) {
        _error = 'تعذّر جلب المغاسل';
        return;
      }

      final body = jsonDecode(res.body);
      final list =
          (body is Map ? body['drycleans'] : null) as List? ?? const [];
      _stores = list
          .map((e) => Store.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      if (seq != _requestSeq) return;
      _error = 'تعذّر الاتصال بالخادم';
    } finally {
      if (seq == _requestSeq) {
        _isLoading = false;
        notifyListeners();
      }
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
          : await _client
              .post(uri, headers: {'Content-Type': 'application/json'});

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _stores[i] = _copyWithFavorite(_stores[i], was);
        notifyListeners();
      }
    } catch (_) {
      _stores[i] = _copyWithFavorite(_stores[i], was);
      notifyListeners();
    }
  }

  /// حالة المفضّلة لمحل بعينه — تقرؤها صفحة المحل لزرّ القلب.
  bool isFavorite(int storeId) {
    for (final s in _stores) {
      if (s.id == storeId) return s.isFavorite;
    }
    return false;
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
        workingHours: s.workingHours,
      );
}
