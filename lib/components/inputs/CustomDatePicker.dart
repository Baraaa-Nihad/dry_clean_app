// lib/widgets/CustomDatePicker.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/style/CustomInputStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class CustomDatePicker extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onDateSelected;
  final String labelText;
  final double fem;

  const CustomDatePicker({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onDateSelected,
    required this.labelText,
    required this.fem,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  bool _isFocused = false;
  bool _isValid = true;
  bool _isDisabled = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
    if (_isFocused) {
      _selectDate(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (Platform.isIOS) {
      _showCupertinoDatePicker(context);
    } else {
      _showMaterialDatePicker(context);
    }
  }

  Future<void> _showMaterialDatePicker(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.gray70, // Set primary color to gray70
            colorScheme: ColorScheme.light(
              primary: AppColors.gray70, // Set primary color
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray70, // Set onSurface to gray70
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      widget.controller.text = formattedDate;
      widget.onDateSelected(formattedDate);
    } else {
      // Handle cancel action
      widget.focusNode.unfocus();
    }

    widget.focusNode.unfocus();
  }

  void _showCupertinoDatePicker(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text(
                    localizations?.translate('done') ?? 'Done',
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray70,
                      ),
                    ),
                  ),
                  onPressed: () {
                    widget.focusNode.unfocus();
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: AppColors.gray70, // Set text color to gray70
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      final formattedDate =
                          "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
                      widget.controller.text = formattedDate;
                      widget.onDateSelected(formattedDate);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => widget.focusNode.unfocus());
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      child: TextField(
        controller: widget.controller,
        readOnly: true,
        decoration: CustomInputStyles.getInputDecoration(
          _isFocused,
          _isValid,
          _isDisabled,
          hasError: false,
          context,
          widget.labelText,
          labelTextSecondary: null,
          isEmpty: widget.controller.text.isEmpty,
          fem: widget.fem,
          filled: true,
          fillColor: AppColors.white,
          labelTextColor: AppColors.gray70, // Ensure label text is gray70
        ),
        style: AppTextStyles.getFontFamily(
          context,
          AppTextStyles.regular16Gray80(context).copyWith(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: AppColors.gray70, // Ensure input text is gray70
          ),
        ),
        onTap: () {
          widget.focusNode.requestFocus();
        },
      ),
    );
  }
}
