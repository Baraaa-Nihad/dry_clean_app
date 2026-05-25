import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final String contact1;
  final String? contact2;
  final bool isPhoneNumber;

  const EmergencyCard({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.contact1,
    this.contact2,
    required this.isPhoneNumber,
  }) : super(key: key);

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _handleContact1Tap() {
    if (isPhoneNumber) {
      _launchUrl('https://wa.me/$contact1'); // WhatsApp URL scheme
    } else {
      _launchUrl('mailto:$contact1'); // Email URL scheme
    }
  }

  void _handleContact2Tap() {
    if (isPhoneNumber && contact2 != null) {
      _launchUrl('tel:$contact2'); // Phone dialer URL scheme
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE5EAF6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray60),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray40),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 32), // Add the same space as the icon and padding
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _handleContact1Tap,
                      child: Row(
                        children: [
                          // Ensure LTR direction for phone numbers
                          Directionality(
                            textDirection: isPhoneNumber
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            child: Text(
                              contact1,
                              style: AppTextStyles.getFontFamily(
                                context,
                                AppTextStyles.regular16Gray80(context).copyWith(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPhoneNumber && contact2 != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '|',
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray20),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleContact2Tap,
                        child: Row(
                          children: [
                            // Ensure LTR direction for contact2 if it is a phone number
                            Directionality(
                              textDirection: isPhoneNumber
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              child: Text(
                                contact2!,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular16Gray80(context)
                                      .copyWith(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.gray70),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
