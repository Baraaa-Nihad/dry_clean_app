import 'package:saleem_dry_clean/services/Models/OrderItem.dart';

class OrderData {
  final int orderId;
  final String status;
  final Map<String, List<Map<String, dynamic>>> categories;
  final String location;
  final String orderedAt;
  final String collectionTime;
  final String deliveryTime;
  final double totalPrice;
  final String subtotal;
  final DateTime collectionDate;
  final DateTime deliveryDate;
  final bool isPaid;
  final double deliveryFees;
  final String paymentMethod;
  final String clientName;
  final String clientAddress;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  List<OrderItem> items;

  OrderData({
    required this.orderId,
    required this.status,
    required this.categories,
    required this.location,
    required this.orderedAt,
    required this.collectionDate,
    required this.deliveryDate,
    required this.collectionTime,
    required this.deliveryTime,
    required this.totalPrice,
    required this.isPaid,
    required this.subtotal,
    required this.deliveryFees,
    required this.paymentMethod,
    required this.clientName,
    required this.clientAddress,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  /// This function organizes the `OrderItem` list by the service type
  Map<String, List<OrderItem>> itemsByCategory() {
    Map<String, List<OrderItem>> categorizedItems = {};

    for (var item in items) {
      String category = item.serviceType;
      if (categorizedItems.containsKey(category)) {
        categorizedItems[category]!.add(item);
      } else {
        categorizedItems[category] = [item];
      }
    }

    return categorizedItems;
  }

  /// Factory method to create an `OrderData` instance from a JSON object
  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orderId: json['id'] is int ? json['id'] : int.parse(json['id']),
      status: json['status'] ?? '',
      categories: {}, // Assuming this field needs a different format
      location: json['fullAddress'] ?? '',
      orderedAt: json['orderedAt'] ?? '',
      collectionTime: json['pickup_time'] ?? '',
      deliveryTime: json['delivery_time'] ?? '',

      collectionDate:
          DateTime.tryParse(json['collection_date'] as String? ?? '')
                  ?.toLocal() ??
              DateTime.now(),
      deliveryDate: DateTime.tryParse(json['delivery_date'] as String? ?? '')
              ?.toLocal() ??
          DateTime.now(),
      subtotal: json['subtotal'] ?? '',
      totalPrice: json['total'] != null
          ? double.tryParse(json['total'].toString()) ?? 0.0
          : 0.0,
      deliveryFees: json['delivery_fees'] != null
          ? double.tryParse(json['delivery_fees'].toString()) ?? 0.0
          : 0.0,
      isPaid: json['ispaid'] == 1, // Handling the "isPaid" field
      paymentMethod: json['payment_method'] ?? '',
      clientName: json['user_name'] ?? '',
      clientAddress: json['user_address'] ?? '',
      isDeleted: json['is_deleted'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),

      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      items: json['order_items'] != null
          ? (json['order_items'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
    );
  }

  /// Converts the `OrderData` instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': orderId,
      'status': status,
      'categories': categories,
      'area_name': location,
      'collection_date': orderedAt,
      'collection_date': collectionDate,
      'delivery_date': deliveryDate,
      'pickup_time': collectionTime,
      'delivery_time': deliveryTime,
      'total': totalPrice,
      'delivery_fees': deliveryFees,
      'subtotal': subtotal,
      'payment_method': paymentMethod,
      'user_full_name': clientName,
      'address': clientAddress,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'is_paid': isPaid ? 1 : 0, // Convert true to 1 and false to 0
    };
  }

  /// This function allows the creation of a new instance with updated fields
  OrderData copyWith({
    int? orderId,
    String? status,
    Map<String, List<Map<String, dynamic>>>? categories,
    String? location,
    String? orderedAt,
    String? collectionTime,
    String? deliveryTime,
    double? totalPrice,
    String? subtotal,
    double? deliveryFees,
    bool? isPaid,
    String? paymentMethod,
    String? clientName,
    String? clientAddress,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? collectionDate,
    DateTime? deliveryDate,
    List<OrderItem>? items,
  }) {
    return OrderData(
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      orderedAt: orderedAt ?? this.orderedAt,
      collectionTime: collectionTime ?? this.collectionTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      collectionDate: collectionDate ?? this.collectionDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryFees: deliveryFees ?? this.deliveryFees,
      totalPrice: totalPrice ?? this.totalPrice,
      isPaid: isPaid ?? this.isPaid,
      subtotal: subtotal ?? this.subtotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      clientName: clientName ?? this.clientName,
      clientAddress: clientAddress ?? this.clientAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
