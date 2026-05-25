import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  String _currentRoute = '/';

  String get currentRoute => _currentRoute;
  int get selectedIndex => _selectedIndex;

  // Sets the selected index only if it is different
  void setSelectedIndex(int index) {
    // Defer the state change if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedIndex = index;
      notifyListeners();
    });
  }

  // Navigate to Home
  void navigateToHome() {
    setSelectedIndex(0);
  }

  // Navigate to Basket
  void navigateToBasket() {
    setSelectedIndex(1);
  }

  // Navigate to Orders
  void navigateToOrders() {
    setSelectedIndex(2);
  }

  // Navigate to More
  void navigateToMore() {
    setSelectedIndex(3);
  }

  void updateCurrentRoute(String routeName) {
    if (_currentRoute != routeName) {
      _currentRoute = routeName;
      notifyListeners();
    }
  }

  // Navigate to a specific index based on a page
  void navigateToPage(int index) {
    if (index >= 0 && index <= 3) {
      // Assuming you have 4 bottom navigation items
      setSelectedIndex(index);
    } else {
      print('Invalid index for navigation');
    }
  }

  // Go back method
  void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Optionally, handle what happens if there is no previous screen
      print('No previous screen to navigate back to');
    }
  }
}
