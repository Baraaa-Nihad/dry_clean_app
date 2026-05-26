class Service {
  final int id;
  final String serviceName;
  final String price;

  Service({
    required this.id,
    required this.serviceName,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      serviceName:
          json['serviceName'] ?? 'Unknown', // Default to 'Unknown' if null
      price: json['price']?.toString() ??
          '0', // Convert to String and default to '0' if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'price': price,
    };
  }
}
