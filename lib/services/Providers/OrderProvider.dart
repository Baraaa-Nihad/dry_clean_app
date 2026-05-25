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

  List<BasketItemData> get cart => _cart;
  Map<String, dynamic>? get address => _address;
  String? get pickupTime => _pickupTime;
  String? get deliveryTime => _deliveryTime;
  double get deliveryFees => _deliveryFees;
  String? get collectionDate => _collectionDate;
  String? get deliveryDate => _deliveryDate;
  String? get collectionDay => _collectionDay;
  String? get deliveryDay => _deliveryDay;

  // Calculating subtotal based on item details
  double get subtotal => _cart.fold(0.0, (sum, item) {
        double itemSubtotal;
        double areaValue = double.tryParse(item.area) ?? 0.0;

        if (item.unit == 'Square meter') {
          itemSubtotal = areaValue * item.price * item.quantity;
        } else {
          itemSubtotal = item.price * item.quantity;
        }
        return sum + itemSubtotal;
      });

  // Total amount including delivery fees
  double get total => subtotal + _deliveryFees;

  // Total quantity of all items in the cart
  int get totalQuantity => _cart.fold(0, (sum, item) => sum + item.quantity);

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

      print(
          "Updated item: ${existingItem.productName}, New Quantity: $updatedQuantity, New Subtotal: $updatedSubtotal");
    } else {
      // Item does not exist, add as a new entry
      double calculatedSubtotal = BasketItemData.calculateSubtotal(
        newItem.unit,
        newItem.price,
        newItem.quantity,
        newItem.area,
      );

      BasketItemData itemToAdd = BasketItemData(
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
      );

      _cart.add(itemToAdd);

      print(
          "Added new item: ${itemToAdd.productName}, Quantity: ${itemToAdd.quantity}, Subtotal: ${itemToAdd.subtotal}");
    }

    saveCartToSession(); // Save updated cart to session storage
    notifyListeners(); // Notify listeners of state change
  }

  // Rest of the OrderProvider remains unchanged...

  // Removes a product from the cart
  void removeProduct(BasketItemData item) {
    _cart.remove(item);
    saveCartToSession(); // Save updated cart to session storage
    notifyListeners(); // Notify listeners of state change
  }

  // Clears all items from the cart
  void clearCart() {
    _cart.clear();
    saveCartToSession(); // Save updated cart to session storage
    notifyListeners(); // Notify listeners of state change
  }

  // Sets the delivery address
  void setAddress(Map<String, dynamic> address) {
    _address = address;
    saveCartToSession(); // Save updated cart to session storage
    notifyListeners(); // Notify listeners of state change
  }

  // Sets the pickup time
  void setPickupTime(String pickupTime) {
    _pickupTime = pickupTime;
    saveCartToSession(); // Save updated cart to session storage
    notifyListeners(); // Notify listeners of state change
  }

  // Sets the delivery time
  void setDeliveryTime(String deliveryTime) {
    _deliveryTime = deliveryTime;
    saveCartToSession(); // Save updated cart to session storage
    notifyListeners(); // Notify listeners of state change
  }

  // Sets the delivery fees
  void setDeliveryFees(double fees) {
    _deliveryFees = fees;
    saveCartToSession(); // Save updated cart to session storage
    notifyListeners(); // Notify listeners of state change
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

    // Clear saved cart in session
    clearCartFromSession();

    notifyListeners(); // Notify listeners to update UI
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
      notifyListeners(); // Notify listeners of state change
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
