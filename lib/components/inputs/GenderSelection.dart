import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';

class GenderSelection extends StatefulWidget {
  final double fem;
  final Function(String) onGenderChanged;

  const GenderSelection({
    Key? key,
    required this.fem,
    required this.onGenderChanged,
  }) : super(key: key);

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  String _selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(
              'Male',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 14.0,
                  color: AppColors.gray70,
                ),
              ),
            ),
            leading: Radio<String>(
              value: 'Male',
              groupValue: _selectedGender,
              activeColor: AppColors.blue,
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value!;
                  widget.onGenderChanged(_selectedGender);
                });
              },
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text(
              'Female',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 14.0,
                  color: AppColors.gray70,
                ),
              ),
            ),
            leading: Radio<String>(
              value: 'Female',
              groupValue: _selectedGender,
              activeColor: AppColors.blue,
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value!;
                  widget.onGenderChanged(_selectedGender);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
