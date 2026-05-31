import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/components/Modals/SmallModal.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class CheckoutSection extends StatelessWidget {
  final double fem;
  final double price;
  final int itemCount;

  const CheckoutSection({
    Key? key,
    required this.fem,
    required this.price,
    required this.itemCount,
  }) : super(key: key);

  void _handleCheckout(BuildContext context, UserProvider userProvider) {
    final localizations = AppLocalizations.of(context);

    if (!userProvider.userSignedIn) {
      SmallModal.show(
        isLoading: false,
        context,
        primaryButtonLable: 'Sign in',
        prefixIconPath: 'assets/vectors/close_icon.svg',
        onPrefixIconTap: () {
          Navigator.pop(context);
        },
        onPressed: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            NavigatorService.navigateTo(RouteNames.signIn);
          });
        },
        onCancel: () {
          Navigator.pop(context);
        },
        fem: fem,
        title: localizations?.translate('login_required') ?? 'Login Required',
        message: localizations?.translate('please_login_to_continue') ??
            'Please login to continue and send your message to support.',
      );
    } else {
      NavigatorService.navigateTo(RouteNames.checkout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(color: AppColors.white),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 84,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${localizations?.translate('Total') ?? 'Total'} ',
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray50(context).copyWith(
                          fontSize: 14.0 * fem,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '₪',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.bold16Gray80(context).copyWith(
                                fontSize: 18.0 * fem,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            price.toStringAsFixed(2),
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.bold16Gray80(context).copyWith(
                                fontSize: 18.0 * fem,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24 * fem),
              Expanded(
                child: LoadingButton(
                  buttonWidth: "large",
                  fem: fem,
                  buttonText:
                      '${localizations?.translate('Checkout') ?? 'Checkout'}  ($itemCount)',
                  onPressed: () => _handleCheckout(context, userProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
