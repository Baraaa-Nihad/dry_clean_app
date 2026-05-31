import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Ensure this import is correct

class BirdieLogo extends StatelessWidget {
  const BirdieLogo({Key? key}) : super(key: key);

  Future<void> _launchURL() async {
    const url = 'https://birdie.ps';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: _launchURL,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  localizations?.translate('By') ?? 'By',
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray50,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Baseline(
                  baseline: 12,
                  baselineType: TextBaseline.alphabetic,
                  child: SvgPicture.asset(
                    'assets/vectors/birdieLogo.svg',
                    width: 29,
                    height: 29,
                  ),
                ),
              ],
            ),
            Text(
              '${localizations?.translate('Version') ?? 'Version'} 1.0',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
