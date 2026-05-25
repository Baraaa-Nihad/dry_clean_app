import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/inputs/CustomDatePicker.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/style/CustomInputStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';

enum InputType {
  text,
  password,
  phoneNumber,
  number,
  emailAddress,
  multiline,
  date
}

class TextCustomInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRequired;
  final double? textInputHeight;
  final bool isDisabled;
  final bool hasError;
  final String labelTextPrimary;
  final String? labelTextSecondary;
  final double fem;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(bool) onInputChange;
  final String? Function(String?)? validator;
  final InputType inputType;

  const TextCustomInput({
    Key? key,
    required this.fem,
    required this.controller,
    required this.focusNode,
    this.textInputHeight = 56.0,
    this.isRequired = false,
    this.isDisabled = false,
    this.hasError = false,
    required this.labelTextPrimary,
    this.labelTextSecondary,
    this.prefixIcon,
    this.suffixIcon,
    required this.onInputChange,
    this.validator,
    this.inputType = InputType.text,
  }) : super(key: key);

  @override
  _TextCustomInputState createState() => _TextCustomInputState();
}

class _TextCustomInputState extends State<TextCustomInput> {
  bool _isFocused = false;
  bool _isValid = true;
  String? _errorMessage;

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
    String input = widget.controller.text;
    bool isValid = widget.validator != null
        ? widget.validator!(input) == null
        : ValidationUtils.validateInput(input, widget.isRequired);

    setState(() {
      _isValid = isValid;
      _errorMessage =
          widget.validator != null ? widget.validator!(input) : null;
      widget.onInputChange(_isValid);
    });
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inputType == InputType.date) {
      return CustomDatePicker(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onDateSelected: (date) {
          _validateInput();
        },
        labelText: widget.labelTextPrimary,
        fem: widget.fem,
      );
    }

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
      case InputType.emailAddress:
        keyboardType = TextInputType.emailAddress;
        break;
      case InputType.multiline:
        keyboardType = TextInputType.multiline;
        break;
      default:
        keyboardType = TextInputType.text;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 380,
          height: widget.textInputHeight ?? 56.0,
          child: Focus(
            focusNode: widget.focusNode,
            child: TextField(
              controller: widget.controller,
              enabled: !widget.isDisabled,
              obscureText: obscureText,
              keyboardType: keyboardType,
              maxLines: widget.inputType == InputType.multiline ? null : 1,
              decoration: CustomInputStyles.getInputDecoration(
                _isFocused,
                _isValid,
                widget.isDisabled,
                hasError: widget.hasError,
                context,
                widget.labelTextPrimary,
                labelTextSecondary: widget.labelTextSecondary,
                isEmpty: widget.controller.text.isEmpty,
                prefixIcon: widget.prefixIcon != null
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: widget.prefixIcon,
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
                filled: true,
                fillColor: AppColors.white,
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
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _errorMessage!,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: AppColors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
