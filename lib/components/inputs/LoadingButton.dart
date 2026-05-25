import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppPrimaryButtonStyles.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;

  const LoadingButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.9; // 90% of the screen width

        return Container(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 380,
              height: 56, // Fixed height for the button
              decoration: AppPrimaryButtonStyles.getDecoration(isDisabled),
              child: ElevatedButton(
                onPressed: isDisabled ? null : onPressed,
                style:
                    AppPrimaryButtonStyles.getButtonStyle(context, isDisabled),
                child: Text(
                  text,
                  style: AppTextStyles.bold16White(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
