import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/ResetPasswordModal.dart';
import 'package:saleem_dry_clean/components/Modals/SuccessModal.dart';
import 'package:saleem_dry_clean/components/Modals/VerificationCodeModal/VerificationCodeModal.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ForgetPasswordProvider with ChangeNotifier {
  final TextEditingController mobileController = TextEditingController();
  bool isButtonDisabled = true;
  String? errorMessage;
  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool validateMobileNumber(String mobileNumber) {
    if (mobileNumber.startsWith('0') && mobileNumber.length == 10) {
      return true;
    } else if (mobileNumber.startsWith('5') && mobileNumber.length == 9) {
      return true;
    } else if ((mobileNumber.startsWith('972') ||
            mobileNumber.startsWith('970')) &&
        mobileNumber.length == 12) {
      return true;
    } else if (mobileNumber.startsWith('+') && mobileNumber.length == 13) {
      return true;
    }
    return false;
  }

  Future<void> sendMobileNumber(BuildContext context, double fem) async {
    final localizations = AppLocalizations.of(context);
    final isValid = validateMobileNumber(mobileController.text);
    final language = Localizations.localeOf(context).languageCode;

    if (isValid) {
      _setLoading(true);
      errorMessage = null;

      try {
        final userExistsUrl = Uri.parse('${Config.CheckUserApi}');
        final userExistsResponse = await http.post(
          userExistsUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'mobile': mobileController.text}),
        );
        final userExistsData = json.decode(userExistsResponse.body);

        if (userExistsResponse.statusCode == 200 && userExistsData['success']) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mobileNumber', userExistsData['mobile']);

          final sendOtpUrl = Uri.parse('${Config.CheckMobileApi}');
          final sendOtpResponse = await http.post(
            sendOtpUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'mobile': userExistsData['mobile'],
              'language': language,
            }),
          );
          final sendOtpData = json.decode(sendOtpResponse.body);

          if (sendOtpResponse.statusCode == 200) {
            if (context.mounted) {
              // Update the existing modal content instead of opening a new one
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final blankModalState =
                    context.findAncestorStateOfType<BlankModalState>();
                if (blankModalState != null) {
                  blankModalState.updateContent(
                    VerificationCodeModal(
                      fem: fem,
                      nextPage: ResetPasswordModal(
                        fem: fem,
                        onPasswordReset: () {
                          onPasswordResetSuccess(context, fem);
                        },
                      ),
                      nextPageType: NextPageType.modal,
                    ),
                  );
                }
              });
            }
          } else {
            errorMessage = sendOtpData['message'] ??
                localizations?.translate('failed_to_send_code') ??
                "Failed to send code. Please try again.";
          }
        } else {
          errorMessage = userExistsData['message'] ??
              localizations?.translate('user_not_exist') ??
              "User does not exist. Please check the mobile number.";
        }
      } catch (error) {
        errorMessage = localizations?.translate('error_occurred') ??
            "An error occurred. Please try again.";
      } finally {
        _setLoading(false);
      }
    } else {
      errorMessage = localizations?.translate('check_mobile_number') ??
          "Please check the mobile number.";
    }
    notifyListeners();
  }

  void onInputChange(bool isValid) {
    isButtonDisabled = !isValid || mobileController.text.isEmpty;
    notifyListeners();
  }

  void onPasswordResetSuccess(BuildContext context, double fem) {
    // Use a local variable to store the current context
    final localizations = AppLocalizations.of(context);
    if (context.mounted) {
      final currentContext = context;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentContext.mounted) {
          final blankModalState =
              currentContext.findAncestorStateOfType<BlankModalState>();
          if (blankModalState != null) {
            blankModalState.updateContent(
              SuccessModal(
                title: localizations?.translate('success') ?? 'Success!',
                message: localizations?.translate('password_reset_success') ??
                    'Your password has been reset successfully.',
                mainButton: PrimaryButton(
                  fem: fem,
                  text: 'done',
                  onPressed: () {
                    Navigator.pop(currentContext);
                  },
                ),
              ),
            );
          }
        }
      });
    }
  }

  void reset() {
    mobileController.clear();
    isButtonDisabled = true;
    errorMessage = null;
    notifyListeners();
  }
}
