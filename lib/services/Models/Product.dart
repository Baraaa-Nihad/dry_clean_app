import 'dart:ffi';

import 'package:saleem_dry_clean/services/Models/Service.dart';

class Product {
  final int productId;
  final String productName;
  final String? imagePath; // Allowing null
  final String? thumbnailPath; // Allowing null
  final List<Service> services;
  final String? area; // Allowing null

  Product({
    required this.productId,
    required this.productName,
    this.imagePath, // Nullable
    this.thumbnailPath, // Nullable
    required this.services,
    this.area, // Nullable
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    print("Parsing JSON: $json");

    // Check each field for null values
    print("product_id: ${json['product_id']}");
    print("product_name: ${json['product_name']}");
    print("image_path: ${json['image_path']}");
    print("thumbnail_path: ${json['thumbnail_path']}");
    print("services: ${json['services']}");
    print("area: ${json['area']}");

    return Product(
      productId: json['product_id'] as int,
      productName: json['product_name'] != null
          ? json['product_name'] as String
          : 'Unknown', // Default if null
      imagePath: json['image_path'] as String?, // Nullable
      thumbnailPath: json['thumbnail_path'] as String?, // Nullable
      services: (json['services'] as List)
          .map((serviceJson) => Service.fromJson(serviceJson))
          .toList(),
      area: json['area'] != null
          ? json['area'].toString() // Convert to string if not null
          : null, // Nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'image_path': imagePath,
      'thumbnail_path': thumbnailPath,
      'services': services.map((service) => service.toJson()).toList(),
      'area': area, // Nullable
    };
  }
}
