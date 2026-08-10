import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Models/Order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserProvider.dart';

class OrderProvider with ChangeNotifier {
  List<BasketItemData> _cart = [];

  /// المحل صاحب السلّة.
  ///
  /// ★ لماذا سلّة واحدة لمحل واحد ★
  ///
  /// كانت سليم هي من تغسل، فالسعر واحد والسلّة تجمع ما تشاء. أمّا وقد
  /// صار كل محل يضع أسعاره، فالصنف الواحد له سعران مختلفان حسب المحل.
  /// وسلّة تخلط محلَّين لا يمكن تسعيرها، ولا إسنادها لسائق واحد، ولا
  /// معرفة من يتحمّل تلفها.
  ///
  /// والقيد يُفرض هنا لا في الشاشة: الشاشات كثيرة والسلّة واحدة.
  int? _storeId;
  String? _storeName;

  /// كود الخصم بعد التحقّق منه، وقيمته كما حسبها الخادم.
  ///
  /// ★ القيمة من الخادم لا تُحسب هنا ★
  ///
  /// حساب النسبة في التطبيق يعني قاعدتين لنفس الرقم: واحدة تعرض
  /// للزبون وأخرى تُحتسب عند الطلب. وتفترقان عند أول كود بحدّ أقصى أو
  /// بشرط محل — فيرى الزبون خصماً ويُحاسَب بغيره.
  String? _promoCode;
  double _discount = 0;

  /// ملاحظة الزبون على الطلب — «اتصل قبل الوصول» ونحوها
  String _customerNote = '';

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
  int? get storeId => _storeId;
  String? get storeName => _storeName;
  String? get promoCode => _promoCode;
  double get discount => _discount;
  String get customerNote => _customerNote;
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

  /// الإجمالي بعد الخصم، ولا ينزل تحت الصفر — خصم يتجاوز قيمة الطلب
  /// لا يجعل سليم تدفع للزبون
  double get total {
    final t = _cachedSubtotal + _deliveryFees - _discount;
    return t < 0 ? 0 : t;
  }

  int get totalQuantity => _cachedTotalQuantity;

  /// Recomputes cached totals. Call after any change to _cart or _deliveryFees.
  void _invalidateCache() {
    _cachedSubtotal = _cart.fold(0.0, (sum, item) => sum + item.subtotal);
    _cachedTotalQuantity = _cart.fold(0, (sum, item) => sum + item.quantity);

    // ★ تغيّر السلّة يُبطل الخصم ★
    //
    // قيمة الخصم محسوبة على قيمة سلّة بعينها، وكثير من الأكواد لها حدّ
    // أدنى. فزبون يضع كوداً على سلّة بستّين ثم يحذف نصفها يبقى خصمه
    // معروضاً — ثم يرفض الخادم الكود عند الطلب فيفشل الطلب كلّه.
    //
    // الإبطال هنا لا في كل شاشة: الشاشات كثيرة والسلّة واحدة.
    if (_promoCode != null) {
      _promoCode = null;
      _discount = 0;
    }
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

  /// تثبيت كود خصم تحقّق منه الخادم.
  void applyPromo(String code, double discount) {
    _promoCode = code;
    _discount = discount < 0 ? 0 : discount;
    _scheduleSave();
    notifyListeners();
  }

  void clearPromo() {
    _promoCode = null;
    _discount = 0;
    _scheduleSave();
    notifyListeners();
  }

  void setCustomerNote(String note) {
    _customerNote = note;
    _scheduleSave();
  }

  /// هل تقبل السلّة صنفاً من هذا المحل؟
  ///
  /// السلّة الفارغة تقبل أي محل، والممتلئة تقبل صاحبها وحده.
  bool acceptsStore(int candidate) =>
      _cart.isEmpty || _storeId == null || _storeId == candidate;

  /// تثبيت المحل على السلّة.
  ///
  /// تُنادى قبل أول إضافة. ولا تفرّغ السلّة عند الاختلاف — التفريغ قرار
  /// الزبون لا قرارنا، فالشاشة تسأله أولاً ثم تنادي [switchStore].
  void bindStore(int id, String name) {
    if (_storeId == id && _storeName == name) return;
    _storeId = id;
    _storeName = name;
    _scheduleSave();
    notifyListeners();
  }

  /// تبديل المحل بعد موافقة الزبون — يفرّغ السلّة لأن أسعارها لم تعد تنطبق.
  void switchStore(int id, String name) {
    _cart.clear();
    _storeId = id;
    _storeName = name;
    _invalidateCache();
    _scheduleSave();
    notifyListeners();
  }

  // Adds a product to the cart and calculates subtotal for the item
  void addProduct(BasketItemData newItem) {
    // Check if the item already exists in the cart based on productId and serviceType.id
    // المطابقة تشمل المساحة.
    //
    // ★ لماذا ★
    //
    // سجادتان بنفس الصنف والخدمة لكن ٤×٦ و٢×٣ ليستا سطراً واحداً
    // بكمية اثنين. الدمج بلا المساحة كان يُبقي مساحة الأولى ويضاعفها،
    // فيدفع الزبون ثمن سجادتين كبيرتين وقد أرسل واحدة كبيرة وأخرى
    // صغيرة. والمساحة فارغة للمسعَّر بالقطعة، فسلوكه لم يتغيّر.
    int existingIndex = _cart.indexWhere(
      (item) =>
          item.productId == newItem.productId &&
          item.serviceType.id == newItem.serviceType.id &&
          item.area == newItem.area,
    );

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

      _cart.add(
        BasketItemData(
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
        ),
      );
    }

    _invalidateCache();
    _scheduleSave();
    notifyListeners();
  }

