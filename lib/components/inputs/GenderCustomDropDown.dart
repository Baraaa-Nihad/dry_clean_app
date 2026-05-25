import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Modals/GenderSelectionModal/GenderSelectionModal.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/style/CustomInputStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class GenderCustomDropDown extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRequired;
  final bool isDisabled;
  final bool hasError;
  final double fem;
  final Function(bool) onInputChange;
  final String? Function(String?)? validator;

  const GenderCustomDropDown({
    Key? key,
    required this.fem,
    this.hasError = false,
    required this.controller,
    required this.focusNode,
    this.isRequired = false,
    this.isDisabled = false,
    required this.onInputChange,
    this.validator,
  }) : super(key: key);

  @override
  _GenderCustomDropDownState createState() => _GenderCustomDropDownState();
}

class _GenderCustomDropDownState extends State<GenderCustomDropDown> {
  bool _isFocused = false;
  bool _isValid = true;

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
        : true; // Only check validity if validator is provided

    setState(() {
      _isValid = isValid;
      widget.onInputChange(_isValid);
    });
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  void _openModal() {
    GenderSelectionModal.show(
      context,
      widget.fem,
      widget.controller.text,
      (selectedArea) {
        setState(() {
          widget.controller.text = selectedArea;
        });
        _validateInput();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      children: [
        Container(
          width: 380 * widget.fem,
          height: 56,
          child: Focus(
            focusNode: widget.focusNode,
            child: GestureDetector(
              onTap: widget.isDisabled ? null : _openModal,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: widget.controller,
                  enabled: !widget.isDisabled,
                  decoration: CustomInputStyles.getInputDecoration(
                    filled: true, // Enable filling the background
                    fillColor: AppColors.white,
                    _isFocused,
                    _isValid,
                    widget.isDisabled,
                    hasError: widget.hasError,
                    context,
                    localizations?.translate('gender') ?? 'Gender',
                    isEmpty: widget.controller.text.isEmpty,
                    suffixIcon: SvgPicture.asset(
                      isRtl
                          ? 'assets/vectors/leftArrow.svg'
                          : 'assets/vectors/rightArrow1.svg',
                      width: 24,
                      height: 24,
                    ),
                    fem: widget.fem,
                  ),
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: widget.isDisabled
                          ? AppColors.inActiveColor
                          : AppColors.gray70,
                    ),
                  ),
                  cursorColor: AppColors.blue,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
