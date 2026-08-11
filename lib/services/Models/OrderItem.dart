import 'package:saleem_dry_clean/services/ApiClient/config.dart';

class OrderItem {
  final int orderId;
  final String serviceName;
  final String productName;
  final String category;
  final String serviceType;
  final double unitPrice;
  final int quantity;
  final double total;
  final bool wasMissed;
  final String imagePath;
  final String unit;
  final double? width;
  final double? length;
  final double? area;
  final bool measurementPending;

  OrderItem({
    required this.orderId,
    required this.serviceName,
    required this.productName,
    required this.category,
    required this.serviceType,
    required this.unitPrice,
    required this.quantity,
    required this.total,
    required this.wasMissed,
    required this.imagePath,
    this.unit = 'item',
    this.width,
    this.length,
    this.area,
    this.measurementPending = false,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'] is int
          ? json['order_id'] as int
          : int.tryParse(json['order_id'].toString()) ?? 0,
      serviceName: json['service_name'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      unitPrice: json['unit_price'] is num
          ? (json['unit_price'] as num).toDouble()
          : double.tryParse(json['unit_price'].toString()) ?? 0.0,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity'].toString()) ?? 0,
      total: json['total'] is num
          ? (json['total'] as num).toDouble()
          : double.tryParse(json['total'].toString()) ?? 0.0,
      wasMissed: json['was_missed'] == 1,
      imagePath: Config.resolveImageUrl(json['image_path'] as String?),
      unit: json['unit']?.toString() ?? 'item',
      width: double.tryParse('${json['width_m'] ?? ''}'),
      length: double.tryParse('${json['length_m'] ?? ''}'),
      area: double.tryParse('${json['area_sqm'] ?? ''}'),
      measurementPending: json['measurement_pending'] == true ||
          json['measurement_pending'] == 1 ||
          json['measurement_pending']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'service_name': serviceName,
      'product_name': productName,
      'category': category,
      'service_type': serviceType,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total': total,
      'was_missed': wasMissed ? 1 : 0,
      'image_path': imagePath,
      'unit': unit,
      'width_m': width,
      'length_m': length,
      'area_sqm': area,
      'measurement_pending': measurementPending ? 1 : 0,
    };
  }

  // Method to clear the OrderItem data
  OrderItem clear() {
    return OrderItem(
      orderId: 0,
      serviceName: '',
      productName: '',
      category: '',
      serviceType: '',
      unitPrice: 0.0,
      quantity: 0,
      total: 0.0,
      wasMissed: false,
      imagePath: '',
      unit: 'item',
      measurementPending: false,
    );
  }
}
