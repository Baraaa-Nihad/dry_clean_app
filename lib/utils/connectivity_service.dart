import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  bool get isConnected => _isConnected;
  ConnectivityResult get connectivityResult => _connectivityResult;

  ConnectivityService() {
    _initializeConnectivity();
    // التعديل 1: الـ Stream الآن يعيد List وليس قيمة منفردة
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectivity(results);
    });
  }

  Future<void> _initializeConnectivity() async {
    try {
      // التعديل 2: استقبال القائمة باستخدام await وتمريرها للدالة
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      _updateConnectivity(results);
    } catch (e) {
      print('ConnectivityService: Failed to initialize connectivity: $e');
    }
  }

// التعديل 3: تأكد أن دالة التحديث تستقبل List
  void _updateConnectivity(List<ConnectivityResult> results) {
    // المنطق الخاص بك لتحديد هل يوجد إنترنت أم لا
    _isConnected =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    // إذا كنت تخزن النتيجة الأخيرة في متغير
    _connectivityResult =
        results.first; // نأخذ أول عنصر للتبسيط إذا كنت تحتاجه كقيمة واحدة

    notifyListeners();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool previousStatus = _isConnected;
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      _isConnected = true;
    } else {
      _isConnected = false;
    }

    if (previousStatus != _isConnected) {
      notifyListeners();
      print(
          'ConnectivityService: Connectivity status changed to $_isConnected');
    }
  }
}
