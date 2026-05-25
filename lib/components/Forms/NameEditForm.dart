import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class NameEditForm extends StatefulWidget {
  final TextEditingController firstNameController;
  final FocusNode firstNameFocusNode;
  final TextEditingController lastNameController;
  final FocusNode lastNameFocusNode;
  final Future<void> Function() onSave;
  final VoidCallback onCancel;
  final double fem;

  const NameEditForm({
    Key? key,
    required this.firstNameController,
    required this.firstNameFocusNode,
    required this.lastNameController,
    required this.lastNameFocusNode,
    required this.onSave,
    required this.onCancel,
    required this.fem,
  }) : super(key: key);

  @override
  _NameEditFormState createState() => _NameEditFormState();
}

class _NameEditFormState extends State<NameEditForm> {
  late String originalFirstName;
  late String originalLastName;
  bool isSaveDisabled = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    originalFirstName = widget.firstNameController.text;
    originalLastName = widget.lastNameController.text;

    widget.firstNameController.addListener(_checkIfChanged);
    widget.lastNameController.addListener(_checkIfChanged);
  }

  void _checkIfChanged() {
    setState(() {
      isSaveDisabled = (widget.firstNameController.text == originalFirstName &&
              widget.lastNameController.text == originalLastName) ||
          !_isValidName(widget.firstNameController.text) ||
          !_isValidName(widget.lastNameController.text);
    });
  }

  Future<void> _handleSave() async {
    setState(() {
      isLoading = true;
    });

    try {
      await widget.onSave();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.firstNameController.removeListener(_checkIfChanged);
    widget.lastNameController.removeListener(_checkIfChanged);
    super.dispose();
  }

  bool _isValidName(String name) {
    final nameRegex = RegExp(r"^[a-zA-Z\u0621-\u064A\s'-]{2,}$");
    return nameRegex.hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      child: Column(
        children: [
          TextCustomInput(
            controller: widget.firstNameController,
            focusNode: widget.firstNameFocusNode,
            labelTextPrimary:
                localizations.translate('first_name') ?? 'First name',
            fem: widget.fem,
            onInputChange: (isValid) {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('please_enter_first_name') ??
                    'Please enter your first name';
              }
              if (!_isValidName(value)) {
                return localizations.translate('Invalid_first_name_format') ??
                    'Invalid first name format';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextCustomInput(
            controller: widget.lastNameController,
            focusNode: widget.lastNameFocusNode,
            labelTextPrimary:
                localizations.translate('last_name') ?? 'Last name',
            fem: widget.fem,
            onInputChange: (isValid) {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('Please_enter_your_last_name') ??
                    'Please enter your last name';
              }
              if (!_isValidName(value)) {
                return localizations.translate('Invalid_last_name_format') ??
                    'Invalid last name format';
              }
              return null;
            },
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingButton(
                buttonWidth: "petiteMedium",
                buttonText: localizations.translate('Save') ?? 'Save',
                fem: widget.fem,
                isLoading: isLoading,
                isDisabled: isSaveDisabled,
                onPressed: isSaveDisabled ? null : _handleSave,
              ),
              SizedBox(width: 24),
              SecondaryButton(
                buttonWidth: "petiteMedium",
                text: localizations.translate('Cancel') ?? 'Cancel',
                fem: widget.fem,
                isDisabled: isLoading,
                onPressed: isLoading ? null : widget.onCancel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
