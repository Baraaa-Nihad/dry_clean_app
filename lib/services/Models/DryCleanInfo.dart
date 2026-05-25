// lib/models/DryCleanInfo.dart

class DryCleanInfo {
  final int id;
  final String drycleanName;

  DryCleanInfo({
    required this.id,
    required this.drycleanName,
  });

  factory DryCleanInfo.fromJson(Map<String, dynamic> json) {
    return DryCleanInfo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      drycleanName: json['dryclean_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dryclean_name': drycleanName,
    };
  }
}
