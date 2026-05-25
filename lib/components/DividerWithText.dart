// divider_with_text.dart
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double fem;

  const DividerWithText({Key? key, required this.text, required this.fem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFFE6EDF5),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * fem),
          child: Text(
            text,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray50(context).copyWith(
                  fontSize: 13.0 * fem, height: 0, fontWeight: FontWeight.w500),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24 * fem),
        Expanded(
          child: Divider(
            color: Color(0xFFE6EDF5),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
