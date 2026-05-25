import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class EmptyAddressCard extends StatelessWidget {
  final VoidCallback onAddNew;

  const EmptyAddressCard({Key? key, required this.onAddNew}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 276.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 160),
                  Container(
                    width: 182,
                    height: 182,
                    decoration: ShapeDecoration(
                      color: Color(0xFFF9F9FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: SvgPicture.asset('assets/Icons/Address.svg'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.translate('no_address_added') ??
                        'No address added',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          height: 2.7,
                          color: AppColors.gray70),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.translate(
                            'Add_new_address_to_be_saved_in_your_profile') ??
                        'Add new address to be saved in your profile',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          height: 2.1,
                          color: AppColors.gray50),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    prefixIcon: "assets/Icons/AddButtonIcon.svg",
                    buttonWidth: "full",
                    fem: 1,
                    text: localizations.translate('add_new') ?? 'Add New',
                    onPressed: onAddNew,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
