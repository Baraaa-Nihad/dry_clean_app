import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Models/Order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserProvider.dart';

class OrderProvider with ChangeNotifier {
  List<BasketItemData> _cart = [];
  Map<String, dynamic>? _address;
  String? _pickupTime;
  String? _deliveryTime;
  double _deliveryFees = 0.0;
  String? _collectionDate;
  String? _deliveryDate;
  String? _collectionDay;
  String? _deliveryDay;

  // Cached totals — recomputed only when cart mutates, not on every getter read
  double _cachedSubtotal = 0.0;
  int _cachedTotalQuantity = 0;

  // Debounce timer — collapses rapid cart mutations into a single disk write
  Timer? _saveDebounce;

  List<BasketItemData> get cart => _cart;
  Map<String, dynamic>? get address => _address;
  String? get pickupTime => _pickupTime;
  String? get deliveryTime => _deliveryTime;
  double get deliveryFees => _deliveryFees;
  String? get collectionDate => _collectionDate;
  String? get deliveryDate => _deliveryDate;
  String? get collectionDay => _collectionDay;
  String? get deliveryDay => _deliveryDay;

  // O(1) reads — cache is updated by _invalidateCache() on every mutation
  double get subtotal => _cachedSubtotal;
  double get total => _cachedSubtotal + _deliveryFees;
  int get totalQuantity => _cachedTotalQuantity;

