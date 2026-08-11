import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

/// The selected laundry's fully dynamic catalogue.
class StoreCatalogProvider with ChangeNotifier {
  StoreCatalogProvider(TokenService tokenService)
      : _tokenService = tokenService,
        _client = ApiClient.createClient(tokenService);

  final http.Client _client;
  final TokenService _tokenService;
  int? _storeId;
  List<StoreService> _services = [];
  List<CatalogType> _catalogTypes = [];
  List<PreviousMeasurement> _previousMeasurements = [];
  int? _selectedTypeId;
  Store? _store;
  bool _isLoading = false;
  String? _error;
  String _search = '';
  String _lang = 'ar';
  int _requestSeq = 0;

  int? get storeId => _storeId;
  List<StoreService> get services => _services;
  List<CatalogType> get catalogTypes => _catalogTypes;
  List<PreviousMeasurement> get previousMeasurements => _previousMeasurements;
  int? get selectedTypeId => _selectedTypeId;
  Store? get store => _store;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;

  CatalogType? get selectedType {
    if (_catalogTypes.isEmpty) return null;
    return _catalogTypes.firstWhere(
      (type) => type.id == _selectedTypeId,
      orElse: () => _catalogTypes.first,
    );
  }

  Map<String, List<CatalogProduct>> get visibleGroups {
    final query = _search.trim().toLowerCase();
    final grouped = <String, List<CatalogProduct>>{};
    final type = selectedType;
    if (type == null) {
      final products = <int, CatalogProduct>{};
      for (final service in _services) {
        for (final offering in service.products) {
          final current = products[offering.productId];
          if (current == null) {
            products[offering.productId] = CatalogProduct(
              productId: offering.productId,
              name: offering.name,
              groupId: offering.groupId,
              groupName: offering.groupName,
              imagePath: offering.imagePath,
              offerings: [offering],
            );
          } else if (!current.offerings.any(
              (item) => item.serviceId == offering.serviceId)) {
            current.offerings.add(offering);
          }
        }
      }
      final fallback = _lang == 'en' ? 'Other' : 'أخرى';
      for (final product in products.values) {
        if (query.isNotEmpty &&
            !product.name.toLowerCase().contains(query)) continue;
        final group = (product.groupName ?? '').trim();
        grouped.putIfAbsent(group.isEmpty ? fallback : group, () => []).add(product);
      }
      return grouped;
    }
    for (final group in type.groups) {
      final products = group.products
          .where((product) =>
              !product.customSizeTemplate &&
              (query.isEmpty || product.name.toLowerCase().contains(query)))
          .toList();
      if (products.isNotEmpty) grouped[group.name] = products;
    }
    return grouped;
  }

  CatalogProduct? get customSizeTemplate {
    for (final group in selectedType?.groups ?? const <CatalogGroup>[]) {
      for (final product in group.products) {
        if (product.customSizeTemplate) return product;
      }
    }
    return null;
  }

  List<PreviousMeasurement> previousMeasurementsForType(int catalogTypeId) =>
      _previousMeasurements
          .where((item) => item.catalogTypeId == catalogTypeId)
          .toList(growable: false);

  /// مصدر الاختيار هو السجل، لكن بيانات المنتج وسعره الحاليان من
  /// الكتالوج المفتوح الآن. هكذا لا يعاد استعمال صنف حُذف أو سعر قديم.
  CatalogProduct? productForPreviousMeasurement(
    PreviousMeasurement measurement,
  ) {
    CatalogType? type;
    for (final candidate in _catalogTypes) {
      if (candidate.id == measurement.catalogTypeId) {
        type = candidate;
        break;
      }
    }
    if (type == null) return null;

    for (final group in type.groups) {
      for (final product in group.products) {
        if (product.productId == measurement.productId &&
            product.offerings.any(
              (offering) => offering.serviceId == measurement.serviceId,
            )) {
          return product;
        }
      }
    }
    return null;
  }

  bool get isEmptyAfterSearch =>
      !_isLoading && _error == null && visibleGroups.isEmpty;

  void setSearch(String value) {
    if (_search == value) return;
    _search = value;
    notifyListeners();
  }

  void selectType(int id) {
    if (_selectedTypeId == id) return;
    _selectedTypeId = id;
    _search = '';
    notifyListeners();
  }

  Future<void> load(int storeId, {String? lang, bool force = false}) async {
    final requestedLanguage = lang ?? _lang;
    final languageChanged = requestedLanguage != _lang;
    _lang = requestedLanguage;
    if (!force && !languageChanged && _storeId == storeId && _catalogTypes.isNotEmpty) {
      return;
    }

    if (_storeId != storeId || languageChanged) {
      _services = [];
      _catalogTypes = [];
      _previousMeasurements = [];
      _selectedTypeId = null;
      _store = null;
      _search = '';
    }

    _storeId = storeId;
    final request = ++_requestSeq;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detailsUri = Uri.parse('${Config.storeDetailsApi}/$storeId')
          .replace(queryParameters: {'lang': _lang});
      final productsUri = Uri.parse('${Config.storeDetailsApi}/$storeId/products')
          .replace(queryParameters: {'lang': _lang});
      final accessToken = await _tokenService.getAccessToken();
      final previousMeasurementsUri = Uri.parse(
        '${Config.storeDetailsApi}/$storeId/previous-measurements',
      );
      final responses = await Future.wait([
        _client.get(detailsUri),
        _client.get(productsUri),
        if (accessToken != null) _client.get(previousMeasurementsUri),
      ]);
      if (request != _requestSeq) return;

      if (responses[1].statusCode != 200) {
        _error = 'catalog_fetch_error';
        return;
      }
      if (responses[0].statusCode == 200) {
        final detailsBody = jsonDecode(responses[0].body);
        final details = detailsBody is Map ? detailsBody['dryclean'] : null;
        if (details is Map) {
          _store = Store.fromJson(Map<String, dynamic>.from(details));
        }
      }

      final body = jsonDecode(responses[1].body);
      final legacy = (body is Map ? body['services'] : null) as List? ?? const [];
      _services = legacy
          .map((item) => StoreService.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      final rawTypes =
          (body is Map ? body['catalogTypes'] : null) as List? ?? const [];
      _catalogTypes = rawTypes
          .map((item) => CatalogType.fromJson(Map<String, dynamic>.from(item as Map)))
          .where((type) => type.groups.any((group) => group.products.isNotEmpty))
          .toList();
      if (_catalogTypes.isNotEmpty) _selectedTypeId = _catalogTypes.first.id;

      _previousMeasurements = [];
      if (accessToken != null &&
          responses.length > 2 &&
          responses[2].statusCode == 200) {
        final previousBody = jsonDecode(responses[2].body);
        final rawMeasurements = previousBody is Map
            ? previousBody['measurements'] as List? ?? const []
            : const [];
        _previousMeasurements = rawMeasurements
            .whereType<Map>()
            .map(
              (item) => PreviousMeasurement.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((item) => item.width > 0 && item.length > 0)
            .toList();
      }
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
    _catalogTypes = [];
    _previousMeasurements = [];
    _selectedTypeId = null;
    _store = null;
    _search = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
