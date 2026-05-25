// lib/services/Providers/UserProvider.dart

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/DeviceService.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Device.dart';
import 'package:saleem_dry_clean/services/Models/OrderItem.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/User/UserService.dart';
import 'package:saleem_dry_clean/services/extensions/list_extensions.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saleem_dry_clean/utils/app_version_helper.dart';
import 'package:saleem_dry_clean/utils/connectivity_service.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class UserProvider with ChangeNotifier {
  bool _isLoadingOrders = false;
  bool _isLoadingCompletedOrders = false;
  bool _isLoadingItems = false;
  final DeviceService _deviceService;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingCompletedOrders => _isLoadingCompletedOrders;
  bool get isLoadingItems => _isLoadingItems;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _userSignedIn = false;
  bool get userSignedIn => _userSignedIn;

  User? _user;
  User? get user => _user;

  List<Map<String, dynamic>> _userAddresses = [];
  List<Map<String, dynamic>> get userAddresses => _userAddresses;

  List<OrderData> _orders = [];
  List<OrderData> get orders => _orders;

  List<OrderData> _completedOrders = [];
  List<OrderData> get completedOrders => _completedOrders;

  // Use the TokenService injected through DeviceService — do NOT create a
  // new instance here. Each TokenService creates its own FlutterSecureStorage,
  // which adds redundant keystore reads on every API call.
  TokenService get _tokenService => _deviceService.tokenService;

  DateTime? _lastFetchTime;
  DateTime? get lastFetchTime => _lastFetchTime;

  int _currentPage = 0;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners(); // Optionally notify listeners if you want to react to page changes
  }

  int _completedPage = 0;
  int get completedPage => _completedPage;

  set completedPage(int value) {
    _completedPage = value;
    notifyListeners(); // Optionally notify listeners if you want to react to page changes
  }

  // Add getters for 'hasMoreOrders' and 'hasMoreCompletedOrders'
  bool _hasMoreOrders = true;
  bool get hasMoreOrders => _hasMoreOrders;

  bool _hasMoreCompletedOrders = true;
  bool get hasMoreCompletedOrders => _hasMoreCompletedOrders;
  String _token = '';

  UserProvider(this._deviceService) {
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    final userService = UserService();
    _userSignedIn = await userService.isUserSignedIn();

    if (_userSignedIn) {
      _user = await userService.getUser();
      _userAddresses = _user?.addresses ?? [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    _userSignedIn = true;
    _userAddresses = user.addresses;
    notifyListeners();
  }

  Future<void> initializeFCM() async {
    await _getToken(); // Call this to retrieve the FCM token on initialization
    await _fetchAndRegisterDeviceInfo();
  }

  void clearUser() {
    _user = null;
    _userSignedIn = false;
    _userAddresses = [];
    _orders = [];
    _completedOrders = [];
    notifyListeners();
  }

  // Add a method to clear orders data
  void clearOrdersData() {
    _orders.clear();
    _completedOrders.clear();
    _isLoadingOrders = false;
    _isLoadingCompletedOrders = false;
    notifyListeners();
  }

  Future<void> registerDeviceToken(String deviceToken, String deviceType,
      String osVersion, String model, String appVersion) async {
    if (_user == null) {
      print('No user is signed in. Cannot register device token.');
      return;
    }

    final device = Device(
      deviceToken: deviceToken,
      deviceType: deviceType,
      osVersion: osVersion,
      model: model,
      appVersion: appVersion,
      userId: _user!.id, // Here, ! is used because _user is checked for null
    );

    final success = await _deviceService.registerDevice(device);
    if (success) {
      print('Device token registered successfully.');
    } else {
      print('Failed to register device token.');
    }
  }

  Future<void> unregisterDeviceToken(String deviceToken) async {
    if (_user == null) {
      print('No user is signed in. Cannot unregister device token.');
      return;
    }

    final success = await _deviceService.unregisterDevice(deviceToken);
    if (success) {
      print('Device token unregistered successfully.');
    } else {
      print('Failed to unregister device token.');
    }
  }

  Future<void> signIn({
    required String selectedCountryCode,
    required String phoneNumber,
    required String password,
    required BuildContext context,
    required String deviceToken, // Pass device token
    required String deviceType, // e.g., 'android' or 'ios'
    required String osVersion, // e.g., '14.0'
    required String model, // e.g., 'iPhone 12'
    required String appVersion, // New Parameter
  }) async {
    _isLoading = true;
    notifyListeners();

    final cleanedPhoneNumber = cleanPhoneNumber(phoneNumber);
    final fullPhoneNumber = selectedCountryCode + cleanedPhoneNumber;
    final url = Uri.parse('${Config.signInApi}');
    print('Attempting to sign in with URL: $url');

    try {
      final client = ApiClient.createClient(_tokenService);
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phoneNumber': fullPhoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userJson = responseData['user'];
        final tokens = responseData['tokens'];

        final user = User.fromJson(userJson);
        final userService = UserService();
        await userService.signIn(user);
        await _tokenService.saveTokens(
            tokens['accessToken'], tokens['refreshToken']);

        _userSignedIn = true;
        setUser(user);

        await fetchUserAddress(
            _user!.id, 'en', context); // Fetch addresses on sign in

        // Register device token with additional details after successful sign-in
        await registerDeviceToken(
            deviceToken, deviceType, osVersion, model, appVersion);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception('Failed to sign in: ${errorResponse['message']}');
      }
    } catch (error) {
      print('Sign-in error: $error');
      throw Exception('Failed to sign in: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _token = token;
      } else {
        print('Failed to obtain FCM token');
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
  }

  Future<void> _fetchAndRegisterDeviceInfo() async {
    if (_user == null) return;

    String deviceType;
    String osVersion;
    String model;
    String appVersion;

    if (Platform.isAndroid) {
      var androidInfo = await _deviceInfoPlugin.androidInfo;
      deviceType = 'android';
      osVersion = androidInfo.version.release ?? 'Unknown';
      model = androidInfo.model ?? 'Unknown';
    } else if (Platform.isIOS) {
      var iosInfo = await _deviceInfoPlugin.iosInfo;
      deviceType = 'ios';
      osVersion = iosInfo.systemVersion ?? 'Unknown';
      model = iosInfo.utsname.machine ?? 'Unknown';
    } else {
      deviceType = 'unknown';
      osVersion = 'unknown';
      model = 'unknown';
    }

    // Fetch app version
    appVersion = await AppVersionHelper.getAppVersion();
    print(appVersion);
    await registerDeviceToken(_token, deviceType, osVersion, model, appVersion);
  }

  Future<void> _sendTokenToBackend(String token) async {
    final isSignedIn = _userSignedIn && _user != null;
    if (!isSignedIn) {
      print('User is not signed in. Skipping sending device token.');
      return;
    }

    final url = '${Config.deviceRegistration}';

    try {
      final jwtToken = await _tokenService.getAccessToken();
      if (jwtToken == null) {
        print(
            'sendTokenToBackend: JWT Token is null. Skipping sending device token.');
        return;
      }

      final client = ApiClient.createClient(_tokenService);

      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'deviceToken': token,
        }),
      );

      if (response.statusCode == 200) {
        print('Device token sent successfully');
      } else {
        print('Failed to send device token: ${response.body}');
      }
    } catch (error) {
      print('Error sending device token: $error');
    }
  }

  Future<void> signOut(BuildContext context, String deviceToken) async {
    final userService = UserService();

    // Step 2: Sign out the user
    await userService.signOut();

    // Step 3: Clear JWT tokens
    await _tokenService.clearTokens();

    // Step 4: Update user state
    _userSignedIn = false;
    clearUser();
  }

  Future<void> fetchOrders({
    int page = 0,
    int pageSize = 3,
    String? lang,
    required BuildContext context,
  }) async {
    print('UserProvider: fetchOrders called with page: $page, lang: $lang');

    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);

    // Prevent fetch if there's no connection
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return;
    }

    // Prevent multiple fetches if already fetching
    if (_isLoadingOrders) return;

    if (_user == null) {
      _isLoadingOrders = false;
      notifyListeners();
      return;
    }

    try {
      _isLoadingOrders = true;
      notifyListeners();

      final userId = _user!.id;
      final url = Uri.parse(
          '${Config.getOrdersApi}?userId=$userId&page=$page&pageSize=$pageSize&lang=$lang&completed=0&tag=app');

      final client = ApiClient.createClient(_tokenService);
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<OrderData> newOrders =
            (responseData['orders']['orders'] as List<dynamic>)
                .map((data) => OrderData.fromJson(data))
                .toList();

        // Avoid adding duplicate orders
        if (page == 0) {
          // Replace the entire orders list if fetching the first page
          _orders = newOrders;
        } else {
          // Filter out orders that are already present in the _orders list
          final existingOrderIds =
              _orders.map((order) => order.orderId).toSet();
          final filteredOrders = newOrders
              .where((order) => !existingOrderIds.contains(order.orderId))
              .toList();

          // Add only the new, non-duplicate orders
          _orders.addAll(filteredOrders);
        }

        if (newOrders.isNotEmpty) {
          final orderIds = newOrders.map((order) => order.orderId).toList();
          await fetchOrderItems(orderIds, lang, context);
        }

        // Determine if there are more orders to load
        _hasMoreOrders = newOrders.length == pageSize;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      print('Error fetching orders: $error');
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  // The same logic applies for fetchCompletedOrders
  Future<void> fetchCompletedOrders({
    int page = 0,
    int pageSize = 3,
    String? lang,
    required BuildContext context,
  }) async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return;
    }

    if (_user == null) {
      _isLoadingCompletedOrders = false;
      notifyListeners();
      return;
    }

    try {
      _isLoadingCompletedOrders = true;
      notifyListeners();
      final userId = _user!.id;

      final url = Uri.parse(
          '${Config.getOrdersApi}?userId=$userId&page=$page&pageSize=$pageSize&lang=$lang&completed=1');

      final client = ApiClient.createClient(_tokenService);
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<OrderData> newCompletedOrders =
            (responseData['orders']['orders'] as List<dynamic>)
                .map((data) => OrderData.fromJson(data))
                .toList();

        if (page == 0) {
          _completedOrders = newCompletedOrders;
        } else {
          _completedOrders.addAll(newCompletedOrders);
        }

        if (newCompletedOrders.isNotEmpty) {
          final orderIds =
              newCompletedOrders.map((order) => order.orderId).toList();
          await fetchOrderItems(orderIds, lang, context);
        }

        _hasMoreCompletedOrders = newCompletedOrders.length == pageSize;
      } else {
        throw Exception('Failed to load completed orders');
      }
    } catch (error) {
      print('Error fetching completed orders: $error');
      // Optionally, set an error message state
    } finally {
      _isLoadingCompletedOrders = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderItems(
      List<int> orderIds, String? lang, BuildContext context) async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return;
    }

    try {
      _isLoadingItems = true;
      notifyListeners();

      final client = ApiClient.createClient(_tokenService);
      final url = Uri.parse('${Config.getOrderItemsApi}?lang=$lang');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'orderIds': orderIds}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('items')) {
          final itemsList = (responseData['items'] as List<dynamic>)
              .map((itemData) => OrderItem.fromJson(itemData))
              .toList();

          final itemsMap = itemsList.groupBy((item) => item.orderId);

          for (var order in _orders) {
            if (itemsMap.containsKey(order.orderId)) {
              order.items.addAll(itemsMap[order.orderId]!);
            }
          }

          for (var completedOrder in _completedOrders) {
            if (itemsMap.containsKey(completedOrder.orderId)) {
              completedOrder.items.addAll(itemsMap[completedOrder.orderId]!);
            }
          }

          notifyListeners();
        } else {
          throw Exception('Unexpected response format for order items');
        }
      } else {
        throw Exception('Failed to fetch order items');
      }
    } catch (error) {
      print('Error fetching order items: $error');
      // Optionally, set an error message state
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreOrders({
    bool fetchCompleted = false,
    String? lang,
    required BuildContext context,
  }) async {
    print(
        'UserProvider: loadMoreOrders called with fetchCompleted: $fetchCompleted');

    try {
      if (!fetchCompleted && !_isLoadingOrders && _hasMoreOrders) {
        _currentPage++;
        await fetchOrders(page: _currentPage, lang: lang, context: context);
      } else if (fetchCompleted &&
          !_isLoadingCompletedOrders &&
          _hasMoreCompletedOrders) {
        _completedPage++;
        await fetchCompletedOrders(
            page: _completedPage, lang: lang, context: context);
      }
    } catch (error) {
      print('Error in loadMoreOrders: $error');
      // Optionally, you can rethrow the error or handle it as needed
      // throw error;
    }
  }

  Future<void> fetchUserAddress(
      String userId, String lang, BuildContext context) async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final client = ApiClient.createClient(_tokenService);
      final url = Uri.parse('${Config.getUserAddressApi}$userId/$lang');
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _userAddresses = List<Map<String, dynamic>>.from(responseData);
        _lastFetchTime = DateTime.now();
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception('Failed to fetch user address');
      }
    } catch (error) {
      print('Fetch address error: $error');
      // Optionally, set an error message state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(
      String userId, String addressId, BuildContext context) async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return;
    }

    _isLoading = true;
    notifyListeners();

    for (var address in _userAddresses) {
      address['is_default'] = address['id'].toString() == addressId ? 1 : 0;
    }
    notifyListeners();

    final url = Uri.parse('${Config.setDefaultAddressApi}');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'addressId': addressId}),
      );

      if (response.statusCode == 200) {
        await fetchUserAddress(userId, 'en', context);
      } else {
        throw Exception('Failed to set address as default');
      }
    } catch (error) {
      print('Error setting default address: $error');
      // Optionally, set an error message state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData(BuildContext context) async {
    if (_user != null) {
      final updatedUser = await _fetchUserById(_user!.id, context);
      setUser(updatedUser);
      await persistUserData(updatedUser);
    }
  }

  Future<User> _fetchUserById(String userId, BuildContext context) async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      throw Exception('No internet connection');
    }

    final url = Uri.parse('${Config.getUserApi}$userId');
    final client = ApiClient.createClient(_tokenService);

    final response = await client.get(url);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return User.fromJson(responseData);
    } else {
      final errorResponse = json.decode(response.body);
      throw Exception('Failed to fetch user data: ${errorResponse['message']}');
    }
  }

  Future<void> persistUserData(User user) async {
    final userService = UserService();
    await userService.signIn(user);
  }

  void updateUserAddresses(
      List<Map<String, dynamic>> addresses, BuildContext context) async {
    _userAddresses = addresses;
    notifyListeners();
    if (_user != null) {
      // Assuming 'en' as the language; modify as needed
      await fetchUserAddress(_user!.id, 'en', /* context */ context);
    }
  }

  Future<void> editUserName(String firstName, String lastName,
      String phoneNumber, BuildContext context) async {
    if (_user == null) return;

    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return;
    }

    final url = Uri.parse('${Config.updateUserNameApi}${_user!.id}');

    try {
      final client = ApiClient.createClient(_tokenService);
      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        await refreshUserData(context);
        if (_user != null) {
          await persistUserData(_user!);
        }
        notifyListeners();
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(
            'Failed to edit user name: ${errorResponse['message']}');
      }
    } catch (error) {
      print('Edit user name error: $error');
      throw Exception('Failed to edit user name: $error');
    }
  }

  Future<User?> fetchUserData(String userId, BuildContext context) async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return null;
    }

    final url = Uri.parse('${Config.getUserApi}$userId');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return User.fromJson(responseData);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(
            'Failed to fetch user data: ${errorResponse['message']}');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  Future<void> editUserEmail(
      String newEmail, String phoneNumber, BuildContext context) async {
    if (_user == null) return;

    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivityService.isConnected) {
      print('No internet connection');
      return;
    }

    final url = Uri.parse('${Config.updateUserEmailApi}${_user!.id}');

    try {
      final client = ApiClient.createClient(_tokenService);
      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': newEmail,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        await refreshUserData(context);
        if (_user != null) {
          await persistUserData(_user!);
        }
        notifyListeners();
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(
            'Failed to edit user email: ${errorResponse['message']}');
      }
    } catch (error) {
      print('Edit user email error: $error');
      throw Exception('Failed to edit user email: $error');
    }
  }

  // Implement the changePassword method
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${Config.changePasswordApi}');
    print('Attempting to change password with URL: $url');

    try {
      final client = ApiClient.createClient(_tokenService);
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _tokenService.getAccessToken()}',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns updated tokens upon password change
        final responseData = json.decode(response.body);
        final tokens = responseData['tokens'];

        if (tokens != null) {
          await _tokenService.saveTokens(
              tokens['accessToken'], tokens['refreshToken']);
        }

        // Optionally, you might want to sign out the user or refresh user data
        // For this example, we'll assume tokens are updated, and user remains signed in

        // Notify UI about success if needed
        // For example, you could set a success flag or send a callback
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Failed to change password.');
      }
    } catch (error) {
      print('Change password error: $error');
      throw Exception(error.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String cleanPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return phoneNumber.substring(1);
    }
    return phoneNumber;
  }
}
