// lib/components/buttons/LanguageToggleButton.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import AppLocalizations

class LanguageButton extends StatelessWidget {
  const LanguageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<LanguageProvider, bool>(
      selector: (_, provider) => provider.locale.languageCode == 'en',
      builder: (context, isEnglish, child) {
        // Access localization if needed
        final AppLocalizations? localizations = AppLocalizations.of(context);

        return SizedBox(
          width: 100.w, // Fixed width of 120 units
          height: 50.h, // Fixed height of 50 units
          child: InkWell(
            onTap: () {
              // Toggle the language when the button is pressed
              Provider.of<LanguageProvider>(context, listen: false)
                  .toggleLanguage();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: const Color(0xFFE5EAF6)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    isEnglish ? 'العربية' : 'English',
                    key: ValueKey<bool>(isEnglish),
                    style: AppTextStyles.getFontFamilyReverse(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray80,
                      ),
                    ),
                    semanticsLabel:
                        isEnglish ? 'Switch to Arabic' : 'Switch to English',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
