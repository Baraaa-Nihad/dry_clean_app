import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Forms/PhoneEditForm.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/SuccessModal.dart';
import 'package:saleem_dry_clean/components/Modals/VerificationCodeModal/VerificationCodeModal.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/services/Providers/sign_up_provider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ChangeMobileNumberConfirmationModal extends StatefulWidget {
  final String? prefixIconPath;
  final VoidCallback? onPrefixIconTap;
  final double fem;
  final String phoneNumber;

  const ChangeMobileNumberConfirmationModal({
    Key? key,
    this.prefixIconPath,
    this.onPrefixIconTap,
    required this.fem,
    required this.phoneNumber,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    String? prefixIconPath,
    VoidCallback? onPrefixIconTap,
    required double fem,
    required String phoneNumber,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => ChangeMobileNumberConfirmationModal(
        prefixIconPath: prefixIconPath,
        onPrefixIconTap: onPrefixIconTap,
        fem: fem,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  _ChangeMobileNumberConfirmationModalState createState() =>
      _ChangeMobileNumberConfirmationModalState();
}

class _ChangeMobileNumberConfirmationModalState
    extends State<ChangeMobileNumberConfirmationModal> {
  void _showFirstVerificationModal() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pop(); // Close the ChangeMobileNumberConfirmationModal first
    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      BlankModal.show(
        context,
        widget.fem,
        VerificationCodeModal(
          fem: widget.fem,
          nextPage: SuccessModal(
            title: 'Success!',
            message: 'Your mobile number has been updated successfully.',
            mainButton: PrimaryButton(
              fem: widget.fem,
              text: 'Done',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          nextPageType: NextPageType.modal,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      height: 322 * widget.fem,
      padding: EdgeInsets.symmetric(horizontal: 24 * widget.fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: SvgPicture.asset(widget.prefixIconPath!),
                onPressed: widget.onPrefixIconTap,
              ),
            ),
          ),
          Text(
            localizations.translate(
                'Are you sure you want to change your verified mobile number?'),
            textAlign: TextAlign.center,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                // height: 3,
                color: AppColors.gray80,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            localizations.translate(
                'You will use this mobile number for login purposes.'),
            textAlign: TextAlign.center,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: AppColors.gray60,
              ),
            ),
          ),
          SizedBox(height: 40 * widget.fem),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: PrimaryButton(
                    fem: widget.fem,
                    buttonWidth: "medium",
                    isDisabled: false,
                    text: localizations.translate('Continue'),
                    onPressed: _showFirstVerificationModal,
                  ),
                ),
                SizedBox(width: 16 * widget.fem),
                Expanded(
                  child: SecondaryButton(
                    fem: widget.fem,
                    buttonWidth: "medium",
                    isDisabled: false,
                    text: localizations.translate('cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 60 * widget.fem), // Space from the bottom
        ],
      ),
    );
  }
}
