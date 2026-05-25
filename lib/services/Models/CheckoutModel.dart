import 'package:flutter/material.dart';

class CheckoutModel extends ChangeNotifier {
  Map<String, dynamic>? customerAddress;
  String? orderPickupDay;
  String? orderPickupTime;
  String? orderDeliveryDay;
  String? orderDeliveryTime;
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? paymentDetails;
  String? clientName;
  String? clientAddress;
  bool isPaid = false;
  bool isDeleted = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  void setCustomerAddress(Map<String, dynamic> address) {
    customerAddress = address;
    notifyListeners();
  }

  void setPickupData(String day, String time) {
    orderPickupDay = day;
    orderPickupTime = time;
    notifyListeners();
  }

  void setDeliveryData(String day, String time) {
    orderDeliveryDay = day;
    orderDeliveryTime = time;
    notifyListeners();
  }

  void setPaymentDetails(Map<String, dynamic> details) {
    paymentDetails = details;
    notifyListeners();
  }

  void setClientInfo(String name, String address) {
    clientName = name;
    clientAddress = address;
    notifyListeners();
  }

  void markAsPaid() {
    isPaid = true;
    notifyListeners();
  }

  void markAsDeleted() {
    isDeleted = true;
    notifyListeners();
  }

  void setCreatedAt(DateTime dateTime) {
    createdAt = dateTime;
    notifyListeners();
  }

  void setUpdatedAt(DateTime dateTime) {
    updatedAt = dateTime;
    notifyListeners();
  }
}
