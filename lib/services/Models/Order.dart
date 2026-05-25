import 'package:saleem_dry_clean/services/BasketItemData.dart';

class Order {
  final String userId;
  final String userFullName;
  final String userPhoneNumber;
  final List<BasketItemData> items;
  final String address;
  final String pickupTime;
  final String deliveryTime;
  final double deliveryFees;
  final double subtotal;
  final double total;

  Order({
    required this.userId,
    required this.userFullName,
    required this.userPhoneNumber,
    required this.items,
    required this.address,
    required this.pickupTime,
    required this.deliveryTime,
    required this.deliveryFees,
    required this.subtotal,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userFullName': userFullName,
      'userPhoneNumber': userPhoneNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'address': address,
      'pickupTime': pickupTime,
      'deliveryTime': deliveryTime,
      'deliveryFees': deliveryFees,
      'subtotal': subtotal,
      'total': total,
    };
  }
}
