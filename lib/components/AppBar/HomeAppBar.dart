import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Notification/QuantityIcon.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? prefixIconPath;
  final Widget? suffixIconPath;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onSuffixIconTap;
  final bool quantityNumber;
  final double fem;

  const HomeAppBar({
    Key? key,
    required this.quantityNumber,
    this.prefixIconPath,
    this.suffixIconPath,
    this.onPrefixIconTap,
    this.onSuffixIconTap,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.white.withOpacity(0.0)],
          stops: [0.3, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12).copyWith(top: 40),
        child: Row(
          children: [
            if (prefixIconPath != null)
              GestureDetector(
                onTap: onPrefixIconTap,
                child: Stack(
                  children: [
                    prefixIconPath!,
                  ],
                ),
              ),
            if (prefixIconPath == null) SizedBox(width: 0),
            Expanded(
              child: Align(
                alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${localizations?.translate('hi') ?? 'Hi'}, ',
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 20.0, fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextSpan(
                        text: user?.fullName ??
                            localizations?.translate('lets_sign_in') ??
                            'let’s sign in',
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.bold16Gray80(context).copyWith(
                              fontSize: 20.0, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  textAlign: isRtl ? TextAlign.end : TextAlign.start,
                ),
              ),
            ),
            if (suffixIconPath != null)
              GestureDetector(
                onTap: onSuffixIconTap,
                child: Stack(
                  children: [
                    suffixIconPath!,
                  ],
                ),
              ),
            if (suffixIconPath == null) SizedBox(width: 60),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120);
}
