import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AgreementText.dart';
import 'package:saleem_dry_clean/components/DividerWithText.dart';
import 'package:saleem_dry_clean/components/Modals/VerificationCodeModal/VerificationCodeModal.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/MobileNumberInput.dart';
import 'package:saleem_dry_clean/services/Providers/sign_up_provider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/screens/SignUpPage/RegistrationForm.dart';

class SignUp extends StatelessWidget {
  final double fem;
  final Function(Locale) setLocale;
  final Locale currentLocale;
  const SignUp({
    Key? key,
    required this.fem,
    required this.setLocale,
    required this.currentLocale,
  }) : super(key: key);

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpProvider(),
      child: Consumer<SignUpProvider>(
        builder: (context, provider, child) {
          double fem = MediaQuery.of(context).size.width / 428;
          final localizations = AppLocalizations.of(context);
          bool isRtl = Directionality.of(context) == TextDirection.rtl;

          void _handleContinue() async {
            if (provider.isButtonEnabled) {
              provider.clearError(); // Clear error message
              final language = Localizations.localeOf(context).languageCode;
              provider.setLoading(true);

              await provider.sendOtp(language);
              provider.setLoading(false);

              if (provider.errorMessage == null) {
                BlankModal.show(
                  context,
                  fem,
                  VerificationCodeModal(
                    fem: fem,
                    nextPage: RegistrationForm(),
                    nextPageType: NextPageType.page,
                  ),
                );
              } else {
                provider.setLoading(false);
                provider.isButtonEnabled = false;
                provider.notifyListeners();
              }
            }
          }

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SafeArea(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24 * fem,
                                vertical: 24 * fem,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 92 * fem),
                                  Text(
                                    localizations?.translate('signup') ??
                                        'Signup',
                                    style: AppTextStyles.getFontFamily(
                                      context,
                                      AppTextStyles.bold16Gray80(context)
                                          .copyWith(
                                        fontSize: 24.0 * fem,
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8 * fem),
                                  Text(
                                    localizations?.translate('join_now') ??
                                        'Join now. Laundry made simple',
                                    style: AppTextStyles.getFontFamily(
                                      context,
                                      AppTextStyles.regular16Gray50(context)
                                          .copyWith(
                                        fontSize: 13.0 * fem,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 40 * fem),
                                  MobileNumberInput(
                                    controller: provider.mobileNumberController,
                                    focusNode: provider.mobileFocusNode,
                                    fem: fem,
                                    enableValidation: true,
                                    labelTextPrimary: localizations
                                            ?.translate('mobile_number') ??
                                        'Mobile Number',
                                    countryCodes: ['+970', '+972'],
                                    onCountryCodeChanged:
                                        provider.onCountryCodeChanged,
                                    onInputChange: (isValid) {
                                      provider.onInputChange(isValid);
                                    },
                                    isRtl: isRtl,
                                  ),
                                  SizedBox(height: 5 * fem),
                                  if (provider.errorMessage != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: Align(
                                        alignment: isRtl
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(provider.errorMessage!,
                                            style: AppTextStyles.getFontFamily(
                                              context,
                                              AppTextStyles.regular16Gray80(
                                                      context)
                                                  .copyWith(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                height: 1.5,
                                                color: AppColors.red,
                                              ),
                                            )),
                                      ),
                                    ),
                                  SizedBox(height: 5 * fem),
                                  AgreementText(
                                    fem: fem,
                                    onChanged: provider.toggleAgreement,
                                  ),
                                  SizedBox(height: 24 * fem),
                                  Container(
                                    width: double.infinity,
                                    child: LoadingButton(
                                      fem: fem,
                                      isLoading: provider.isLoading,
                                      buttonText: localizations
                                              ?.translate('continue') ??
                                          'Continue',
                                      onPressed: provider.isButtonEnabled
                                          ? _handleContinue
                                          : null,
                                      isDisabled: !provider.isButtonEnabled,
                                    ),
                                  ),
                                  SizedBox(height: 24 * fem),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: AppColors.transparent,
                            padding: EdgeInsets.only(
                              left: 24 * fem,
                              right: 24 * fem,
                              bottom: 24 * fem,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                DividerWithText(
                                  text: localizations
                                          ?.translate('have_account') ??
                                      'Have an account?',
                                  fem: fem,
                                ),
                                SizedBox(height: 170 * fem),
                                Container(
                                  width: double.infinity,
                                  child: SecondaryButton(
                                    fem: fem,
                                    text: localizations?.translate('log_in') ??
                                        'Log in',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -245 * fem,
                      right: -161 * fem,
                      child: Opacity(
                        opacity: 0.05,
                        child: Container(
                          width: 428 * fem,
                          height: 428 * fem,
                          decoration: ShapeDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.5,
                              colors: [
                                AppColors.green,
                                AppColors.blue.withOpacity(0)
                              ],
                              stops: [0.5, 1.0],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20 * fem,
                      left: -20 * fem,
                      child: Opacity(
                        opacity: 0.05,
                        child: Container(
                          width: 104 * fem,
                          height: 104 * fem,
                          decoration: ShapeDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.5,
                              colors: [
                                AppColors.green,
                                AppColors.blue.withOpacity(0)
                              ],
                              stops: [0.5, 1.0],
                            ),
                            shape: OvalBorder(),
                          ),
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
