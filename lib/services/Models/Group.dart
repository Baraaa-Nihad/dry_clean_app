import 'package:saleem_dry_clean/services/Models/Product.dart';

class Group {
  final int groupId;
  final String groupName;
  final String serviceName;
  final String pricePer;
  final String? pricePerUnit;
  final List<Product> products;

  Group({
    required this.groupId,
    required this.groupName,
    required this.serviceName,
    required this.pricePer,
    this.pricePerUnit,
    required this.products,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['group_id'],
      groupName: json['group_name'],
      serviceName: json['service_name'],
      pricePer: json['price_per'],
      pricePerUnit: json['price_per'],
      products: (json['products'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
    );
  }
}
