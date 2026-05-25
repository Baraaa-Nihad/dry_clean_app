import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/MessageContainer.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/SmallModal.dart';
import 'package:saleem_dry_clean/components/Modals/SuccessModal.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/feedback/feedbackTypes.dart';
import 'package:saleem_dry_clean/components/inputs/MobileNumberInput.dart';
import 'package:saleem_dry_clean/screens/SignInPage/SignIn.dart';
import 'package:saleem_dry_clean/services/FeedbackService/FeedbackProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class FeedbackPage extends StatefulWidget {
  final double fem;
  final Function(Locale) setLocale;
  final bool userSignedIn;
  final Locale currentLocale;

  const FeedbackPage({
    Key? key,
    required this.fem,
    required this.userSignedIn,
    required this.setLocale,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  // Add the required phone controller and focus node for guest users
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  bool _isButtonDisabled = true;
  int _selectedIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();

    // Dispose of the phone controller and focus node when no longer needed
    phoneController.dispose();
    phoneFocusNode.dispose();

    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isButtonDisabled = _messageController.text.trim().isEmpty;
    });
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  bool _isUserSignedIn() {
    return widget.userSignedIn;
  }

  Future<void> _handleSendMessage() async {
    final localizations = AppLocalizations.of(context);
    final feedbackProvider =
        Provider.of<FeedbackProvider>(context, listen: false);

    String selectedType = '';
    String selectedId = '';

    const types = [
      {'label': 'bug', 'id': '1'},
      {'label': 'suggestion', 'id': '2'},
      {'label': 'others', 'id': '3'}
    ];

    switch (_selectedIndex) {
      case 0:
        selectedType = types[0]['label']!;
        selectedId = types[0]['id']!;
        break;
      case 1:
        selectedType = localizations.translate(types[1]['label']!);
        selectedId = types[1]['id']!;
        break;
      case 2:
        selectedType = localizations.translate(types[2]['label']!);
        selectedId = types[2]['id']!;
        break;
    }

    String feedbackMessage = _messageController.text.trim();
    if (_isUserSignedIn()) {
      // User is logged in, send feedback with user ID
      print('Sending feedback as logged-in user');
      await feedbackProvider.sendFeedback(
        feedbackTypeId: selectedId,
        feedbackType: selectedType,
        isGuest: false, // Explicitly false for logged-in users
        guestNumber: null, // No guest number for logged-in users
        message: feedbackMessage,
        lang: widget.currentLocale.languageCode,
      );
    } else {
      // User is not logged in, send feedback as a guest
      print('Sending feedback as guest');
      if (phoneController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your mobile number';
        });
        return;
      }

      print('Guest number: ${phoneController.text}');
      await feedbackProvider.sendFeedback(
        feedbackTypeId: selectedId,
        feedbackType: selectedType,
        message: feedbackMessage,
        lang: widget.currentLocale.languageCode,
        isGuest: true,
        guestNumber: phoneController.text, // Include guest number
      );
    }

    if (feedbackProvider.errorMessage == null) {
      setState(() {
        _errorMessage = null;
      });

      // Ensure keyboard unfocus before modal closing
      FocusScope.of(context).unfocus();

      BlankModal.show(
        context,
        isDismissible: false,
        widget.fem,
        SuccessModal(
          isDismissible: false,
          isCloseable: false,
          title: localizations.translate('sent_successfully'),
          message: localizations.translate('feedback_sent'),
          mainButton: PrimaryButton(
            fem: 1,
            text: localizations.translate('done'),
            onPressed: () {
              FocusManager.instance.primaryFocus
                  ?.unfocus(); // Ensure focus removal
              Navigator.pop(context); // Close SuccessModal
              Navigator.pop(context); // Close FeedbackPage
            },
          ),
        ),
      );
    } else {
      print('Error sending feedback: ${feedbackProvider.errorMessage}');
      setState(() {
        _errorMessage = feedbackProvider.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppHeader(
        quantityNumber: false,
        prefixIcon: BackButtonWidget(
          onTap: () {
            Navigator.pop(
                context); // Correct: Passes a function that calls Navigator.pop when tapped
          },
        ),
        title: localizations.translate('feedback_and_suggestions'),
        fem: widget.fem,
        onPrefixIconTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // Ensure focus removal
          Navigator.pop(context);
        },
      ),
      body: GestureDetector(
        onTap: _unfocus,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('do_you_have_a_suggestion'),
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            height: 0,
                            color: AppColors.gray50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FeedBackTypes(
                      items: [
                        {
                          'label': localizations.translate('bug'),
                          'icon': 'bug_icon.svg',
                          'id': '1',
                          'value': 'bug',
                        },
                        {
                          'label': localizations.translate('suggestion'),
                          'icon': 'suggestion_icon.svg',
                          'id': '2',
                          'value': 'suggestion',
                        },
                        {
                          'label': localizations.translate('others'),
                          'icon': 'others_icon.svg',
                          'id': '3',
                          'value': 'others',
                        },
                      ],
                      fem: widget.fem,
                      selectedIndex: _selectedIndex,
                      onItemSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      maxLines: 10,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.gray30,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.gray20,
                            width: 1.0,
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelText:
                            localizations.translate('describe_experience_here'),
                        alignLabelWithHint: true,
                        labelStyle: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              height: 0,
                              color: AppColors.gray50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_isUserSignedIn()) ...[
                      // Show phone number input for guest users
                      Text(
                        localizations.translate('input_guest_number'),
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              height: 0,
                              color: AppColors.gray50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      MobileNumberInput(
                        controller: phoneController,
                        focusNode: phoneFocusNode,
                        hasError: false,
                        fem: 1.0,
                        showDropdown: false,
                        enableValidation: false,
                        labelTextPrimary: localizations.translate(''),
                        labelTextSecondary:
                            localizations.translate('enter_mobile_number'),
                        countryCodes: ['+970', '+972'],
                        onCountryCodeChanged: (code) {
                          print('Country code selected: $code');
                        },
                        onInputChange: (isValid) {
                          print('Input is valid: $isValid');
                        },
                        isRtl: isRtl,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_errorMessage != null)
                      MessageContainer(
                        message: _errorMessage!,
                        type: MessageType.error,
                      ),
                    const SizedBox(height: 40),
                    LoadingButton(
                      buttonWidth: "full",
                      fem: widget.fem,
                      isDisabled: _isButtonDisabled,
                      buttonText: localizations.translate('send_feedback'),
                      onPressed: _isButtonDisabled ? null : _handleSendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
