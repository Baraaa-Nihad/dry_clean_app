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

enum FavoriteToggleResult { updated, authenticationRequired, failed }

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
  StoresProvider(this._tokenService)
      : _client = ApiClient.createClient(_tokenService);

  final TokenService _tokenService;
  final http.Client _client;

  List<Store> _stores = [];
  bool _isLoading = false;
  String? _error;

  String _search = '';
  StoreSort _sort = StoreSort.rating;
  bool _favoritesOnly = false;
  final Map<int, bool> _favoriteStates = {};
  final Set<int> _favoriteUpdates = {};
  int? _areaId;
  String _lang = 'ar';

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

      for (final store in loaded) {
        if (!_favoriteUpdates.contains(store.id)) {
          _favoriteStates[store.id] = store.isFavorite;
        }
      }

      // ★ ما يُعرض هو ما ردّه الخادم — لا أكثر ★
      //
      // كانت القائمة تُكمَّل إلى أربع بطاقات ببيانات مخترَعة حين ترد أقلّ،
      // ليُراجَع تصميم الكرت المتراكم. والثمن أن الزبون يرى مغاسل غير
      // موجودة تحمل تقييمات وعروضاً وأسعاراً لا مصدر لها — ولو ضغط
      // إحداها لم يحدث شيء.
      //
      // ومنطقةٌ فيها محل واحد يجب أن تُظهر محلاً واحداً: ذاك هو الواقع،
      // وإخفاؤه بثلاثة أشباح يخفي مشكلة التغطية عمّن يملك حلّها.
      _stores = loaded;
    } catch (_) {
      if (seq != _requestSeq) return;
      _stores = [];
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
  Future<FavoriteToggleResult> toggleFavorite(
    int storeId, {
    bool? currentValue,
  }) async {
    if (_favoriteUpdates.contains(storeId)) {
      return FavoriteToggleResult.failed;
    }

    final token = await _tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      return FavoriteToggleResult.authenticationRequired;
    }

    final was = isFavorite(storeId, fallback: currentValue ?? false);
    _favoriteUpdates.add(storeId);
    _setFavorite(storeId, !was);
    notifyListeners();

    if (storeId < 0) {
      _favoriteUpdates.remove(storeId);
      notifyListeners();
      return FavoriteToggleResult.updated;
    }

    try {
      final uri = Uri.parse('${Config.storeDetailsApi}/$storeId/favorite');
      final res = was
          ? await _client.delete(uri)
          : await _client
              .post(uri, headers: {'Content-Type': 'application/json'});

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return FavoriteToggleResult.updated;
      }

      _setFavorite(storeId, was);
      return res.statusCode == 401
          ? FavoriteToggleResult.authenticationRequired
          : FavoriteToggleResult.failed;
    } catch (_) {
      _setFavorite(storeId, was);
      return FavoriteToggleResult.failed;
    } finally {
      _favoriteUpdates.remove(storeId);
      notifyListeners();
    }
  }

  /// حالة المفضّلة لمحل بعينه — تقرؤها صفحة المحل لزرّ القلب.
  bool isFavorite(int storeId, {bool fallback = false}) {
    final remembered = _favoriteStates[storeId];
    if (remembered != null) return remembered;
    for (final s in _stores) {
      if (s.id == storeId) return s.isFavorite;
    }
    return fallback;
  }

  bool isFavoriteUpdating(int storeId) => _favoriteUpdates.contains(storeId);

  void _setFavorite(int storeId, bool value) {
    _favoriteStates[storeId] = value;
    final index = _stores.indexWhere((store) => store.id == storeId);
    if (index >= 0) {
      _stores[index] = _copyWithFavorite(_stores[index], value);
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
        discountPercent: s.discountPercent,
        isPromoted: s.isPromoted,
        isFavorite: fav,
        address: s.address,
        phone: s.phone,
        latitude: s.latitude,
        longitude: s.longitude,
        workingHours: s.workingHours,
      );

}
