import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/services/Providers/ForgetPasswordProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ForgetPasswordModal extends StatelessWidget {
  final double fem;

  const ForgetPasswordModal({
    Key? key,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ForgetPasswordProvider();
        provider.reset();
        return provider;
      },
      child: Consumer<ForgetPasswordProvider>(
        builder: (context, provider, child) {
          final localizations = AppLocalizations.of(context);

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.0 * fem)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 56 * fem,
              minHeight: MediaQuery.of(context).size.height - 56 * fem,
            ),
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/vectors/close_icon.svg',
                            width: 48.0 * fem,
                            height: 48.0 * fem,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 16.0 * fem),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.translate('reset_password') ??
                              'Reset Password',
                          textAlign: TextAlign.left,
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.bold16Gray80(context).copyWith(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0 * fem),
                        Text(
                          localizations
                                  ?.translate('enter_mobile_to_receive_code') ??
                              "Please enter your mobile number to receive a verification code.",
                          textAlign: TextAlign.left,
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray50(context).copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.0 * fem),
                    TextCustomInput(
                      controller: provider.mobileController,
                      inputType: InputType.number,
                      focusNode: FocusNode(),
                      labelTextPrimary:
                          localizations?.translate('mobile_number') ??
                              'Mobile Number',
                      fem: fem,
                      isDisabled: false,
                      onInputChange: (isValid) {
                        provider.onInputChange(isValid);
                      },
                    ),
                    if (provider.errorMessage != null)
                      Padding(
                          padding: EdgeInsets.only(top: 8.0 * fem),
                          child: Text(
                            provider.errorMessage!,
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.red,
                              ),
                            ),
                          )),
                    SizedBox(height: 24.0 * fem),
                    Container(
                      width: double.infinity,
                      child: PrimaryButton(
                        fem: fem,
                        isDisabled: provider.isButtonDisabled,
                        text: localizations?.translate('send_code') ??
                            'Send Code',
                        onPressed: provider.isButtonDisabled
                            ? null
                            : () {
                                provider.sendMobileNumber(context, fem);
                              },
                      ),
                    ),
                    if (provider.isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 8.0 * fem),
                        child: Center(
                          child: LoadingDots(
                            fem: fem,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
