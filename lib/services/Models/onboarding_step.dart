// lib/models/onboarding_step.dart

class OnboardingStep {
  final int id;
  final String imageUrlEn;
  final String imageUrlAr;
  final String titleEn;
  final String titleAr;
  final String messageEn;
  final String messageAr;
  final String? subMessageEn;
  final String? subMessageAr;

  OnboardingStep({
    required this.id,
    required this.imageUrlEn,
    required this.imageUrlAr,
    this.titleEn = '',
    this.titleAr = '',
    required this.messageEn,
    required this.messageAr,
    this.subMessageEn,
    this.subMessageAr,
  });

  // Backend stores message_en as the primary heading and sub_message_en as body text.
  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      id: json['id'] as int,
      imageUrlEn: json['image_url_en'] as String? ?? '',
      imageUrlAr: json['image_url_ar'] as String? ?? '',
      titleEn:
          json['title_en'] as String? ?? json['message_en'] as String? ?? '',
      titleAr:
          json['title_ar'] as String? ?? json['message_ar'] as String? ?? '',
      messageEn: json['sub_message_en'] as String? ?? '',
      messageAr: json['sub_message_ar'] as String? ?? '',
      subMessageEn: null,
      subMessageAr: null,
    );
  }
}
