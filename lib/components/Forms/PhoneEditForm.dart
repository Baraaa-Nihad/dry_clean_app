import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/MobileNumberInput.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class PhoneEditForm extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocusNode;
  final String? phoneValue;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final double fem;

  const PhoneEditForm({
    Key? key,
    required this.phoneController,
    this.phoneValue,
    required this.phoneFocusNode,
    required this.onSave,
    required this.onCancel,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0 * fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0 * fem)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 56 * fem,
        minHeight: MediaQuery.of(context).size.height - 56 * fem,
      ),
      child: SingleChildScrollView(
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
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Gradient shadow
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: 76 * fem,
                            height: 76 * fem,
                            decoration: ShapeDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.5,
                                colors: [
                                  Color(0xFF00E213),
                                  Color(0xFF01B5CF).withOpacity(0)
                                ],
                                stops: [0.5, 1.0],
                              ),
                              shape: OvalBorder(),
                            ),
                          ),
                        ),
                      ),
                      // Phone icon
                      SvgPicture.asset(
                        'assets/vectors/phone_icon.svg',
                        width: 76.0 * fem,
                        height: 76.0 * fem,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0 * fem),
                  Container(
                    width: 380 * fem,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'The code sent to your \n mobile number',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.bold16Gray80(context).copyWith(
                              fontSize: 24.0 * fem,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0 * fem),
                        MobileNumberInput(
                          controller: phoneController,
                          focusNode: phoneFocusNode,
                          hasError: false,
                          fem: fem,
                          enableValidation: true,
                          labelTextPrimary: 'New Mobile Number',
                          countryCodes: ['+970', '+972'],
                          onCountryCodeChanged: (code) {},
                          onInputChange: (isValid) {},
                          isRtl: false,
                        ),
                        SizedBox(height: 24 * fem),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PrimaryButton(
                              buttonWidth: "petiteMedium",
                              text: 'Save',
                              fem: fem,
                              onPressed: onSave,
                            ),
                            SizedBox(width: 24),
                            SecondaryButton(
                              buttonWidth: "petiteMedium",
                              text: 'Cancel',
                              fem: fem,
                              onPressed: onCancel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
