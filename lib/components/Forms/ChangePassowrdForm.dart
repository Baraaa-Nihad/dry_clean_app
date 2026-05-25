import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/ForgetPasswordModal.dart';
import 'package:saleem_dry_clean/components/Modals/SuccessModal.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ChangePasswordForm extends StatefulWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController repeatNewPasswordController;
  final FocusNode currentPasswordFocusNode;
  final FocusNode newPasswordFocusNode;
  final FocusNode repeatNewPasswordFocusNode;
  final VoidCallback onPasswordReset;
  final double fem;

  const ChangePasswordForm({
    Key? key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.repeatNewPasswordController,
    required this.currentPasswordFocusNode,
    required this.newPasswordFocusNode,
    required this.repeatNewPasswordFocusNode,
    required this.onPasswordReset,
    required this.fem,
  }) : super(key: key);

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isRepeatNewPasswordVisible = false;

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSuccess = false;

  final _formKey = GlobalKey<FormState>();
  bool get _notEmpty {
    return widget.currentPasswordController.text.isNotEmpty &&
        widget.newPasswordController.text.isNotEmpty &&
        widget.repeatNewPasswordController.text.isNotEmpty;
  }

  void _showSuccessModal(BuildContext context, String title, String message) {
    BlankModal.show(
      context,
      widget.fem,
      SuccessModal(
        title: title,
        message: message,
        mainButton: Builder(
          builder: (context) => PrimaryButton(
            fem: 1,
            text: AppLocalizations.of(context)?.translate('done') ?? 'Done',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword(User user) async {
    if (!_notEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      String mobileNumber = user.phoneNumber;
      String language = Localizations.localeOf(context).languageCode;

      final response = await http.post(
        Uri.parse('${Config.changePasswordApi}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mobile': mobileNumber,
          'password': widget.newPasswordController.text,
          'currentPassword': widget.currentPasswordController.text,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isSuccess = true;
        });
        widget.onPasswordReset();
        _showSuccessModal(
          context,
          AppLocalizations.of(context)?.translate('success') ?? 'Success!',
          AppLocalizations.of(context)
                  ?.translate('password_updated_successfully') ??
              'Your password has been updated successfully.',
        );
      } else {
        // Parse the error message from the backend
        final responseData = json.decode(response.body);
        setState(() {
          _hasError = true;
          _errorMessage = responseData['message'] ??
              (AppLocalizations.of(context)
                      ?.translate('failed_to_reset_password') ??
                  'Failed to reset password. Please try again.');
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage =
            AppLocalizations.of(context)?.translate('error_occurred') ??
                'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          children: [
            TextCustomInput(
              controller: widget.currentPasswordController,
              focusNode: widget.currentPasswordFocusNode,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                  });
                },
                child: SvgPicture.asset(
                  _isCurrentPasswordVisible
                      ? 'assets/vectors/textPassword.svg'
                      : 'assets/vectors/showPassword.svg',
                  width: 24,
                  height: 24,
                ),
              ),
              labelTextPrimary: localizations?.translate('current_password') ??
                  'Current password',
              inputType: _isCurrentPasswordVisible
                  ? InputType.text
                  : InputType.password,
              fem: widget.fem,
              onInputChange: (isValid) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations
                          ?.translate('please_enter_current_password') ??
                      'Please enter your current password';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextCustomInput(
              controller: widget.newPasswordController,
              focusNode: widget.newPasswordFocusNode,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
                child: SvgPicture.asset(
                  _isNewPasswordVisible
                      ? 'assets/vectors/textPassword.svg'
                      : 'assets/vectors/showPassword.svg',
                  width: 24,
                  height: 24,
                ),
              ),
              labelTextPrimary:
                  localizations?.translate('new_password') ?? 'New password',
              inputType:
                  _isNewPasswordVisible ? InputType.text : InputType.password,
              fem: widget.fem,
              onInputChange: (isValid) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations
                          ?.translate('please_enter_new_password') ??
                      'Please enter your new password';
                } else if (value.length < 8) {
                  return localizations
                          ?.translate('password_must_be_8_characters') ??
                      'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextCustomInput(
              controller: widget.repeatNewPasswordController,
              focusNode: widget.repeatNewPasswordFocusNode,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isRepeatNewPasswordVisible = !_isRepeatNewPasswordVisible;
                  });
                },
                child: SvgPicture.asset(
                  _isRepeatNewPasswordVisible
                      ? 'assets/vectors/textPassword.svg'
                      : 'assets/vectors/showPassword.svg',
                  width: 24,
                  height: 24,
                ),
              ),
              labelTextPrimary:
                  localizations?.translate('repeat_new_password') ??
                      'Repeat new password',
              inputType: _isRepeatNewPasswordVisible
                  ? InputType.text
                  : InputType.password,
              fem: widget.fem,
              onInputChange: (isValid) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations
                          ?.translate('please_repeat_new_password') ??
                      'Please repeat your new password';
                } else if (value != widget.newPasswordController.text) {
                  return localizations?.translate('passwords_do_not_match') ??
                      'Passwords do not match';
                }
                return null;
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 21),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '• ${localizations?.translate('password_must_be_8_characters') ?? 'Password must be at least 8 characters'}',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 13.0 * widget.fem,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray50),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryButton(
                  buttonWidth: "full",
                  text: _isLoading
                      ? (AppLocalizations.of(context)?.translate('loading') ??
                          'Loading...')
                      : (localizations?.translate('update_password') ??
                          'Update password'),
                  fem: widget.fem,
                  isDisabled: !_notEmpty || _isLoading,
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            FocusScope.of(context).unfocus();
                            _handleResetPassword(user!);
                          }
                        },
                ),
              ],
            ),
            if (_hasError)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (!_hasError)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 21),
              child: Align(
                alignment: Alignment.center,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();

                      BlankModal.show(
                        context,
                        widget.fem,
                        ForgetPasswordModal(fem: widget.fem),
                      );
                    },
                    child: Text(
                      localizations?.translate('forget_password') ??
                          'Forget password?',
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.bold16Gray80(context).copyWith(
                          fontSize: 16.sp,
                          color: AppColors.gray60,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
