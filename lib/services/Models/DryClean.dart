class DryClean {
  final int id;
  final String drycleanNameAr;
  final String phone;
  final String email;
  final double deliveryFees;

  DryClean({
    required this.id,
    required this.drycleanNameAr,
    required this.phone,
    required this.email,
    required this.deliveryFees,
  });

  factory DryClean.fromJson(Map<String, dynamic> json) {
    return DryClean(
      id: json['id'] as int,
      drycleanNameAr: json['dryclean_name_ar'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      deliveryFees: double.parse(json['delivery_fees'].toString()),
    );
  }
}
