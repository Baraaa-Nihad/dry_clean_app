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
      id: json['id'],
      serviceName: json['serviceName'],
      price: json['price'],
    );
  }
}