  /// Recomputes cached totals. Call after any change to _cart or _deliveryFees.
  void _invalidateCache() {
    _cachedSubtotal = _cart.fold(0.0, (sum, item) => sum + item.subtotal);
    _cachedTotalQuantity = _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Debounced persist — collapses rapid taps into one SharedPreferences write.
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), saveCartToSession);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  // Adds a product to the cart and calculates subtotal for the item
  void addProduct(BasketItemData newItem) {
    // Check if the item already exists in the cart based on productId and serviceType.id
    int existingIndex = _cart.indexWhere((item) =>
        item.productId == newItem.productId &&
        item.serviceType.id == newItem.serviceType.id);

    if (existingIndex != -1) {
      // Item exists, update the quantity and subtotal
      BasketItemData existingItem = _cart[existingIndex];
      int updatedQuantity = existingItem.quantity + newItem.quantity;
      double updatedSubtotal = BasketItemData.calculateSubtotal(
        existingItem.unit,
        existingItem.price,
        updatedQuantity,
        existingItem.area,
      );

      _cart[existingIndex] = BasketItemData(
        productId: existingItem.productId,
        productName: existingItem.productName,
        category: existingItem.category,
        serviceType: existingItem.serviceType,
        imagePath: existingItem.imagePath,
        price: existingItem.price,
        unit: existingItem.unit,
        quantity: updatedQuantity,
        subCategory: existingItem.subCategory,
        area: existingItem.area,
        subtotal: updatedSubtotal,
      );
    } else {
      // Item does not exist, add as a new entry
      double calculatedSubtotal = BasketItemData.calculateSubtotal(
        newItem.unit,
        newItem.price,
        newItem.quantity,
        newItem.area,
      );

      _cart.add(BasketItemData(
        productId: newItem.productId,
        productName: newItem.productName,
        category: newItem.category,
        serviceType: newItem.serviceType,
        imagePath: newItem.imagePath,
        price: newItem.price,
        unit: newItem.unit,
        quantity: newItem.quantity,
        subCategory: newItem.subCategory,
        area: newItem.area,
        subtotal: calculatedSubtotal,
      ));
    }

    _invalidateCache();
    _scheduleSave();
    notifyListeners();
  }

  // Rest of the OrderProvider remains unchanged...

  // Removes a product from the cart
  void removeProduct(BasketItemData item) {
    _cart.remove(item);
    _invalidateCache();
    _scheduleSave();
    notifyListeners();
  }

  // Clears all items from the cart
  void clearCart() {
    _cart.clear();
    _invalidateCache();
    _scheduleSave();
    notifyListeners();
  }

  // Sets the delivery address
  void setAddress(Map<String, dynamic> address) {
    _address = address;
    _scheduleSave();
    notifyListeners();
  }

  // Sets the pickup time
  void setPickupTime(String pickupTime) {
    _pickupTime = pickupTime;
    _scheduleSave();
    notifyListeners();
  }

  // Sets the delivery time
  void setDeliveryTime(String deliveryTime) {
    _deliveryTime = deliveryTime;
    _scheduleSave();
    notifyListeners();
  }

  // Sets the delivery fees
  void setDeliveryFees(double fees) {
    _deliveryFees = fees;
    _scheduleSave();
    notifyListeners();
  }

  // Sets the collection date
  void setCollectionDate(String date) {
    _collectionDate = date;
    notifyListeners(); // Notify listeners of state change
  }

  // Sets the delivery date
  void setDeliveryDate(String date) {
    _deliveryDate = date;
    notifyListeners(); // Notify listeners of state change
  }

  // Sets the collection day
  void setCollectionDay(String day) {
    _collectionDay = day;
    notifyListeners(); // Notify listeners of state change
  }

  // Sets the delivery day
  void setDeliveryDay(String day) {
    _deliveryDay = day;
    notifyListeners(); // Notify listeners of state change
  }

  // Method to clear the cart from session storage
  Future<void> clearCartFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }

  // Saves the cart and its details to session storage
  Future<void> saveCartToSession() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode({
      'cart': _cart.map((item) => item.toJson()).toList(),
      'address': _address, // Store the address map as is
      'pickupTime': _pickupTime,
      'deliveryTime': _deliveryTime,
      'deliveryFees': _deliveryFees,
    });
    await prefs.setString('cart', cartJson);
  }

  // Method to reset provider state
  void resetProvider() {
    _cart.clear();
    _address = null;
    _pickupTime = null;
    _deliveryTime = null;
    _deliveryFees = 0.0;
    _collectionDate = null;
    _deliveryDate = null;
    _collectionDay = null;
    _deliveryDay = null;
    _invalidateCache();
    _saveDebounce?.cancel();
    clearCartFromSession();
    notifyListeners();
  }

  // Loads the cart and its details from session storage
  Future<void> loadCartFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');
    if (cartJson != null) {
      final Map<String, dynamic> jsonMap = json.decode(cartJson);
      final List<dynamic> jsonList = jsonMap['cart'];
      _cart = jsonList.map((json) => BasketItemData.fromJson(json)).toList();
      _address = jsonMap['address'] as Map<String, dynamic>?;
      _pickupTime = jsonMap['pickupTime'];
      _deliveryTime = jsonMap['deliveryTime'];
      _deliveryFees = jsonMap['deliveryFees'] ?? 0.0;
      _invalidateCache();
      notifyListeners();
    }
  }

  // Clear all order-related data
  void clear() {
    clearCart();
    _address = null;
    _collectionDate = null;
    _deliveryDate = null;
    _pickupTime = null;
    _deliveryTime = null;
    notifyListeners();
  }

  // Builds an Order object using the current cart state and user information
  Order buildOrder(UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null) {
      throw Exception("User is not logged in");
    }

    return Order(
      userId: user.id,
      userFullName: user.fullName,
      userPhoneNumber: user.phoneNumber,
      items: _cart.map((item) {
        return BasketItemData(
          productId: item.productId,
          productName: item.productName,
          category: item.category,
          serviceType: item.serviceType,
          imagePath: item.imagePath,
          price: item.price,
          unit: item.unit,
          quantity: item.quantity,
          subCategory: item.subCategory,
          area: item.area,
          subtotal: item.subtotal,
        );
      }).toList(),
      address: _address?['id'] ?? '',
      pickupTime: _pickupTime ?? '',
      deliveryTime: _deliveryTime ?? '',
      deliveryFees: _deliveryFees,
      subtotal: subtotal,
      total: total,
    );
  }
}
