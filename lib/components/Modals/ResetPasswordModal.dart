import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Modals/SuccessModal.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';

class ResetPasswordModal extends StatefulWidget {
  final double fem;
  final VoidCallback onPasswordReset;

  const ResetPasswordModal({
    Key? key,
    required this.fem,
    required this.onPasswordReset,
  }) : super(key: key);

  @override
  _ResetPasswordModalState createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends State<ResetPasswordModal> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSuccess = false;
  String _errorMessage = '';

  void _validateForm() {
    bool isPasswordValid = _passwordController.text.length >= 8;
    bool isConfirmPasswordValid =
        _confirmPasswordController.text == _passwordController.text;

    setState(() {
      _isButtonEnabled = isPasswordValid && isConfirmPasswordValid;
    });
  }

  Future<void> _handleResetPassword() async {
    if (_isButtonEnabled) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final prefs = await SharedPreferences.getInstance();
      String mobileNumber = prefs.getString('mobileNumber') ?? '';
      String language = Localizations.localeOf(context).languageCode;

      try {
        final response = await http.post(
          Uri.parse('${Config.resetPasswordApi}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'mobile': mobileNumber,
            'password': _passwordController.text,
            'language': language,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _isSuccess = true;
          });
          widget.onPasswordReset();
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = AppLocalizations.of(context)
                    ?.translate('failed_to_reset_password') ??
                'Failed to reset password. Please try again.';
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
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final fem = widget.fem;

    if (_isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final blankModalState =
            context.findAncestorStateOfType<BlankModalState>();
        if (blankModalState != null) {
          blankModalState.updateContent(
            SuccessModal(
              title: localizations?.translate('success') ?? 'Success!',
              message: localizations?.translate('password_reset_success') ??
                  'Your password has been reset successfully.',
              mainButton: Builder(
                builder: (context) => LoadingButton(
                  fem: fem,
                  buttonText: localizations?.translate('done') ?? 'Done',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          );
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0 * fem)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text(
            localizations?.translate('reset_password') ?? 'Reset Password',
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.bold16Gray80(context).copyWith(
                fontSize: 24.0 * fem,
              ),
            ),
          ),
          SizedBox(height: 8.0 * fem),
          Text(
            localizations?.translate('enter_new_password') ??
                'Enter your new password below.',
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray50(context).copyWith(
                fontSize: 13.0 * fem,
              ),
            ),
          ),
          SizedBox(height: 16.0 * fem),
          TextCustomInput(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            inputType: _isPasswordVisible ? InputType.text : InputType.password,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              child: SvgPicture.asset(
                _isPasswordVisible
                    ? 'assets/vectors/textPassword.svg'
                    : 'assets/vectors/showPassword.svg',
                width: 24,
                height: 24,
              ),
            ),
            labelTextPrimary:
                localizations?.translate('New Password') ?? 'New password',
            fem: fem,
            onInputChange: (isValid) {
              _validateForm();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations?.translate('please_enter_password') ??
                    'Please enter your password';
              } else if (value.length < 8) {
                return localizations?.translate('password_too_short') ??
                    'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0 * fem),
          TextCustomInput(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            inputType:
                _isConfirmPasswordVisible ? InputType.text : InputType.password,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              child: SvgPicture.asset(
                _isConfirmPasswordVisible
                    ? 'assets/vectors/textPassword.svg'
                    : 'assets/vectors/showPassword.svg',
                width: 24,
                height: 24,
              ),
            ),
            labelTextPrimary:
                localizations?.translate('confirm_new_password') ??
                    'Confirm New Password',
            fem: fem,
            onInputChange: (isValid) {
              _validateForm();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations?.translate('please_repeat_password') ??
                    'Please repeat your password';
              } else if (value != _passwordController.text) {
                return localizations?.translate('passwords_do_not_match') ??
                    'Passwords do not match';
              }
              return null;
            },
          ),
          if (_hasError)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0 * fem),
              child: Text(
                _errorMessage,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.red,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 24.0 * fem),
          Container(
            width: double.infinity,
            child: LoadingButton(
              fem: fem,
              buttonText: localizations?.translate('reset_password_button') ??
                  'Reset Password',
              isLoading: _isLoading,
              isDisabled: !_isButtonEnabled,
              onPressed: _isButtonEnabled ? _handleResetPassword : null,
            ),
          ),
        ],
      ),
    );
  }
}
