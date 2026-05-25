import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CreateNewPasswordForm extends StatefulWidget {
  final double fem;

  const CreateNewPasswordForm({
    Key? key,
    required this.fem,
  }) : super(key: key);

  @override
  _CreateNewPasswordFormState createState() => _CreateNewPasswordFormState();
}

class _CreateNewPasswordFormState extends State<CreateNewPasswordForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordValid = true;
  bool _doPasswordsMatch = true;

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 8;
      _doPasswordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _handleSubmit() {
    _validatePassword();
    if (_isPasswordValid && _doPasswordsMatch) {
      // Handle successful password creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password successfully created')),
      );
      Navigator.pop(context); // Close the modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please check your inputs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0 * widget.fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16.0 * widget.fem)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0 * widget.fem),
            Text(
              'Create New Password',
              textAlign: TextAlign.center,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.bold16Gray80(context).copyWith(
                  fontSize: 24.0 * widget.fem,
                ),
              ),
            ),
            SizedBox(height: 24.0 * widget.fem),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: !_isPasswordValid
                    ? 'Password must be at least 8 characters'
                    : null,
              ),
              onChanged: (value) => _validatePassword(),
            ),
            SizedBox(height: 16.0 * widget.fem),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: !_doPasswordsMatch ? 'Passwords do not match' : null,
              ),
              onChanged: (value) => _validatePassword(),
            ),
            SizedBox(height: 24.0 * widget.fem),
            PrimaryButton(
              fem: widget.fem,
              isLoading: false,
              text: 'Submit',
              onPressed: _handleSubmit,
              isDisabled: !_isPasswordValid || !_doPasswordsMatch,
            ),
          ],
        ),
      ),
    );
  }
}
