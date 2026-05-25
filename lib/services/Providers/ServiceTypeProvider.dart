import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Group.dart';
import 'package:saleem_dry_clean/services/Models/Service.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';

extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class ServiceTypeProvider with ChangeNotifier {
  final http.Client client;
  final LanguageProvider languageProvider;

  // Current state variables
  bool _isLoading = false;
  bool _isLoadingCategories = false;

  String? _errorMessage;
  List<Group>? _groups;
  List<Group>? _allGroups; // Store all groups here
  String? _currentServiceTypeId;
  List<Map<String, dynamic>> _categories = []; // New: categories list

  ServiceTypeProvider(this.client, this.languageProvider) {
    // Listen to language changes to refetch data if necessary
    languageProvider.onLocaleChanged = refetchData;
  }

  // Getter for the list of groups
  List<Group>? get groups => _groups;

  // Getter for all fetched groups
  List<Group>? get allGroups => _allGroups;

  // Getter for categories
  List<Map<String, dynamic>> get categories => _categories;

  // Getter for loading state
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;

  // Getter for the error message
  String? get errorMessage => _errorMessage;

  /// Fetch categories once when the page is first loaded.
  Future<void> fetchCategories(String serviceTypeId) async {
    _isLoading = true;
    _isLoadingCategories = false;
    _errorMessage = null;
    _categories = [];
    notifyListeners();

    try {
      final lang = languageProvider.locale.languageCode;
      final url = Uri.parse(
          '${Config.fetchProductsByServiceTypeID}?serviceTypeId=$serviceTypeId&lang=$lang');

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body)['groupData'];

        // Parse the list of groups, but only extract categories
        final Map<int, Map<String, dynamic>> categoryMap = {};
        final List<Group> parsedGroups = (responseData['data'] as List)
            .map((groupJson) => Group.fromJson(groupJson))
            .toList();

        // Store all groups
        _allGroups = parsedGroups;

        // Extract categories from the groups
        for (var group in parsedGroups) {
          categoryMap[group.groupId] = {
            'id': group.groupId,
            'label': group.groupName,
          };
        }

        _categories = categoryMap.values.toList();
        _errorMessage = null;
      } else {
        _errorMessage =
            'Failed to load categories (Status Code: ${response.statusCode})';
        _categories = [];
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch groups by category (if needed)
  Future<void> fetchGroupsByCategory(String serviceTypeId,
      {bool forceRefresh = false, String categoryId = ''}) async {
    // This method can be used if you have subcategories
    // Since categoryId == groupId, it's similar to fetchServiceTypes
    await fetchServiceTypes(serviceTypeId,
        forceRefresh: forceRefresh, categoryId: categoryId);
  }

  Future<void> fetchServiceTypes(String serviceTypeId,
      {bool forceRefresh = false, String categoryId = ''}) async {
    _isLoading = true;
    _isLoadingCategories = true;
    _errorMessage = null;
    _currentServiceTypeId = serviceTypeId;
    _groups = null;
    _categories = [];
    notifyListeners();

    try {
      final lang = languageProvider.locale.languageCode;
      final url = Uri.parse(
          '${Config.fetchProductsByServiceTypeID}?serviceTypeId=$serviceTypeId&lang=$lang&groupId=$categoryId');

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body)['groupData'];

        _groups = (responseData['data'] as List)
            .map((groupJson) => Group.fromJson(groupJson))
            .toList();

        final Map<int, Map<String, dynamic>> categoryMap = {};
        for (var group in _groups!) {
          categoryMap[group.groupId] = {
            'id': group.groupId,
            'label': group.groupName,
          };
        }

        _categories = categoryMap.values.toList();
        _errorMessage = null;
      } else {
        _errorMessage =
            'Failed to load service types (Status Code: ${response.statusCode})';
        _groups = null;
        _categories = [];
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      _groups = null;
      _categories = [];
    } finally {
      _isLoading = false;
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Get services for a specific product
  List<Service>? getProductServices(int productId) {
    if (_groups == null) return null;

    for (var group in _groups!) {
      for (var product in group.products) {
        if (product.productId == productId) {
          return product.services;
        }
      }
    }
    return null;
  }

  void refetchData() {
    if (_currentServiceTypeId != null) {
      fetchServiceTypes(_currentServiceTypeId!);
      fetchCategories(_currentServiceTypeId!);
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _isLoadingCategories = false;
    _errorMessage = null;
    _groups = null;
    notifyListeners();

    try {
      final lang = languageProvider.locale.languageCode;
      final url = Uri.parse(
          '${Config.fetchProductsByServiceTypeID}?serviceTypeId=$_currentServiceTypeId&lang=$lang&search=$query');

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body)['groupData'];

        _groups = (responseData['data'] as List)
            .map((groupJson) => Group.fromJson(groupJson))
            .toList();
        _errorMessage = null;

        // Update categories based on search results
        _categories = _groups!
            .map((group) => {'id': group.groupId, 'label': group.groupName})
            .toList();
      } else {
        _errorMessage =
            'Failed to load search results (Status Code: ${response.statusCode})';
        _groups = null;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      _groups = null;
    } finally {
      _isLoading = false;
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Clear all data
  void clearData() {
    _groups = null;
    _errorMessage = null;
    _isLoading = false;
    _isLoadingCategories = false;
    _currentServiceTypeId = null;
    _categories = [];
    _allGroups = [];
    notifyListeners();
  }
}
