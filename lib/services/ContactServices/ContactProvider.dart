import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

class ContactProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final TokenService _tokenService;
  final UserProvider _userProvider;

  ContactProvider(this._tokenService, this._userProvider);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> sendContactForm({
    required String message,
    bool isGuest = false, // Default to false
    String? guestNumber, // Nullable string for guestNumber
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final userId = _userProvider.user?.id;
    print("sendContactForm");
    // Build contact data
    final contactData = {
      if (!isGuest) 'user_id': userId, // Add user_id if not a guest
      'message': message,
      if (isGuest) 'guest_number': guestNumber, // Add guest number if available
      'is_readed': false, // Default to false
    };

    print('Sending contact form data: $contactData');

    try {
      final client = ApiClient.createClient(_tokenService);
      final url =
          Uri.parse(Config.sendContactApi); // Define the correct API URL

      // Print the API URL for debugging purposes
      print('API URL: $url');

      // Get the access token (if authentication is required)
      final token = await _tokenService.getAccessToken();
      print(
          'User access token: $token'); // Optional: print the token for debugging

      // Send the POST request to the API
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Add Authorization header if needed
        },
        body: jsonEncode(contactData),
      );

      print('Contact form response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success handling
        _successMessage = 'Message sent successfully';
        print(_successMessage);
      } else {
        // Handle error response from the API
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to send message';
        print('Error message from API: $_errorMessage');
      }
    } catch (error) {
      // Handle exceptions
      _errorMessage = 'Error sending message: $error';
      print('Exception caught: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to close the modal and unfocus textarea
  void closeModal(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus(); // Unfocus globally
    Navigator.pop(context); // Close the modal
  }
}
