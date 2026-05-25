// lib/services/Models/Device.dart

class Device {
  final String deviceToken;
  final String deviceType;
  final String osVersion;
  final String model;
  final String appVersion; // New Field
  final String? userId;

  Device({
    required this.deviceToken,
    required this.deviceType,
    required this.osVersion,
    required this.model,
    required this.appVersion, // Initialize the new field
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceToken': deviceToken,
      'deviceType': deviceType,
      'osVersion': osVersion,
      'model': model,
      'appVersion': appVersion, // Include in JSON
      'userId': userId,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceToken: json['deviceToken'],
      deviceType: json['deviceType'],
      osVersion: json['osVersion'],
      model: json['model'],
      appVersion: json['appVersion'], // Parse from JSON
      userId: json['userId'],
    );
  }
}
