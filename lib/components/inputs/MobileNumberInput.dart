import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/style/MobileInputStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'CountryCodeDropdown.dart'; // Import the CountryCodeDropdown

enum InputType { text, password, phoneNumber, number }

class MobileNumberInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRequired;
  final bool isDisabled;
  final String labelTextPrimary;
  final String? labelTextSecondary;
  final double fem;
  final List<String> countryCodes;
  final Function(String) onCountryCodeChanged;
  final Function(bool) onInputChange;
  final String? Function(String?)? validator;
  final InputType inputType;
  final Widget? suffixIcon;
  final bool showValidationMessage;
  final bool hasError;
  final bool enableValidation;
  final bool isRtl;
  final bool showDropdown; // Add the showDropdown parameter

  const MobileNumberInput({
    Key? key,
    required this.fem,
    required this.controller,
    required this.focusNode,
    this.isRequired = false,
    this.isDisabled = false,
    required this.labelTextPrimary,
    this.labelTextSecondary,
    required this.countryCodes,
    required this.onCountryCodeChanged,
    required this.onInputChange,
    this.validator,
    this.inputType = InputType.phoneNumber, // Default to phoneNumber
    this.suffixIcon,
    this.showValidationMessage = true,
    this.hasError = false,
    this.enableValidation = true,
    this.isRtl = false,
    this.showDropdown = true, // Default value for showDropdown
  }) : super(key: key);

  @override
  _MobileNumberInputState createState() => _MobileNumberInputState();
}

class _MobileNumberInputState extends State<MobileNumberInput> {
  bool _isFocused = false;
  bool _isValid = true;
  String _validationMessage = '';
  String _selectedCountryCode = '+970';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInput);
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _validateInput() {
    if (!widget.enableValidation) {
      setState(() {
        _isValid = true;
        _validationMessage = '';
        widget.onInputChange(true);
      });
      return;
    }

    String input = widget.controller.text;

    if (input.isNotEmpty) {
      // Remove leading '0' if present
      if (input.startsWith('0')) {
        input = input.substring(1);
        widget.controller.text = input;
      }

      // Check if input starts with '0' or '5'
      if (input.startsWith('0') || input.startsWith('5')) {
        // Validate input length based on starting digit
        bool isValid = widget.validator != null
            ? widget.validator!(input) == null
            : ValidationUtils.validateInput(input, widget.isRequired);

        setState(() {
          _isValid = isValid;
          _validationMessage = isValid
              ? ''
              : AppLocalizations.of(context)
                      ?.translate('invalid_phone_number') ??
                  'Invalid phone number';
          widget.onInputChange(_isValid);
        });
      } else {
        // Input does not start with '0' or '5'
        setState(() {
          _isValid = false;
          _validationMessage =
              AppLocalizations.of(context)?.translate('invalid_phone_number') ??
                  'Invalid phone number';
          widget.onInputChange(_isValid);
        });
      }
    } else {
      // Clear validation message when input is empty
      setState(() {
        _isValid = true;
        _validationMessage = '';
        widget.onInputChange(_isValid);
      });
    }
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  void _onCountryCodeChanged(String code) {
    setState(() {
      _selectedCountryCode = code;
      widget.onCountryCodeChanged(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;
    bool obscureText = false;

    switch (widget.inputType) {
      case InputType.text:
        keyboardType = TextInputType.text;
        break;
      case InputType.password:
        keyboardType = TextInputType.visiblePassword;
        obscureText = true;
        break;
      case InputType.phoneNumber:
        keyboardType = TextInputType.phone;
        break;
      case InputType.number:
        keyboardType = TextInputType.number;
        break;
      default:
        keyboardType = TextInputType.text;
    }

    List<TextInputFormatter> inputFormatters = [];
    if (widget.enableValidation && widget.inputType == InputType.phoneNumber) {
      inputFormatters.add(DynamicLengthLimitingTextInputFormatter(
        maxLength0: 10,
        maxLength5: 9,
      ));
    }

    // Add conditional padding based on dropdown visibility
    EdgeInsetsGeometry contentPadding = widget.showDropdown
        ? const EdgeInsets.only(left: 50.0, right: 12.0) // Space for dropdown
        : const EdgeInsets.all(12.0); // Full padding when no dropdown

    // Wrap the TextField in Directionality for RTL support
    return Directionality(
      textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment:
            widget.isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: 380,
            height: 56,
            color: AppColors.white,
            child: Focus(
              focusNode: widget.focusNode,
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isDisabled,
                obscureText: obscureText,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                decoration: MobileInputStyles.getInputDecoration(
                  context, // Add context as a parameter
                  _isFocused,
                  _isValid && !widget.hasError,
                  widget.isDisabled,
                  widget.labelTextPrimary,
                  labelTextSecondary: widget.labelTextSecondary,
                  isEmpty: widget.controller.text.isEmpty,
                  prefixIcon: widget.showDropdown
                      ? CountryCodeDropdown(
                          selectedCountryCode: _selectedCountryCode,
                          countryCodes: widget.countryCodes,
                          onChanged: _onCountryCodeChanged,
                          fem: widget.fem,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: widget.suffixIcon,
                        )
                      : null,
                  fem: widget.fem,
                  hasError: widget.hasError,
                  isRtl: widget.isRtl,
                ),
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: widget.isDisabled
                        ? AppColors.inActiveColor
                        : AppColors.gray70,
                  ),
                ),
                cursorColor: AppColors.blue,
              ),
            ),
          ),
          if (!_isValid &&
              widget.controller.text.isNotEmpty &&
              widget.showValidationMessage)
            Padding(
              padding: EdgeInsets.only(
                  left: widget.isRtl ? 0.0 : 8.0,
                  right: widget.isRtl ? 8.0 : 0.0),
              child: Text(
                _validationMessage,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      height: 0,
                      color: AppColors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DynamicLengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxLength0;
  final int maxLength5;

  DynamicLengthLimitingTextInputFormatter({
    required this.maxLength0,
    required this.maxLength5,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    int maxLength = newText.startsWith('0')
        ? maxLength0
        : newText.startsWith('5')
            ? maxLength5
            : newText.length; // Allow full length if validation is disabled

    if (newText.length > maxLength && maxLength != 0) {
      return oldValue;
    }

    return newValue;
  }
}
