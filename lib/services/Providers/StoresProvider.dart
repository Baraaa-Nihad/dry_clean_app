import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  String get translationKey {
    switch (this) {
      case StoreSort.popular:
        return 'stores_sort_popular';
      case StoreSort.priceLow:
        return 'stores_sort_price_low';
      case StoreSort.priceHigh:
        return 'stores_sort_price_high';
      case StoreSort.rating:
        return 'stores_sort_rating';
    }
  }

  IconData get icon {
    switch (this) {
      case StoreSort.popular:
        return Icons.local_fire_department_outlined;
      case StoreSort.priceLow:
        return Icons.trending_down_rounded;
      case StoreSort.priceHigh:
        return Icons.trending_up_rounded;
      case StoreSort.rating:
        return Icons.star_outline_rounded;
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
  bool _isPreviewData = false;

  String _search = '';
  StoreSort _sort = StoreSort.rating;
  bool _favoritesOnly = false;
  int? _areaId;
  String _lang = 'ar';

  /// يُلغي نداءً سابقاً لم يعد يعني شيئاً — الزبون بدّل الفلتر مرّتين
  Timer? _debounce;
  int _requestSeq = 0;

  List<Store> get stores => _visible;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPreviewData => _isPreviewData;
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
    _isPreviewData = false;
    notifyListeners();
    load(force: true);
  }

  Future<void> load({int? areaId, String? lang, bool force = false}) async {
    if (areaId != null) _areaId = areaId;
    if (lang != null) _lang = lang;
    if (!force && _stores.isNotEmpty) return;

    final seq = ++_requestSeq;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(Config.storesApi).replace(queryParameters: {
        'lang': _lang,
        'sort': _sort.apiKey,
        if (_areaId != null) 'areaId': '$_areaId',
        if (_search.trim().isNotEmpty) 'search': _search.trim(),
      });

      final res = await _client.get(uri);

      // ردّ نداء تجاوزَه نداء أحدث يُهمل: وصولهما بترتيب معكوس يعرض
      // نتيجة فلتر ألغاه الزبون
      if (seq != _requestSeq) return;

      if (res.statusCode != 200) {
        _error = 'stores_fetch_error';
        return;
      }

      final body = jsonDecode(res.body);
      final list =
          (body is Map ? body['drycleans'] : null) as List? ?? const [];
      final loaded = list
          .map((e) => Store.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      // Preview data is deliberately debug-only. It lets us review the new
      // card layout in an area that has no providers yet, without placing fake
      // laundries in the production app or database.
      if (loaded.isEmpty &&
          kDebugMode &&
          _search.trim().isEmpty &&
          !_favoritesOnly) {
        _stores = _previewStoresForSort();
        _isPreviewData = true;
      } else {
        _stores = loaded;
        _isPreviewData = false;
      }
    } catch (_) {
      if (seq != _requestSeq) return;
      _stores = [];
      _isPreviewData = false;
      _error = 'server_connection_error';
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

    if (_isPreviewData) return;

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

  List<Store> _previewStoresForSort() {
    final english = _lang == 'en';
    final stores = <Store>[
      Store(
        id: -1,
        name: english ? 'Saleem Modern Laundry' : 'مغسلة سليم الحديثة',
        description: english
            ? 'Complete care for clothes and delicate fabrics'
            : 'عناية متكاملة بالملابس والأقمشة الحسّاسة',
        rating: 4.9,
        ratingCount: 128,
        ordersCount: 642,
        productsCount: 34,
        averagePrice: 14,
        minOrderTotal: 30,
        turnaroundHours: 24,
        hasActiveOffer: true,
        isPromoted: true,
        workingHours:
            english ? 'Daily 8:00 AM - 10:00 PM' : 'يومياً 8:00 - 22:00',
      ),
      Store(
        id: -2,
        name: english ? 'Al Nada Laundry' : 'مغسلة الندى',
        description: english
            ? 'Fast washing and ironing with attention to every detail'
            : 'غسيل وكوي سريع مع اهتمام بأدق التفاصيل',
        rating: 4.7,
        ratingCount: 86,
        ordersCount: 391,
        productsCount: 27,
        averagePrice: 12,
        minOrderTotal: 25,
        turnaroundHours: 48,
        workingHours: english
            ? 'Saturday - Thursday 9:00 AM - 9:00 PM'
            : 'السبت - الخميس 9:00 - 21:00',
      ),
      Store(
        id: -3,
        name: english ? 'Clean Touch Laundry' : 'مغسلة لمسة نظافة',
        description: english
            ? 'Professional cleaning with results your clothes deserve'
            : 'تنظيف احترافي ونتيجة تليق بملابسك',
        rating: 4.6,
        ratingCount: 54,
        ordersCount: 218,
        productsCount: 19,
        averagePrice: 10,
        minOrderTotal: 20,
        turnaroundHours: 72,
        workingHours:
            english ? 'Daily 10:00 AM - 8:00 PM' : 'يومياً 10:00 - 20:00',
      ),
    ];

    switch (_sort) {
      case StoreSort.popular:
        stores.sort((a, b) => b.ordersCount.compareTo(a.ordersCount));
        break;
      case StoreSort.priceLow:
        stores.sort(
            (a, b) => (a.averagePrice ?? 0).compareTo(b.averagePrice ?? 0));
        break;
      case StoreSort.priceHigh:
        stores.sort(
            (a, b) => (b.averagePrice ?? 0).compareTo(a.averagePrice ?? 0));
        break;
      case StoreSort.rating:
        stores.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return stores;
  }
}
