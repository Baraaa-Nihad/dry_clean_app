import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/Cards/CustomCard.dart';
import 'package:saleem_dry_clean/components/Modals/LangSelectionModal.dart';
import 'package:saleem_dry_clean/screens/ContactUs/ContactPage.dart';
import 'package:saleem_dry_clean/screens/Feedback/FeedbackPage.dart';
import 'package:saleem_dry_clean/screens/MorePage/favorite_stores_screen.dart';
import 'package:saleem_dry_clean/screens/MorePage/my_ratings_screen.dart';
import 'package:saleem_dry_clean/screens/MorePage/notification_settings_screen.dart';
import 'package:saleem_dry_clean/screens/WebViewPage/web_view_page.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
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
      LangSelectionModal.show(context, fem, currentLanguage, (
        String currentLanguage,
      ) {
        _changeLanguage(currentLanguage);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.translate('Other'),
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

        // ── إضافات صفحة الحساب (٢.١.٨) ──
        //
        // الثلاثة تخصّ المسجَّلين وحدهم: تقييمات زائر لا وجود لها،
        // ومفضّلته وإعداداته لا مكان يُحفظان فيه.
        if (userSignedIn) ...[
          CustomCard(
            heightType: HeightType.normal,
            title: localizations.translate('favorite_laundries'),
            leadingIcon: true,
            leadingIconPath: 'assets/Icons/favoriteLaundries.svg',
            trailingIcon: true,
            trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoriteStoresScreen()),
            ),
          ),
          SizedBox(height: 12),
          CustomCard(
            heightType: HeightType.normal,
            title: localizations.translate('my_ratings'),
            leadingIcon: true,
            leadingIconPath: 'assets/Icons/myRatings.svg',
            trailingIcon: true,
            trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyRatingsScreen()),
            ),
          ),
          SizedBox(height: 12),
          CustomCard(
            heightType: HeightType.normal,
            title: localizations.translate('notification_settings'),
            leadingIcon: true,
            leadingIconPath: 'assets/Icons/notificationSettings.svg',
            trailingIcon: true,
            trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],

        CustomCard(
          heightType: HeightType.normal,
          title: localizations.translate('app_language'),
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/appLanguage.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: openLangModal,
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations.translate('Feedback & Suggestions'),
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
          title: localizations.translate('Contact us'),
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
          title: localizations.translate('Privacy Policy'),
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/privacy.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            final lang = currentLocale.languageCode == 'ar' ? 'ar' : 'en';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WebViewPage(
                  url: '${Config.privacyPolicyUrl}?lang=$lang',
                  titleKey: 'Privacy Policy',
                  fem: fem,
                  setLocale: setLocale,
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
          title: localizations.translate('Terms of Use'),
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/terms.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            final lang = currentLocale.languageCode == 'ar' ? 'ar' : 'en';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WebViewPage(
                  url: '${Config.termsAndConditionsUrl}?lang=$lang',
                  titleKey: 'Terms of Use',
                  fem: fem,
                  setLocale: setLocale,
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
          title: localizations.translate('Rate app'),
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
