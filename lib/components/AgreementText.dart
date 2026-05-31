import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/CustomCheckbox/CustomCheckbox.dart';
import 'package:saleem_dry_clean/screens/WebViewPage/web_view_page.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class AgreementText extends StatefulWidget {
  final double fem;
  final Function(bool) onChanged;

  const AgreementText({
    Key? key,
    required this.fem,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AgreementTextState createState() => _AgreementTextState();
}

class _AgreementTextState extends State<AgreementText> {
  bool _isChecked = false;

  final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer();

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openWebView(BuildContext context, String url, String titleKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewPage(
          url: url,
          titleKey: titleKey,
          fem: widget.fem,
          setLocale: (_) {},
          userSignedIn: false,
          currentLocale: Localizations.localeOf(context),
        ),
      ),
    );
  }

  void _toggleCheckbox(bool? value) {
    setState(() {
      _isChecked = value!;
      widget.onChanged(_isChecked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final String lang = isRtl ? 'ar' : 'en';

    _termsRecognizer.onTap = () => _openWebView(
          context,
          '${Config.termsAndConditionsUrl}?lang=$lang',
          'Terms of Use',
        );
    _privacyRecognizer.onTap = () => _openWebView(
          context,
          '${Config.privacyPolicyUrl}?lang=$lang',
          'Privacy Policy',
        );

    return Container(
      width: 380,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCheckbox(
            value: _isChecked,
            onChanged: _toggleCheckbox,
          ),
          SizedBox(width: 8 * widget.fem),
          Expanded(
            child: RichText(
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              text: TextSpan(
                text: localizations?.translate('agreement_part1') ??
                    'By signing up, you agree to our ',
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 14.0 * widget.fem,
                      fontWeight: FontWeight.w500,
                      height: 0,
                      color: AppColors.gray40),
                ),
                children: [
                  TextSpan(
                    text: localizations?.translate('terms_of_use') ??
                        'Terms of Use',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0 * widget.fem,
                          fontWeight: FontWeight.w600,
                          height: 0,
                          color: AppColors.gray80),
                    ),
                    recognizer: _termsRecognizer,
                  ),
                  TextSpan(
                    text:
                        localizations?.translate('agreement_part2') ?? ' and ',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0 * widget.fem,
                          fontWeight: FontWeight.w500,
                          height: 0,
                          color: AppColors.gray40),
                    ),
                  ),
                  TextSpan(
                    text: localizations?.translate('privacy_policy') ??
                        'Privacy Policy',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0 * widget.fem,
                          fontWeight: FontWeight.w600,
                          height: 0,
                          color: AppColors.gray80),
                    ),
                    recognizer: _privacyRecognizer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
