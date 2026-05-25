import 'package:saleem_dry_clean/utils/CustomLengthFormatter/DateUtils.dart';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String id;
  final String gender;
  final String dateOfBirth;
  final bool isVerified;
  final List<Map<String, dynamic>> addresses;
  final List<String> deviceTokens; // New field for device tokens

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.id,
    required this.gender,
    required this.dateOfBirth,
    required this.isVerified,
    required this.addresses,
    required this.deviceTokens, // Initialize in constructor
  });

  // Add a copyWith method to allow partial updates
  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? id,
    String? gender,
    String? dateOfBirth,
    bool? isVerified,
    List<Map<String, dynamic>>? addresses,
    List<String>? deviceTokens, // Allow partial updates
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      id: id ?? this.id,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isVerified: isVerified ?? this.isVerified,
      addresses: addresses ?? this.addresses,
      deviceTokens: deviceTokens ?? this.deviceTokens, // Update if provided
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      id: json['id'].toString(),
      gender: json['gender'] as String? ?? '',
      dateOfBirth: DateUtils.formatDateToYYYYDDMM(
          json['date_of_birth'] as String? ?? ''),
      isVerified: json['is_verified'] == 1,
      addresses: List<Map<String, dynamic>>.from(json['addresses'] ?? []),
      deviceTokens:
          List<String>.from(json['device_tokens'] ?? []), // Parse device tokens
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'id': id,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'is_verified': isVerified ? 1 : 0,
      'addresses': addresses,
      'device_tokens': deviceTokens, // Include device tokens
    };
  }

  String get fullName => '$firstName $lastName';
}
