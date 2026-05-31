import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/EmergencyCard.dart';
import 'package:saleem_dry_clean/components/Cards/MessageContainer.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/SuccessModal.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/MobileNumberInput.dart';
import 'package:saleem_dry_clean/services/ContactServices/ContactProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ContactPage extends StatefulWidget {
  final double fem;
  final Function(Locale) setLocale;
  final bool userSignedIn;
  final Locale currentLocale;

  const ContactPage({
    Key? key,
    required this.fem,
    required this.userSignedIn,
    required this.setLocale,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isButtonDisabled = true;
  final TextEditingController mobileController = TextEditingController();
  final FocusNode mobileFocusNode = FocusNode();
  String? _errorMessage; // Variable to store error message

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    mobileController.dispose();
    mobileFocusNode.dispose();
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

  void _handleSendMessage(BuildContext context) async {
    final contactProvider =
        Provider.of<ContactProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    if (_isUserSignedIn()) {
      // Send message for signed-in user
      await contactProvider.sendContactForm(
        message: _messageController.text.trim(),
      );

      if (contactProvider.errorMessage == null) {
        _errorMessage = null; // Clear error message on success
        // Show success modal
        BlankModal.show(
          context,
          widget.fem, // Pass fem as an argument if needed
          SuccessModal(
            title: localizations?.translate('message_sent') ?? 'Message Sent',
            message: localizations?.translate('message_sent_success') ??
                'Your message has been sent successfully.',
            mainButton: PrimaryButton(
              fem: 1,
              text: localizations?.translate('done') ?? 'Done',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      } else {
        // Set error message
        setState(() {
          _errorMessage = contactProvider.errorMessage ?? 'Error';
        });
      }
    } else {
      // Send message as guest with mobile number
      if (mobileController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(localizations?.translate('enter_mobile') ??
              'Please enter your mobile number'),
        ));
        return;
      }

      await contactProvider.sendContactForm(
        message: _messageController.text.trim(),
        isGuest: true,
        guestNumber: mobileController.text.trim(),
      );

      if (contactProvider.errorMessage == null) {
        _errorMessage = null; // Clear error message on success
        // Show success modal
        BlankModal.show(
          context,
          widget.fem,
          SuccessModal(
            title: localizations?.translate('message_sent') ?? 'Message Sent',
            message: localizations?.translate('message_sent_success') ??
                'Your message has been sent successfully.',
            mainButton: PrimaryButton(
              fem: 1,
              text: localizations?.translate('done') ?? 'Done',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = contactProvider.errorMessage ?? 'Error';
        });
      }
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
        title: localizations?.translate('contact_us') ?? 'Contact us',
        fem: widget.fem,
        onPrefixIconTap: () {
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
                      localizations?.translate('we_love_to_hear') ??
                          'We’d love to hear from you. Our friendly team is always here to chat.',
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: localizations?.translate('enter_message') ??
                            'Enter your message here',
                        hintStyle: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray50),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: AppColors.gray30, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: AppColors.gray20, width: 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_errorMessage != null) // Show error if exists
                      MessageContainer(
                        message: _errorMessage!,
                        type: MessageType.error,
                      ),
                    const SizedBox(height: 12),
                    if (!_isUserSignedIn()) // Show mobile input if not signed in
                      MobileNumberInput(
                        controller: mobileController,
                        focusNode: mobileFocusNode,
                        fem: widget.fem,
                        showDropdown: false,
                        enableValidation: false,
                        labelTextPrimary:
                            localizations?.translate('mobile_number') ??
                                'Mobile Number',
                        countryCodes: ['+970', '+972'],
                        onCountryCodeChanged: (code) =>
                            print('Country code: $code'),
                        onInputChange: (isValid) =>
                            print('Input is valid: $isValid'),
                        isRtl: isRtl,
                      ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      buttonWidth: "full",
                      fem: widget.fem,
                      isDisabled: _isButtonDisabled,
                      text: localizations?.translate('send_message') ??
                          'Send message',
                      onPressed: _isButtonDisabled
                          ? null
                          : () => _handleSendMessage(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    EmergencyCard(
                      isPhoneNumber: true,
                      iconPath: 'assets/Icons/phoneBlue.svg',
                      title: localizations?.translate('phone_number') ??
                          'Phone number',
                      subtitle: localizations?.translate('sat_wed_hours') ??
                          'Sat-Wed from 8:00am to 5:00pm',
                      contact1: '+970 123 456 789',
                      contact2: '+972 111 222 333',
                    ),
                    const SizedBox(height: 16),
                    EmergencyCard(
                      isPhoneNumber: false,
                      iconPath: 'assets/Icons/sms.svg',
                      title: localizations?.translate('email') ?? 'Email',
                      subtitle: localizations?.translate('friendly_help') ??
                          'Our friendly team is here to help.',
                      contact1: 'Dry-cleaning@birdie.ps',
                      contact2: '',
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
