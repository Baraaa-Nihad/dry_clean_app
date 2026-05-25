// lib/services/Providers/AddressesProvider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'UserProvider.dart';

class AddressesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _addressNames = [];

  List<Map<String, dynamic>> get addresses => _addresses;
  List<Map<String, dynamic>> get addressNames => _addressNames;

  bool _isLoading = false;
  final TokenService _tokenService = TokenService();

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void initialize(List<Map<String, dynamic>> addresses) {
    _addresses = List<Map<String, dynamic>>.from(addresses);
    notifyListeners();
  }

  Future<void> fetchAddresses(String userId, String lang) async {
    setLoading(true);

    final url = Uri.parse('${Config.getUserAddressApi}$userId/$lang');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _addresses = List<Map<String, dynamic>>.from(responseData);
        print("_addresses_addresses_addresses_addresses");
        print(_addresses);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch addresses');
      }
    } catch (error) {
      print('Error fetching addresses: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchAddressNames() async {
    setLoading(true);

    final url = Uri.parse('${Config.getAddressNamesApi}');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List) {
          _addressNames = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic>) {
          _addressNames = [responseData];
          print(_addressNames);
        } else {
          throw Exception('Unexpected response type');
        }

        notifyListeners();
      } else {
        throw Exception('Failed to fetch address names');
      }
    } catch (error) {
      print('Error fetching address names: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> addAddress(Map<String, dynamic> address,
      UserProvider userProvider, String lang, BuildContext context) async {
    setLoading(true);

    final url = Uri.parse('${Config.addAddressApi}');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userProvider.user!.id,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        await fetchAddresses(
            userProvider.user!.id, lang); // Refetch addresses after adding
        userProvider.updateUserAddresses(
            _addresses, context); // Update UserProvider with new addresses
        notifyListeners();
      } else {
        throw Exception('Failed to add address');
      }
    } catch (error) {
      print('Error adding address: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> setDefaultAddress(
      String userId, String addressId, BuildContext context) async {
    setLoading(true);

    final url = Uri.parse('${Config.setDefaultAddressApi}');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'addressId': addressId}),
      );

      if (response.statusCode == 200) {
        await fetchAddresses(userId, 'en');
      } else {
        throw Exception('Failed to set address as default');
      }
    } catch (error) {
      print('Error setting default address: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateAddress(Map<String, dynamic> address,
      UserProvider userProvider, String lang, BuildContext context) async {
    print("updateAddress");
    setLoading(true);
    print("asdfasdfasdfsadfas");
    final url = Uri.parse('${Config.updateUserAddressApi}');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userProvider.user!.id,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        await fetchAddresses(
            userProvider.user!.id, lang); // Refetch addresses after updating
        userProvider.updateUserAddresses(
            _addresses, context); // Update UserProvider with new addresses
        notifyListeners();
      } else {
        throw Exception('Failed to update address');
      }
    } catch (error) {
      print('Error updating address: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    setLoading(true);

    final url = Uri.parse(
        '${Config.deleteAddressApi}?userId=$userId&addressId=$addressId');
    final client = ApiClient.createClient(_tokenService);

    try {
      final response = await client.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Address deleted successfully');
        await fetchAddresses(userId, 'en');
      } else {
        print(
            'Failed to delete address with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete address');
      }
    } catch (error) {
      print('Error deleting address: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> setDefault(Map<String, dynamic> address,
      UserProvider userProvider, BuildContext context) async {
    setLoading(true);

    await userProvider.setDefaultAddress(
        userProvider.user!.id, address['id'].toString(), context);

    await fetchAddresses(userProvider.user!.id, 'en');

    setLoading(false);
  }
}
