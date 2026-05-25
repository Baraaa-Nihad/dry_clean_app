// lib/models/notification_model.dart

import 'dart:convert';

class NotificationModel {
  final String orderNumber;
  final String status;
  final DateTime dateTime;
  bool isNew;

  NotificationModel({
    required this.orderNumber,
    required this.status,
    required this.dateTime,
    this.isNew = true,
  });

  // Factory constructor for creating a new NotificationModel instance from a map.
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      orderNumber: map['orderNumber'],
      status: map['status'],
      dateTime: DateTime.parse(map['dateTime']),
      isNew: map['isNew'] ?? true,
    );
  }

  // Converts the NotificationModel instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'status': status,
      'dateTime': dateTime.toIso8601String(),
      'isNew': isNew,
    };
  }

  // Converts the NotificationModel instance to a JSON string.
  String toJson() => json.encode(toMap());

  // Factory constructor for creating a new NotificationModel instance from a JSON string.
  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source));
}