  /// Replaces every basket line for one catalogue product in a single update.
  ///
  /// One product can have independent washing, ironing and dry-clean lines.
  /// Applying the details screen as one transaction prevents intermediate cart
  /// totals and makes closing the screen without saving harmless.
  void replaceProductLines({
    required int productId,
    required int storeId,
    required String storeName,
    required List<BasketItemData> lines,
  }) {
    if (!acceptsStore(storeId)) {
      throw StateError('The basket belongs to another laundry.');
    }

    _cart.removeWhere((item) => item.productId == productId);

    for (final line in lines.where((item) => item.quantity > 0)) {
      final existingIndex = _cart.indexWhere(
        (item) =>
            item.productId == line.productId &&
            item.serviceType.id == line.serviceType.id &&
            item.area == line.area,
      );

      if (existingIndex == -1) {
        _cart.add(
          BasketItemData(
            productId: line.productId,
            productName: line.productName,
            category: line.category,
            serviceType: line.serviceType,
            imagePath: line.imagePath,
            price: line.price,
            unit: line.unit,
            quantity: line.quantity,
            subCategory: line.subCategory,
            area: line.area,
            subtotal: BasketItemData.calculateSubtotal(
              line.unit,
              line.price,
              line.quantity,
              line.area,
            ),
          ),
        );
      } else {
        final existing = _cart[existingIndex];
        final quantity = existing.quantity + line.quantity;
        _cart[existingIndex] = BasketItemData(
          productId: existing.productId,
          productName: existing.productName,
          category: existing.category,
          serviceType: existing.serviceType,
          imagePath: existing.imagePath,
          price: existing.price,
          unit: existing.unit,
          quantity: quantity,
          subCategory: existing.subCategory,
          area: existing.area,
          subtotal: BasketItemData.calculateSubtotal(
            existing.unit,
            existing.price,
            quantity,
            existing.area,
          ),
        );
      }
    }

    if (_cart.isEmpty) {
      _storeId = null;
      _storeName = null;
    } else {
      _storeId = storeId;
      _storeName = storeName;
    }
    _invalidateCache();
    _scheduleSave();
    notifyListeners();
  }

  // Rest of the OrderProvider remains unchanged...

  // Removes a product from the cart
  void removeProduct(BasketItemData item) {
    _cart.remove(item);
    if (_cart.isEmpty) {
      _storeId = null;
      _storeName = null;
    }
    _invalidateCache();
    _scheduleSave();
    notifyListeners();
  }

  // Clears all items from the cart
  void clearCart() {
    _cart.clear();
    // السلّة الفارغة بلا محل: إبقاء الربط يمنع الزبون من الطلب من محل
    // آخر بعد أن أفرغ سلّته بنفسه
    _storeId = null;
    _storeName = null;
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
      'storeId': _storeId,
      'storeName': _storeName,
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
    _storeId = null;
    _storeName = null;
    _promoCode = null;
    _discount = 0;
    _customerNote = '';
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
      // سلّة محفوظة قبل هذا التحديث لا تحمل معرّف محل. لا تُرمى — يكفي
      // أن تبقى بلا ربط، فأول إضافة تثبّت محلها.
      _storeId = jsonMap['storeId'] as int?;
      _storeName = jsonMap['storeName'] as String?;
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
