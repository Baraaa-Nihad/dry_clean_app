import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import localization

class EmailEditForm extends StatefulWidget {
  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final String? emailValue;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final double fem;

  const EmailEditForm({
    Key? key,
    required this.emailController,
    this.emailValue,
    required this.emailFocusNode,
    required this.onSave,
    required this.onCancel,
    required this.fem,
  }) : super(key: key);

  @override
  _EmailEditFormState createState() => _EmailEditFormState();
}

class _EmailEditFormState extends State<EmailEditForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaveDisabled = true;

  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_checkIfEmailChanged);
    _checkIfEmailChanged(); // Initial check
  }

  @override
  void dispose() {
    widget.emailController.removeListener(_checkIfEmailChanged);
    super.dispose();
  }

  void _checkIfEmailChanged() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final isChanged = widget.emailController.text != widget.emailValue;

    setState(() {
      _isSaveDisabled = !isValid || !isChanged;
    });
  }

  void _handleSave() {
    if (!_isSaveDisabled) {
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Get localization context

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextCustomInput(
            controller: widget.emailController,
            focusNode: widget.emailFocusNode,
            labelTextPrimary: localizations?.translate('Email') ??
                'Email', // Use localization
            inputType: InputType.emailAddress,
            fem: widget.fem,
            onInputChange: (isValid) {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations?.translate('Please_enter_your_email') ??
                    'Please enter your email'; // Use localization
              }
              // Email format validation
              final emailRegex =
                  RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
              if (!emailRegex.hasMatch(value)) {
                return localizations?.translate('Please_enter_a_valid_email') ??
                    'Please enter a valid email'; // Use localization
              }
              return null;
            },
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryButton(
                buttonWidth: "petiteMedium",
                text: localizations?.translate('Save') ?? 'Save',
                fem: 1,
                isDisabled: _isSaveDisabled, // Disable button if invalid
                onPressed: _handleSave,
              ),
              SizedBox(width: 24),
              SecondaryButton(
                buttonWidth: "petiteMedium",
                text: localizations?.translate('Cancel') ?? 'Cancel',
                fem: 1,
                onPressed: widget.onCancel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
