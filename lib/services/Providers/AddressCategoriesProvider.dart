import 'package:flutter/material.dart';

class CategoriesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [
    {'icon': 'assets/Icons/HomeDefult.svg', 'label': 'Home'},
    {'icon': 'assets/Icons/Work.svg', 'label': 'Work'},
    {'icon': 'assets/Icons/Hotel.svg', 'label': 'Hotel'},
  ];

  List<Map<String, dynamic>> get categories => _categories;

  void addCategory(Map<String, dynamic> category) {
    _categories.add(category);
    notifyListeners();
  }

  void removeCategory(int index) {
    _categories.removeAt(index);
    notifyListeners();
  }
}
