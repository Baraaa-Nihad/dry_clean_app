import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'dart:convert';
import 'package:saleem_dry_clean/services/Models/Order.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';

class OrderService {
  final TokenService _tokenService;

  // Pass TokenService via the constructor
  OrderService(this._tokenService);

  // Method to fetch a single order by orderId
  Future<OrderData> getOrderById(int orderId) async {
    try {
      // Create the API client
      final client = ApiClient.createClient(_tokenService);

      // Define the correct API URL with the orderId
      final url = Uri.parse('${Config.getOrder}/$orderId');

      // Get the access token (if authentication is required)
      final token = await _tokenService.getAccessToken();

      // Send the GET request to the API
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Add Authorization header if needed
        },
      );

      print('Order response: ${response.statusCode} - ${response.body}');

      // Handle success and error responses
      if (response.statusCode == 200) {
        // Parse the response body into a single OrderData object
        final jsonData = json.decode(response.body);
        return OrderData.fromJson(jsonData['data']);
      } else {
        // Handle error response from the API
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Failed to load order';
        print('Error message from API: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Handle exceptions
      print('Exception caught: $error');
      throw Exception('Error fetching order: $error');
    }
  }
}
