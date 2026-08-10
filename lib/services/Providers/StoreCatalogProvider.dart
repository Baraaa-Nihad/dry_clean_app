import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

/// Loads one laundry's catalogue and exposes it in the product-first shape
/// used by the customer experience.
class StoreCatalogProvider with ChangeNotifier {
  StoreCatalogProvider(TokenService tokenService)
    : _client = ApiClient.createClient(tokenService);

  final http.Client _client;

  int? _storeId;
  List<StoreService> _services = [];
  Store? _store;
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String _lang = 'ar';
  int _requestSeq = 0;

  int? get storeId => _storeId;
  List<StoreService> get services => _services;
  Store? get store => _store;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;

  /// Products after search, grouped by garment category.
  ///
  /// The API response is service-first because each price belongs to one
  /// product/service/store row. Rows sharing a product id are folded into one
  /// catalogue item so all services can be selected from its details screen.
  Map<String, List<CatalogProduct>> get visibleGroups {
    final query = _search.trim().toLowerCase();
    final fallbackGroup = _lang == 'en' ? 'Other' : 'أخرى';
    final products = <int, CatalogProduct>{};

    for (final service in _services) {
      for (final offering in service.products) {
        final existing = products[offering.productId];
        if (existing == null) {
          products[offering.productId] = CatalogProduct(
            productId: offering.productId,
            name: offering.name,
            groupId: offering.groupId,
            groupName: offering.groupName,
            imagePath: offering.imagePath,
            offerings: [offering],
          );
        } else if (!existing.offerings.any(
          (item) => item.serviceId == offering.serviceId,
        )) {
          existing.offerings.add(offering);
        }
      }
    }

    final grouped = <String, List<CatalogProduct>>{};
    for (final product in products.values) {
      if (query.isNotEmpty && !product.name.toLowerCase().contains(query)) {
        continue;
      }
      final group = (product.groupName ?? '').trim();
      grouped
          .putIfAbsent(group.isEmpty ? fallbackGroup : group, () => [])
          .add(product);
    }
    if (kDebugMode && query.isEmpty && products.isNotEmpty) {
      _appendPreviewCategories(grouped, products.values.toList());
    }
    return grouped;
  }

  /// Adds enough development-only content to exercise the sticky category
  /// navigation and long-list behaviour. Release builds always use server data
  /// only, and searching hides the preview rows so search results stay honest.
  void _appendPreviewCategories(
    Map<String, List<CatalogProduct>> grouped,
    List<CatalogProduct> source,
  ) {
    final labels = _lang == 'en'
        ? const [
            'Bedding',
            'Jackets',
            'Sportswear',
            'Children',
            'Curtains',
            'Blankets',
            'Traditional wear',
            'Home textiles',
          ]
        : const [
            'أغطية السرير',
            'جاكيتات',
            'ملابس رياضية',
            'ملابس أطفال',
            'ستائر',
            'بطانيات',
            'ملابس تراثية',
            'مفروشات منزلية',
          ];

    for (var groupIndex = 0; groupIndex < labels.length; groupIndex++) {
      final label = labels[groupIndex];
      if (grouped.containsKey(label)) continue;
      grouped[label] = List.generate(3, (itemIndex) {
        final original = source[(groupIndex * 3 + itemIndex) % source.length];
        return CatalogProduct(
          productId: original.productId,
          name: original.name,
          groupId: original.groupId,
          groupName: label,
          imagePath: original.imagePath,
          offerings: List<StoreProduct>.from(original.offerings),
        );
      });
    }
  }

  bool get isEmptyAfterSearch =>
      !_isLoading && _error == null && visibleGroups.isEmpty;

  void setSearch(String value) {
    if (_search == value) return;
    _search = value;
    notifyListeners();
  }

  Future<void> load(int storeId, {String? lang, bool force = false}) async {
    final requestedLanguage = lang ?? _lang;
    final languageChanged = requestedLanguage != _lang;
    _lang = requestedLanguage;

    if (!force &&
        !languageChanged &&
        _storeId == storeId &&
        _services.isNotEmpty) {
      return;
    }

    if (_storeId != storeId || languageChanged) {
      _services = [];
      _store = null;
      _search = '';
    }

    _storeId = storeId;
    final request = ++_requestSeq;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detailsUri = Uri.parse(
        '${Config.storeDetailsApi}/$storeId',
      ).replace(queryParameters: {'lang': _lang});
      final productsUri = Uri.parse(
        '${Config.storeDetailsApi}/$storeId/products',
      ).replace(queryParameters: {'lang': _lang});

      final responses = await Future.wait([
        _client.get(detailsUri),
        _client.get(productsUri),
      ]);
      if (request != _requestSeq) return;

      final detailsResponse = responses[0];
      final productsResponse = responses[1];
      if (productsResponse.statusCode != 200) {
        _error = 'catalog_fetch_error';
        return;
      }

      if (detailsResponse.statusCode == 200) {
        final detailsBody = jsonDecode(detailsResponse.body);
        final details = detailsBody is Map ? detailsBody['dryclean'] : null;
        if (details is Map) {
          _store = Store.fromJson(Map<String, dynamic>.from(details));
        }
      }

      final body = jsonDecode(productsResponse.body);
      final raw = (body is Map ? body['services'] : null) as List? ?? const [];
      _services = raw
          .map(
            (item) =>
                StoreService.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      if (request != _requestSeq) return;
      _error = 'server_connection_error';
    } finally {
      if (request == _requestSeq) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _requestSeq++;
    _storeId = null;
    _services = [];
    _store = null;
    _search = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
