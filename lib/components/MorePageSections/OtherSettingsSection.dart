import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/Cards/CustomCard.dart';
import 'package:saleem_dry_clean/components/Modals/LangSelectionModal.dart';
import 'package:saleem_dry_clean/screens/ContactUs/ContactPage.dart';
import 'package:saleem_dry_clean/screens/Feedback/FeedbackPage.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class OtherSettingsSection extends StatelessWidget {
  final Function(Locale) setLocale;
  final bool userSignedIn;
  final double fem;
  final Locale currentLocale;

  const OtherSettingsSection({
    Key? key,
    required this.setLocale,
    required this.userSignedIn,
    required this.fem,
    required this.currentLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    void _changeLanguage(String language) {
      if (language == 'en') {
        setLocale(Locale('en'));
      } else if (language == 'ar') {
        setLocale(Locale('ar'));
      }
    }

    void openLangModal() {
      String currentLanguage = currentLocale.languageCode;
      LangSelectionModal.show(
        context,
        fem,
        currentLanguage,
        (String currentLanguage) {
          _changeLanguage(currentLanguage);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations?.translate('Other') ?? "Other",
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0 * fem,
              fontWeight: FontWeight.w500,
              height: 0,
              color: AppColors.gray50,
            ),
          ),
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('App language') ?? "App language",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/comment.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: openLangModal,
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('Feedback & Suggestions') ??
              "Feedback & Suggestions",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/comment.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedbackPage(
                  setLocale: setLocale,
                  fem: fem,
                  userSignedIn: userSignedIn,
                  currentLocale: currentLocale,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('Contact us') ?? "Contact us",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/phone.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactPage(
                  setLocale: setLocale,
                  fem: fem,
                  userSignedIn: userSignedIn,
                  currentLocale: currentLocale,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('Privacy Policy') ?? "Privacy Policy",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/privacy.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {},
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('Terms of Use') ?? "Terms of Use",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/terms.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {},
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('Rate app') ?? "Rate app",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/rate.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/out.svg',
          onTap: () {},
        ),
      ],
    );
  }
}
