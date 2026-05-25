import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Modals/VerificationCodeModal/CodeInputField.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/theme/app_theme.dart';
import 'package:saleem_dry_clean/utils/TimerText.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/services/Providers/sign_up_provider.dart';
import '../BlankModal.dart'; // Import the BlankModal here

enum NextPageType { modal, page }

class VerificationCodeModal extends StatefulWidget {
  final double fem;
  final Widget nextPage;
  final NextPageType nextPageType;

  const VerificationCodeModal({
    Key? key,
    required this.fem,
    required this.nextPage,
    required this.nextPageType,
  }) : super(key: key);

  @override
  _VerificationCodeModalState createState() => _VerificationCodeModalState();
}

class _VerificationCodeModalState extends State<VerificationCodeModal> {
  bool _showResendButton = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isError = false;
  bool _isVerifying = false;
  String mobileNumber = '';
  String _errorMessage = '';
  final int _timerDuration = 60; // Duration for timer in seconds
  final TextEditingController _controller = TextEditingController();

  // --- TEMPORARY OTP BYPASS ---
  // SMS subscription has expired. Backend stores '0000' as the OTP for every
  // registration. On open we auto-fill and submit so the user sees no friction.
  // Remove this override (and the initState call) when SMS is renewed.
  static const _bypassOtp = '0000';

  @override
  void initState() {
    super.initState();
    // Auto-submit the bypass OTP after a short delay so the modal fully renders first.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _controller.text = _bypassOtp;
        _checkCodeCompletion(_bypassOtp);
      }
    });
  }
  // --- END BYPASS ---

  void _onTimerComplete() {
    setState(() {
      _showResendButton = true;
    });
  }

  Future<void> _resendCode() async {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    await signUpProvider.loadMobileNumber();
    final language = Localizations.localeOf(context).languageCode;

    setState(() {
      _showResendButton = false;
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    bool canSend = await signUpProvider.canSendOtp(language);

    if (canSend) {
      await signUpProvider.sendOtp(language);
    } else {
      setState(() {
        _isError = true;
        _errorMessage = signUpProvider.errorMessage ??
            'Too many requests. Please try again later.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkCodeCompletion(String value) async {
    final code = value.trim();

    if (_isVerifying) return;

    if (code.length == 4) {
      _isVerifying = true;
      setState(() {
        _isLoading = true;
        _showResendButton = false;
        _isError = false;
        _errorMessage = '';
      });

      final signUpProvider =
          Provider.of<SignUpProvider>(context, listen: false);
      signUpProvider.otpController.text = code;
      final language = Localizations.localeOf(context).languageCode;

      try {
        await signUpProvider.loadMobileNumber();
        await signUpProvider.verifyOtp(language, context, () {
          if (!mounted) return;
          setState(() {
            _isSuccess = true;
            _isError = false;
            _errorMessage = '';
          });

          // Navigate to the next page based on the type
          if (widget.nextPageType == NextPageType.page) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => widget.nextPage),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final blankModalState =
                  context.findAncestorStateOfType<BlankModalState>();
              if (blankModalState != null) {
                blankModalState.updateContent(widget.nextPage);
              }
            });
          }
        });

        if (!mounted) return;

        if (signUpProvider.errorMessage != null) {
          setState(() {
            _isSuccess = false;
            _isError = true;
            _errorMessage = signUpProvider.errorMessage!;
            _showResendButton = true; // Re-enable the resend button
          });
        }
      } finally {
        _isVerifying = false;
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isSuccess = false;
        _isError = false;
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    signUpProvider.loadMobileNumber().then((value) {
      setState(() {
        mobileNumber = signUpProvider.mobileNumber;
      });
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16.0 * widget.fem)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 56 * widget.fem,
        minHeight: MediaQuery.of(context).size.height - 56 * widget.fem,
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
                    width: 48.0 * widget.fem,
                    height: 48.0 * widget.fem,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 16.0 * widget.fem),
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
                            width: 76 * widget.fem,
                            height: 76 * widget.fem,
                            decoration: ShapeDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.5,
                                colors: [Color(0xFF00E213), Color(0x0001B5CF)],
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
                        width: 76.0 * widget.fem,
                        height: 76.0 * widget.fem,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0 * widget.fem),
                  Container(
                    width: 380 * widget.fem,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localizations.translate('the_code_sent'),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.bold16Gray80(context).copyWith(
                              fontSize: 24.0 * widget.fem,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0 * widget.fem),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  localizations.translate('code_sent_to'),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.semibold16Gray50(context)
                                      .copyWith(
                                    fontSize: 14.0 * widget.fem,
                                    height: 1.5, // 21px / 14px
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0 * widget.fem),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                mobileNumber,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.semibold16Gray50(context)
                                    .copyWith(
                                  fontSize: 14.0 * widget.fem,
                                  height: 1.5, // 21px / 14px
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0 * widget.fem),
                            GestureDetector(
                              onTap: () {
                                // Close the modal and implement Edit phone number functionality
                                Navigator.pop(context);
                              },
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppTheme.getPrimaryGradient(context)
                                        .createShader(bounds),
                                child: Text(
                                  localizations.translate('edit'),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.regular16Gray80(context)
                                      .copyWith(
                                    fontSize: 16.0,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.0 * widget.fem),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24.0 * widget.fem),
                      child: Consumer<SignUpProvider>(
                        builder: (context, signUpProvider, child) {
                          return CodeInputField(
                            fem: widget.fem,
                            controller: _controller,
                            isError: _isError,
                            isLoading: _isLoading,
                            isSuccess: _isSuccess,
                            length: 4, // Length of the OTP code
                            onCompletedCallback: (value) {
                              _checkCodeCompletion(value);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  if (_isError)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0 * widget.fem),
                      child: Text(
                        _errorMessage,
                        style: AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0,
                          color: AppColors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  CountdownTimer(
                    fem: widget.fem,
                    duration: _timerDuration,
                    onTimerComplete: _onTimerComplete,
                    onResendCode: _resendCode,
                    showResendButton: _showResendButton,
                    isLoading: _isLoading,
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
