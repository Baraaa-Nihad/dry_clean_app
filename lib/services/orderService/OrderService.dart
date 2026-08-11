import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'dart:convert';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';

class OrderService {
  final TokenService _tokenService;

  // Pass TokenService via the constructor
  OrderService(this._tokenService);

  // Method to fetch a single order by orderId
  Future<OrderData> getOrderById(int orderId, {required String language}) async {
    try {
      // Create the API client
      final client = ApiClient.createClient(_tokenService);

      // Define the correct API URL with the orderId
      final url = Uri.parse('${Config.getOrder}/$orderId').replace(
        queryParameters: {'lang': language},
      );

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

      // Handle success and error responses
      if (response.statusCode == 200) {
        // Parse the response body into a single OrderData object
        final jsonData = json.decode(response.body);
        return OrderData.fromJson(jsonData['data']);
      } else {
        // Handle error response from the API
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Failed to load order';
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Handle exceptions
      throw Exception('Error fetching order: $error');
    }
  }
}
