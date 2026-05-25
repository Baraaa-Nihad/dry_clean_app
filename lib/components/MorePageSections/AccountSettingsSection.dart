import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/Cards/CustomCard.dart';
import 'package:saleem_dry_clean/components/Forms/ChangePassowrdForm.dart';
import 'package:saleem_dry_clean/components/Modals/CustomModal.dart';
import 'package:saleem_dry_clean/screens/MorePage/MyAddressesPage.dart';
import 'package:saleem_dry_clean/screens/MorePage/PersonalInfoPage.dart';
import 'package:saleem_dry_clean/screens/MorePage/PhoneNumberPage.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Ensure you have this import for localization

class AccountSettingsSection extends StatefulWidget {
  final double fem;
  final User user;
  final Locale currentLocale;
  final VoidCallback onUserDataUpdated;

  const AccountSettingsSection({
    Key? key,
    required this.fem,
    required this.user,
    required this.currentLocale,
    required this.onUserDataUpdated, // Add the callback
  }) : super(key: key);

  @override
  _AccountSettingsSectionState createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController repeatNewPasswordController;

  late FocusNode currentPasswordFocusNode;
  late FocusNode newPasswordFocusNode;
  late FocusNode repeatNewPasswordFocusNode;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    repeatNewPasswordController = TextEditingController();

    currentPasswordFocusNode = FocusNode();
    newPasswordFocusNode = FocusNode();
    repeatNewPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    repeatNewPasswordController.dispose();

    currentPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    repeatNewPasswordFocusNode.dispose();
    super.dispose();
  }

  void _changePassword() {
    CustomModal.show(
      context,
      mainTitle: AppLocalizations.of(context)?.translate('Change Password') ??
          'Change Password',
      fem: widget.fem,
      isDisabledButton: false,
      onPrefixIconTap: () {
        Navigator.pop(context);
      },
      prefixIconPath: 'assets/vectors/close_icon.svg',
      content: ChangePasswordForm(
        currentPasswordController: currentPasswordController,
        newPasswordController: newPasswordController,
        repeatNewPasswordController: repeatNewPasswordController,
        currentPasswordFocusNode: currentPasswordFocusNode,
        newPasswordFocusNode: newPasswordFocusNode,
        repeatNewPasswordFocusNode: repeatNewPasswordFocusNode,
        fem: widget.fem,
        onPasswordReset: () {
          // Handle post-password reset actions, e.g., refresh user data
          widget.onUserDataUpdated();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 20),
        Text(
          localizations?.translate('Account settings') ?? "Account settings",
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
                fontSize: 16.0 * widget.fem,
                fontWeight: FontWeight.w500,
                height: 0,
                color: AppColors.gray50),
          ),
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('Personal information') ??
              "Personal information",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/personGradent.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalInfoPage(
                  fem: widget.fem,
                  userId: widget.user.id,
                  onUserDataUpdated: widget.onUserDataUpdated,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('mobile_number') ??
              "Update mobile number",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/mobileGradent.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhoneNumberPage(
                  fem: widget.fem,
                  user: widget.user,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title:
              localizations?.translate('Change password') ?? "Change password",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/changePassword.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            _changePassword();
          },
        ),
        SizedBox(height: 12),
        CustomCard(
          heightType: HeightType.normal,
          title: localizations?.translate('My addresses') ?? "My addresses",
          leadingIcon: true,
          leadingIconPath: 'assets/Icons/locationGradent.svg',
          trailingIcon: true,
          trailingIconPath: 'assets/Icons/rightSmallArrow.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAddressesPage(
                  fem: widget.fem,
                  user: widget.user,
                  currentLocale: widget.currentLocale,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
