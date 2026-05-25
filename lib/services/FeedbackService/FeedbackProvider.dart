import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

class FeedbackProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final TokenService _tokenService;
  final UserProvider _userProvider;

  FeedbackProvider(this._tokenService, this._userProvider);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> sendFeedback({
    required String feedbackTypeId,
    required String feedbackType,
    required String message,
    required String lang,
    bool isGuest = false, // Default to false
    String? guestNumber, // Nullable string for guestNumber
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final userId = _userProvider.user?.id;

    // Build feedback data
    final feedbackData = {
      if (!isGuest) 'user_id': userId, // Add user_id if not a guest
      'feedback_type_id': feedbackTypeId,
      'feedbackType': feedbackType,
      'message': message,
      'lang': lang,
      if (isGuest) 'is_guest': 1, // Add is_guest if the user is a guest
      if (guestNumber != null)
        'guest_number': guestNumber, // Add guest number if available
    };

    print('Sending feedback data: $feedbackData');

    try {
      final client = ApiClient.createClient(_tokenService);
      final url = Uri.parse(Config.sendFeedbackApi);

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(feedbackData),
      );

      print('Feedback response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = 'Feedback sent successfully';
      } else {
        final errorResponse = json.decode(response.body);
        _errorMessage = errorResponse['message'] ?? 'Failed to send feedback';
      }
    } catch (error) {
      _errorMessage = 'Error sending feedback: $error';
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
