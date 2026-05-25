import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/CustomCard.dart';
import 'package:saleem_dry_clean/components/Modals/ChangeMobileNumberModal.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class PhoneNumberPage extends StatefulWidget {
  final double fem;
  final User user;

  const PhoneNumberPage({
    Key? key,
    required this.fem,
    required this.user,
  }) : super(key: key);

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  void _editPhoneNumberConfirmationModal() {
    ChangeMobileNumberConfirmationModal.show(context,
        prefixIconPath: 'assets/vectors/close_icon.svg', onPrefixIconTap: () {
      Navigator.of(context).pop();
    }, fem: widget.fem, phoneNumber: widget.user.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    print("isVerified");
    print(widget.user.isVerified);
    return Scaffold(
      backgroundColor: AppColors.gray10,
      appBar: AppHeader(
        quantityNumber: false,
        prefixIcon: BackButtonWidget(
          onTap: () {
            Navigator.pop(
                context); // Correct: Passes a function that calls Navigator.pop when tapped
          },
        ),
        title: localizations?.translate('Mobile_number') ?? 'Mobile number',
        fem: widget.fem,
        onPrefixIconTap: () {
          Navigator.pop(context);
        },
        onSuffixIconTap: () {
          // Handle user profile icon tap
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCard(
                  isVerified: widget.user.isVerified,
                  heightType: HeightType.big,
                  leadingIcon: true,
                  leadingIconPath:
                      'assets/Icons/mobileGradent.svg', // Ensure this path is correct
                  title: localizations?.translate('Mobile_number') ??
                      'Mobile number',
                  subtitle: widget.user.phoneNumber,
                  trailingIcon: true,
                  trailingIconPath:
                      'assets/Icons/edit.svg', // Ensure this path is correct
                  onTap: _editPhoneNumberConfirmationModal,
                  onTrailingIconTap: _editPhoneNumberConfirmationModal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
