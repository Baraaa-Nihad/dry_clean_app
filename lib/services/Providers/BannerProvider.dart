import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';

class BannerProvider with ChangeNotifier {
  final TokenService _tokenService;
  List<String> _bannerImages = [];
  DateTime? _lastFetchedTime; // Track the last time data was fetched
  String? _lastLang; // Track the last language used

  BannerProvider(this._tokenService);

  List<String> get bannerImages => _bannerImages;

  // Fetch banner images with language parameter
  Future<void> fetchBannerImages(String lang) async {
    // Check if cached data is still valid (within 1 hour) and if language is the same
    if (_lastFetchedTime != null &&
        DateTime.now().difference(_lastFetchedTime!).inMinutes < 60 &&
        _lastLang == lang) {
      print('Using cached banner images.');
      return; // Return the cached data
    }

    final url = Uri.parse(
        '${Config.getBanners}?lang=$lang'); // Append 'lang' parameter to URL
    print('Attempting to fetch banner images from URL: $url');

    try {
      // Create the client using the token service
      final client = ApiClient.createClient(_tokenService);

      // Make a GET request
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Banner images fetched successfully.');
        print(response.body);

        // Parse the response body
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Check if success is true and data is present
        if (responseBody['success'] == true && responseBody['data'] is List) {
          final List<dynamic> data = responseBody['data'];

          // Clear existing banner images before updating
          _bannerImages.clear();

          // Populate _bannerImages with URLs from the 'imagePath' field in the response
          _bannerImages = data
              .map((item) {
                final imageObj = lang == 'ar' ? item['image_ar'] : item['image_en'];
                final String? raw = imageObj?['image_path'] as String?;
                return Config.resolveImageUrl(raw);
              })
              .where((url) => url.isNotEmpty)
              .toList();

          // Update the last fetched time and language
          _lastFetchedTime = DateTime.now();
          _lastLang = lang;

          // Notify listeners that the data has been updated
          notifyListeners();
        } else {
          throw Exception('Unexpected response format.');
        }
      } else {
        throw Exception(
            'Failed to load banner images. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error: Clear banner images on failure and log the error
      _bannerImages.clear();
      print('Error fetching banner images: $error');
      notifyListeners();
    }
  }
}
